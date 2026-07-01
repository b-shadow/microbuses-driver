import 'package:flutter/foundation.dart';

import '../../../../core/services/driver_api.dart';

class AuditViewController extends ChangeNotifier {
  AuditViewController({DriverApi? api}) : _api = api ?? DriverApi();

  final DriverApi _api;
  final List<dynamic> rows = [];
  String status = '';
  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadAudit() async {
    try {
      final res = await _api.dio.get('/audit', options: await _api.auth());
      rows
        ..clear()
        ..addAll(res.data['data'] as List<dynamic>);
      status = rows.isEmpty ? 'Sin eventos.' : 'Eventos cargados.';
    } catch (_) {
      rows.clear();
      status = 'No se pudo cargar auditoria.';
    }
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
