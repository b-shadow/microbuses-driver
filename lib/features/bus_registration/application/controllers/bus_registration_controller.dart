import 'package:flutter/foundation.dart';

import '../../../../core/services/driver_api.dart';

class DriverLineOption {
  const DriverLineOption({
    required this.id,
    required this.name,
    this.color,
  });

  final int id;
  final String name;
  final String? color;
}

class BusRegistrationController extends ChangeNotifier {
  BusRegistrationController({DriverApi? api}) : _api = api ?? DriverApi();

  final DriverApi _api;
  bool isLoading = false;
  String status = '';
  final List<DriverLineOption> lines = [];
  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
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
            return DriverLineOption(
              id: (row['id_linea'] as num?)?.toInt() ?? 0,
              name: (row['nombre_linea'] ?? '').toString(),
              color: row['color_linea']?.toString(),
            );
          }).where((line) => line.id > 0),
        );
      if (status.isEmpty) {
        status =
            lines.isEmpty ? 'No hay lineas disponibles.' : 'Lineas cargadas.';
      }
    } catch (error) {
      lines.clear();
      status = DriverApi.describeError(error,
          fallback: 'No se pudieron cargar lineas.');
    }
    _notify();
  }

  Future<bool> registerBus({
    required String plate,
    required String model,
    required int seats,
    required String internalNumber,
    required int lineId,
  }) async {
    isLoading = true;
    status = 'Registrando microbus...';
    _notify();
    try {
      await _api.dio.post('/buses',
          data: {
            'plate': plate,
            'model': model,
            'seats_count': seats,
            'internal_number': internalNumber,
            'current_line_id': lineId,
          },
          options: await _api.auth());
      status = 'Microbus registrado correctamente.';
      isLoading = false;
      _notify();
      return true;
    } catch (error) {
      status = DriverApi.describeError(error,
          fallback: 'No se pudo registrar el microbus.');
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
