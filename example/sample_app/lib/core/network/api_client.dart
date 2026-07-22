import 'package:dio/dio.dart';
import '../../app/config/env_config.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
      ),
    );
    if (EnvConfig.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }
  }

  late final Dio _dio;
  Dio get dio => _dio;
}
