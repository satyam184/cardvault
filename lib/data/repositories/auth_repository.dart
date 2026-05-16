import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/token_storage_service.dart';

class AuthRepository {
  final DioClient _dioClient;
  final TokenStorageService _tokenService;

  AuthRepository(this._dioClient, this._tokenService);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      
      // Save tokens
      await _tokenService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      
      // Save tokens
      await _tokenService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _tokenService.clearAll();
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'An error occurred';
    }
    return 'Network error. Please check your connection.';
  }
}
