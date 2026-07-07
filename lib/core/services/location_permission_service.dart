import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationResult {
  const DriverLocationResult._({
    this.position,
    this.message,
  });

  factory DriverLocationResult.ready(Position position) {
    return DriverLocationResult._(position: position);
  }

  factory DriverLocationResult.blocked(String message) {
    return DriverLocationResult._(message: message);
  }

  final Position? position;
  final String? message;

  bool get hasPosition => position != null;
}

class DriverLocationPermissionService {
  Future<DriverLocationResult> currentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return DriverLocationResult.blocked(
          'Activa la ubicacion/GPS del dispositivo para usar esta funcion.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return DriverLocationResult.blocked('Permiso de ubicacion denegado.');
      }

      if (permission == LocationPermission.deniedForever) {
        return DriverLocationResult.blocked(
          'Permiso de ubicacion denegado permanentemente. Activa el permiso desde Configuracion.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      return DriverLocationResult.ready(position);
    } on LocationServiceDisabledException {
      return DriverLocationResult.blocked(
        'Activa la ubicacion/GPS del dispositivo para usar esta funcion.',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Location] No se pudo obtener la ubicacion: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      return DriverLocationResult.blocked(
        'No se pudo obtener la ubicacion del dispositivo.',
      );
    }
  }
}
