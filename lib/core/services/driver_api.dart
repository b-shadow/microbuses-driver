import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverApi {
  DriverApi() : dio = Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:8000/api/v1')));

  final Dio dio;

  Future<String?> token() async => (await SharedPreferences.getInstance()).getString('driver_access_token');

  Future<Options> auth() async {
    final t = await token();
    return Options(headers: {'Authorization': 'Bearer $t'});
  }
}
