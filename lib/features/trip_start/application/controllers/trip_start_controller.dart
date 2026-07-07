import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/driver_api.dart';
import '../../../../core/services/location_permission_service.dart';

class DriverOperationLineOption {
  const DriverOperationLineOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class TripStartController extends ChangeNotifier {
  TripStartController({
    DriverApi? api,
    DriverLocationPermissionService? locationService,
  })  : _api = api ?? DriverApi(),
        _locationService = locationService ?? DriverLocationPermissionService();

  final DriverApi _api;
  final DriverLocationPermissionService _locationService;
  bool _disposed = false;

  bool isLoading = false;
  String status = '';
  String selectedBusId = '';
  String selectedLineId = '';
  String activeTripId = '';
  DateTime? activeTripStartedAt;
  final List<Map<String, dynamic>> buses = [];
  final List<DriverOperationLineOption> lines = [];
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

  Future<void> preloadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    selectedBusId = prefs.getString('selected_bus_id') ?? '';
    selectedLineId = prefs.getString('selected_line_id') ?? '';
    activeTripId = prefs.getString('driver_active_trip_id') ?? '';
    final startedAtRaw = prefs.getString('driver_active_trip_started_at');
    activeTripStartedAt = _parseServerDate(startedAtRaw);
    _notify();
  }

  Future<void> loadContext() async {
    await preloadSelection();
    await Future.wait([
      loadBuses(),
      loadLines(),
      loadCurrentLocation(),
    ]);
  }

  Future<void> loadCurrentLocation() async {
    final result = await _locationService.currentPosition();
    if (!result.hasPosition) {
      status =
          result.message ?? 'No se pudo obtener la ubicacion del dispositivo.';
      _notify();
      return;
    }

    final position = result.position!;
    currentLat = position.latitude;
    currentLng = position.longitude;
    _notify();
  }

  Future<void> loadBuses() async {
    try {
      final res = await _api.dio.get('/buses', options: await _api.auth());
      final rows = (res.data['data'] as List<dynamic>? ?? []);
      buses
        ..clear()
        ..addAll(rows.map((raw) => Map<String, dynamic>.from(raw as Map)));

      if (selectedBusId.isNotEmpty) {
        final selected = selectedBus;
        if (selected != null) {
          final lineId = (selected['line_id'] ?? '').toString();
          if (lineId.isNotEmpty && selectedLineId.isEmpty) {
            selectedLineId = lineId;
          }
        }
      }
    } catch (error) {
      buses.clear();
      status = DriverApi.describeError(error,
          fallback: 'No se pudieron cargar microbuses.');
    }
    _notify();
  }

  Future<void> loadLines() async {
    try {
      final res = await _api.dio.get('/lineas');
      final rows = (res.data['data'] as List<dynamic>? ?? []);
      lines
        ..clear()
        ..addAll(
          rows.map((raw) {
            final row = Map<String, dynamic>.from(raw as Map);
            return DriverOperationLineOption(
              id: ((row['id_linea'] ?? '') as Object).toString(),
              name: (row['nombre_linea'] ?? '').toString(),
            );
          }).where((line) => line.id.isNotEmpty),
        );
    } catch (error) {
      if (status.isEmpty) {
        status = DriverApi.describeError(error,
            fallback: 'No se pudieron cargar lineas.');
      }
    }
    _notify();
  }

  Map<String, dynamic>? get selectedBus {
    if (selectedBusId.isEmpty) return null;
    for (final bus in buses) {
      if ((bus['id'] ?? '').toString() == selectedBusId) {
        return bus;
      }
    }
    return null;
  }

  String get selectedLineName {
    for (final line in lines) {
      if (line.id == selectedLineId) {
        return line.name;
      }
    }
    return selectedLineId;
  }

  Future<void> selectBus(String busId) async {
    selectedBusId = busId;
    final bus = selectedBus;
    final lineId = (bus?['line_id'] ?? '').toString();
    if (lineId.isNotEmpty) {
      selectedLineId = lineId;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_bus_id', selectedBusId);
    if (selectedLineId.isNotEmpty) {
      await prefs.setString('selected_line_id', selectedLineId);
    }
    status = 'Microbus seleccionado para la jornada.';
    _notify();
  }

  Future<void> changeLine(String newLineId) async {
    if (selectedBusId.isEmpty) {
      status = 'Selecciona un microbus antes de definir la linea.';
      _notify();
      return;
    }
    isLoading = true;
    status = 'Actualizando linea operativa...';
    _notify();
    try {
      await _api.dio.post(
        '/buses/$selectedBusId/change-line',
        data: {'line_id': int.parse(newLineId)},
        options: await _api.auth(),
      );
      selectedLineId = newLineId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_line_id', newLineId);
      status = 'Linea operativa actualizada.';
      await loadBuses();
    } catch (error) {
      status = DriverApi.describeError(error,
          fallback: 'No se pudo cambiar la linea.');
    }
    isLoading = false;
    _notify();
  }

  Future<String?> startTrip(
      {required String busId, required String lineId}) async {
    isLoading = true;
    status = 'Iniciando recorrido...';
    _notify();
    try {
      final res = await _api.dio.post(
        '/active-trips/start',
        data: {'bus_id': busId, 'line_id': lineId},
        options: await _api.auth(),
      );
      final tripId = res.data['data']?['id'] as String?;
      if (tripId == null || tripId.isEmpty) {
        status = 'No se pudo obtener el viaje activo.';
        isLoading = false;
        _notify();
        return null;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_active_trip_id', tripId);
      await prefs.setString('selected_bus_id', busId);
      await prefs.setString('selected_line_id', lineId);
      final startedAtRaw = res.data['data']?['started_at']?.toString();
      if (startedAtRaw != null && startedAtRaw.isNotEmpty) {
        activeTripStartedAt = _parseServerDate(startedAtRaw);
        await prefs.setString('driver_active_trip_started_at', startedAtRaw);
      }
      activeTripId = tripId;
      selectedBusId = busId;
      selectedLineId = lineId;
      status = 'Tu recorrido esta activo.';
      isLoading = false;
      _notify();
      return tripId;
    } catch (error) {
      status = DriverApi.describeError(error,
          fallback: 'No se pudo iniciar el recorrido.');
      isLoading = false;
      _notify();
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
