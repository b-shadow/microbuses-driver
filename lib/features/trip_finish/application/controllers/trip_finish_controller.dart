import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/driver_api.dart';

class TripFinishController extends ChangeNotifier {
  TripFinishController({DriverApi? api}) : _api = api ?? DriverApi();

  final DriverApi _api;
  bool _disposed = false;

  bool isLoading = false;
  String status = '';
  DateTime? startedAt;
  DateTime? finishedAt;
  String activeTripId = '';

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

  Future<bool> finishCurrentTrip() async {
    isLoading = true;
    status = 'Finalizando recorrido...';
    _notify();

    final prefs = await SharedPreferences.getInstance();
    final tripId = prefs.getString('driver_active_trip_id');
    if (tripId == null || tripId.isEmpty) {
      status = 'No hay viaje activo.';
      isLoading = false;
      _notify();
      return false;
    }
    activeTripId = tripId;
    final localStarted = prefs.getString('driver_active_trip_started_at');
    startedAt = _parseServerDate(localStarted);

    try {
      final res = await _api.dio
          .post('/active-trips/$tripId/finish', options: await _api.auth());
      final data = Map<String, dynamic>.from((res.data['data'] ?? {}) as Map);
      startedAt = _parseServerDate(data['started_at']?.toString());
      finishedAt = _parseServerDate(data['finished_at']?.toString());
      await prefs.remove('driver_active_trip_id');
      await prefs.remove('driver_active_trip_started_at');
      await prefs.remove('driver_gps_queue');
      status = 'Recorrido finalizado correctamente.';
      isLoading = false;
      _notify();
      return true;
    } catch (error) {
      status = DriverApi.describeError(error,
          fallback: 'No se pudo finalizar el recorrido.');
      isLoading = false;
      _notify();
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
