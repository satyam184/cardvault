import 'user_model.dart';

class AuthResponseModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponseModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] ?? '',
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class RefreshTokenResponse {
  final bool success;
  final String accessToken;

  RefreshTokenResponse({
    required this.success,
    required this.accessToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] ?? false,
      accessToken: json['accessToken'],
    );
  }
}
