import 'package:dio/dio.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://sig.leonardoserrate.xyz/api/v1',
);

class ApiConfig {
  static const backendOrigin = 'http://sig.leonardoserrate.xyz';
  static const defaultBaseUrl = '$backendOrigin/api/v1';
  static const baseUrl = apiBaseUrl;

  static const normalTimeout = Duration(seconds: 30);

  static BaseOptions baseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: normalTimeout,
      sendTimeout: normalTimeout,
      receiveTimeout: normalTimeout,
      headers: const {'Accept': 'application/json'},
    );
  }
}
