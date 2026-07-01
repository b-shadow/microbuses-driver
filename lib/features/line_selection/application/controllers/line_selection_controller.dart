import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/driver_api.dart';

class LineSelectionController extends ChangeNotifier {
  LineSelectionController({DriverApi? api}) : _api = api ?? DriverApi();

  final DriverApi _api;
  String status = '';
  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> changeLine(String newLineId) async {
    final prefs = await SharedPreferences.getInstance();
    final busId = prefs.getString('selected_bus_id');
    if (busId == null || busId.isEmpty) {
      status = 'Selecciona microbus primero.';
      _notify();
      return;
    }
    try {
      await _api.dio.post('/buses/$busId/change-line', data: {'line_id': newLineId}, options: await _api.auth());
      await prefs.setString('selected_line_id', newLineId);
      status = 'Linea actualizada correctamente.';
    } catch (_) {
      status = 'No se pudo cambiar la linea.';
    }
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
