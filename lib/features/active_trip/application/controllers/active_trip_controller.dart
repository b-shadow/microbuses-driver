import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/driver_api.dart';
import '../../../../core/services/location_permission_service.dart';

class ActiveTripController extends ChangeNotifier {
  ActiveTripController({
    DriverApi? api,
    DriverLocationPermissionService? locationService,
  })  : _api = api ?? DriverApi(),
        _locationService = locationService ?? DriverLocationPermissionService();

  final DriverApi _api;
  final DriverLocationPermissionService _locationService;
  Timer? _timer;
  final Random _random = Random();
  bool _disposed = false;

  bool isRunning = false;
  bool isLoading = false;
  String status = 'Sin viaje activo.';
  String activeTripId = '';
  DateTime? lastSentAt;
  DateTime? startedAt;
  double currentLat = -17.7833;
  double currentLng = -63.1821;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  DateTime? _parseServerDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final raw = value.trim();
    final normalized =
        raw.contains('Z') || RegExp(r'([+-]\d{2}:\d{2})$').hasMatch(raw)
            ? raw
            : '${raw}Z';
    return DateTime.tryParse(normalized);
  }

  Future<void> _clearActiveTripSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_active_trip_id');
    await prefs.remove('driver_active_trip_started_at');
    activeTripId = '';
    isRunning = false;
    _timer?.cancel();
  }

  Future<void> loadActiveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    activeTripId = prefs.getString('driver_active_trip_id') ?? '';
    if (activeTripId.isEmpty) {
      status = 'No hay viaje activo.';
      _notify();
      return;
    }
    String? loadWarning;
    try {
      final res = await _api.dio
          .get('/active-trips/current', options: await _api.auth());
      final data = Map<String, dynamic>.from((res.data['data'] ?? {}) as Map);
      activeTripId = (data['id'] ?? activeTripId).toString();
      startedAt = _parseServerDate(data['started_at']?.toString());
    } catch (error) {
      final localStarted = prefs.getString('driver_active_trip_started_at');
      startedAt = _parseServerDate(localStarted);
      loadWarning = DriverApi.describeError(error,
          fallback: 'No se pudo consultar el viaje activo.');
    }
    final hasLocation = await _loadCurrentLocation();
    if (hasLocation) {
      status = loadWarning ?? 'Viaje activo cargado.';
    }
    _notify();
  }

  Future<bool> _loadCurrentLocation() async {
    final result = await _locationService.currentPosition();
    if (!result.hasPosition) {
      status =
          result.message ?? 'No se pudo obtener la ubicacion del dispositivo.';
      _notify();
      return false;
    }

    final position = result.position!;
    currentLat = position.latitude;
    currentLng = position.longitude;
    return true;
  }

  Future<void> startTracking() async {
    if (activeTripId.isEmpty) await loadActiveTrip();
    if (activeTripId.isEmpty) return;
    final hasLocation = await _loadCurrentLocation();
    if (!hasLocation) {
      isRunning = false;
      _timer?.cancel();
      _notify();
      return;
    }

    isRunning = true;
    status = 'Tracking iniciado. Envio cada 10 segundos.';
    _notify();

    await flushQueue();
    await sendNow();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => sendNow());
  }

  Future<void> stopTracking() async {
    _timer?.cancel();
    isRunning = false;
    status = 'Tracking detenido.';
    _notify();
  }

  Future<void> sendNow() async {
    if (activeTripId.isEmpty) return;
    final hasLocation = await _loadCurrentLocation();
    if (!hasLocation) {
      isRunning = false;
      _timer?.cancel();
      _notify();
      return;
    }

    final payload = {
      'lat': currentLat + (_random.nextDouble() - 0.5) / 2000,
      'lng': currentLng + (_random.nextDouble() - 0.5) / 2000,
      'speed': 22.0,
      'recorded_at': DateTime.now().toIso8601String(),
    };

    try {
      await _api.dio.post('/tracking/location',
          data: {'active_trip_id': activeTripId, ...payload},
          options: await _api.auth());
      currentLat = (payload['lat'] as num).toDouble();
      currentLng = (payload['lng'] as num).toDouble();
      lastSentAt = DateTime.now();
      status = 'Ubicacion enviada hace 10 segundos.';
      _notify();
      await flushQueue();
    } on DioException catch (error) {
      final errorCode = error.response?.data is Map<String, dynamic>
          ? error.response?.data['error_code']?.toString()
          : null;
      if (error.response?.statusCode == 409 &&
          errorCode == 'INVALID_ACTIVE_TRIP') {
        await _clearActiveTripSession();
        status = 'El viaje activo ya fue cerrado. Se detuvo el tracking.';
        _notify();
        return;
      }
      await queuePoint(payload);
      status = DriverApi.describeError(error,
          fallback: 'Sin conexion. Se guardara temporalmente.');
      _notify();
    } catch (error) {
      await queuePoint(payload);
      status = DriverApi.describeError(error,
          fallback: 'Sin conexion. Se guardara temporalmente.');
      _notify();
    }
  }

  Future<void> queuePoint(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('driver_gps_queue') ?? [];
    queue.add(jsonEncode(payload));
    await prefs.setStringList('driver_gps_queue', queue);
  }

  Future<void> flushQueue() async {
    if (activeTripId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('driver_gps_queue') ?? [];
    if (queue.isEmpty) return;

    final points =
        queue.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    try {
      await _api.dio.post('/tracking/batch',
          data: {'active_trip_id': activeTripId, 'points': points},
          options: await _api.auth());
      await prefs.remove('driver_gps_queue');
      status = 'Cola local sincronizada.';
      _notify();
    } on DioException catch (error) {
      final errorCode = error.response?.data is Map<String, dynamic>
          ? error.response?.data['error_code']?.toString()
          : null;
      if (error.response?.statusCode == 409 &&
          errorCode == 'INVALID_ACTIVE_TRIP') {
        await prefs.remove('driver_gps_queue');
        await _clearActiveTripSession();
        status =
            'El viaje activo ya fue cerrado. Se descarto la cola pendiente.';
        _notify();
        return;
      }
      status = DriverApi.describeError(error,
          fallback: 'Sin conexion. Cola local pendiente.');
      _notify();
    } catch (error) {
      status = DriverApi.describeError(error,
          fallback: 'Sin conexion. Cola local pendiente.');
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
