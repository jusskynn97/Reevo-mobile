import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _fcmTokenKey = 'fcm_token';

  final SharedPreferences _prefs;

  TokenStorageService(this._prefs);

  // Save tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await Future.wait([
      _prefs.setString(_accessTokenKey, accessToken),
      _prefs.setString(_refreshTokenKey, refreshToken),
      _prefs.setString(_userIdKey, userId),
    ]);
  }

  // Get access token
  String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  // Get user ID
  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  // Save FCM token
  Future<void> saveFcmToken(String fcmToken) async {
    await _prefs.setString(_fcmTokenKey, fcmToken);
  }

  // Get FCM token
  String? getFcmToken() {
    return _prefs.getString(_fcmTokenKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getAccessToken() != null && getRefreshToken() != null;
  }

  // Clear all tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _prefs.remove(_accessTokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_fcmTokenKey),
    ]);
  }

  // Update access token (for refresh token flow)
  Future<void> updateAccessToken(String newAccessToken) async {
    await _prefs.setString(_accessTokenKey, newAccessToken);
  }

  // Update refresh token
  Future<void> updateRefreshToken(String newRefreshToken) async {
    await _prefs.setString(_refreshTokenKey, newRefreshToken);
  }
}
