import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final FlutterSecureStorage _storage;

  TokenStorageService(this._storage);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveRememberMe({
    required bool rememberMe,
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _rememberMeKey, value: rememberMe.toString());
    if (rememberMe) {
      await _storage.write(key: _savedEmailKey, value: email);
      await _storage.write(key: _savedPasswordKey, value: password);
    } else {
      await _storage.delete(key: _savedEmailKey);
      await _storage.delete(key: _savedPasswordKey);
    }
  }

  Future<bool> getRememberMeStatus() async {
    final value = await _storage.read(key: _rememberMeKey);
    // By default remember me is selected, so if there is no stored value, return true.
    if (value == null) return true;
    return value == 'true';
  }

  Future<String?> getSavedEmail() async {
    return await _storage.read(key: _savedEmailKey);
  }

  Future<String?> getSavedPassword() async {
    return await _storage.read(key: _savedPasswordKey);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
