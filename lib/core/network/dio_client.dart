import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../services/token_storage_service.dart';

class DioClient {
  final String baseUrl;
  late Dio _dio;

  DioClient({required this.baseUrl, required TokenStorageService tokenService}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(tokenService, _dio));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
