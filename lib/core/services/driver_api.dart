import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class DriverApi {
  DriverApi() : dio = Dio(ApiConfig.baseOptions()) {
    _installDebugLogging();
  }

  final Dio dio;

  Future<String?> token() async =>
      (await SharedPreferences.getInstance()).getString('driver_access_token');

  Future<Options> auth({
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    final t = await token();
    return Options(
      headers: {'Authorization': 'Bearer $t'},
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  static String describeError(
    Object error, {
    String fallback = 'No se pudo completar la solicitud.',
  }) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseMessage = _responseMessage(error.response?.data);
      final parts = <String>[
        fallback,
        if (statusCode != null) 'Codigo HTTP $statusCode.',
        if (responseMessage != null) responseMessage,
        if (kDebugMode)
          'Debug: ${error.type.name}${error.message == null ? '' : ' - ${error.message}'}',
      ];
      return parts.join(' ');
    }

    if (kDebugMode) {
      return '$fallback Debug: $error';
    }
    return fallback;
  }

  void _installDebugLogging() {
    if (!kDebugMode) return;

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) =>
            debugPrint(_redactSensitiveLog(object.toString())),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final request = error.requestOptions;
          debugPrint('[DriverApi] ${request.method} ${request.uri}');
          debugPrint(
              '[DriverApi] statusCode: ${error.response?.statusCode ?? '-'}');
          debugPrint('[DriverApi] type: ${error.type.name}');
          debugPrint('[DriverApi] message: ${error.message ?? '-'}');
          debugPrint(
              '[DriverApi] responseBody: ${_redactData(error.response?.data)}');
          handler.next(error);
        },
      ),
    );
  }

  static String? _responseMessage(Object? data) {
    if (data == null) return null;
    if (data is String) {
      final trimmed = data.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (data is Map) {
      for (final key in const [
        'message',
        'detail',
        'error',
        'error_description',
        'error_code'
      ]) {
        final value = data[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      final errors = data['errors'];
      if (errors != null) return 'Errores: ${_redactData(errors)}';
    }
    return 'Respuesta: ${_redactData(data)}';
  }

  static Object? _redactData(Object? value) {
    if (value is Map) {
      return value.map(
        (key, nested) => MapEntry(
          key,
          _isSensitiveKey(key.toString()) ? '***' : _redactData(nested),
        ),
      );
    }
    if (value is Iterable) {
      return value.map(_redactData).toList();
    }
    return value;
  }

  static String _redactSensitiveLog(String value) {
    var redacted = value;
    for (final key in _sensitiveKeys) {
      redacted = redacted.replaceAllMapped(
        RegExp('("$key"\\s*:\\s*")([^"]*)(")', caseSensitive: false),
        (match) => '${match.group(1)}***${match.group(3)}',
      );
      redacted = redacted.replaceAllMapped(
        RegExp('($key\\s*[:=]\\s*)([^,}\\]\\n]+)', caseSensitive: false),
        (match) => '${match.group(1)}***',
      );
    }
    return redacted;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return _sensitiveKeys.any(normalized.contains);
  }

  static const _sensitiveKeys = [
    'authorization',
    'password',
    'contrasena',
    'access_token',
    'refresh_token',
    'token',
  ];
}
