import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/services/driver_api.dart';

class DriverProfileController extends ChangeNotifier {
  DriverProfileController({DriverApi? api}) : _api = api ?? DriverApi();

  final DriverApi _api;
  String profileJson = 'Cargando...';
  String status = '';
  Map<String, dynamic> profile = {};
  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    try {
      final res = await _api.dio.get('/auth/me', options: await _api.auth());
      profile = Map<String, dynamic>.from((res.data['data'] ?? {}) as Map);
      profileJson = const JsonEncoder.withIndent('  ').convert(profile);
      status = profile.isEmpty ? 'Sin datos de perfil.' : 'Perfil cargado.';
    } catch (error) {
      profile = {};
      status = DriverApi.describeError(error,
          fallback: 'No se pudo cargar el perfil.');
      profileJson = status;
    }
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
