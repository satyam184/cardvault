import 'package:dio/dio.dart';
import '../services/token_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenService;
  final Dio _dio;

  AuthInterceptor(this._tokenService, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If error is 401, try to refresh token
    if (err.response?.statusCode == 401) {
      final refreshToken = await _tokenService.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final response = await _dio.post(
            '/api/auth/refresh-token',
            data: {'refreshToken': refreshToken},
            // Prevent infinite loop by not using this interceptor for refresh call
            options: Options(headers: {'no-auth': true}),
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            await _tokenService.saveAccessToken(newAccessToken);

            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // If refresh fails, clear tokens and let the app handle logout
          await _tokenService.clearAll();
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}
