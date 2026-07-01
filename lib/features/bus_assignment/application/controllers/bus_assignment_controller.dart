import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/driver_api.dart';

class BusAssignmentController extends ChangeNotifier {
  BusAssignmentController({DriverApi? api}) : _api = api ?? DriverApi();

  final DriverApi _api;
  final List<dynamic> buses = [];
  String status = '';
  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadBuses() async {
    try {
      final res = await _api.dio.get('/buses', options: await _api.auth());
      buses
        ..clear()
        ..addAll(res.data['data'] as List<dynamic>);
      status = buses.isEmpty ? 'Sin microbuses disponibles.' : 'Microbuses cargados.';
    } catch (_) {
      buses.clear();
      status = 'No se pudieron cargar microbuses.';
    }
    _notify();
  }

  Future<void> selectBus({required String busId, required String lineId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_bus_id', busId);
    await prefs.setString('selected_line_id', lineId);
    status = 'Microbus seleccionado.';
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
