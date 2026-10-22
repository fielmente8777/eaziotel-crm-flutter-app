import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String ownerTokenKey = 'owner_access_token';
  static const String ownerRefreshTokenKey = 'owner_refresh_token';
  static const String ownerHotelKey = 'owner_selected_hotel_id';

  static Future<String?> getOwnerAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ownerTokenKey);
  }

  /// Keep the original owner session while APIs use the selected client token.
  /// Repeated switches must never replace the original owner credentials.
  static Future<void> enterClient(String token, String hotelId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(ownerTokenKey)) {
      final ownerToken = prefs.getString(accessTokenKey);
      if (ownerToken == null || ownerToken.isEmpty) {
        throw StateError('Owner session is missing');
      }
      await prefs.setString(ownerTokenKey, ownerToken);
      final refresh = prefs.getString(refreshTokenKey);
      if (refresh != null) await prefs.setString(ownerRefreshTokenKey, refresh);
      final hotel = prefs.getString('selected_hotel_id');
      if (hotel != null) await prefs.setString(ownerHotelKey, hotel);
    }
    // The owner's refresh token cannot refresh a client's access token.
    await prefs.remove(refreshTokenKey);
    await prefs.setString(accessTokenKey, token);
    if (hotelId.isEmpty) {
      await prefs.remove('selected_hotel_id');
    } else {
      await prefs.setString('selected_hotel_id', hotelId);
    }
  }

  static Future<bool> restoreOwner() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ownerTokenKey);
    if (token == null || token.isEmpty) return false;
    await prefs.setString(accessTokenKey, token);
    for (final pair in [
      (ownerRefreshTokenKey, refreshTokenKey),
      (ownerHotelKey, 'selected_hotel_id'),
    ]) {
      final value = prefs.getString(pair.$1);
      if (value == null) {
        await prefs.remove(pair.$2);
      } else {
        await prefs.setString(pair.$2, value);
      }
      await prefs.remove(pair.$1);
    }
    await prefs.remove(ownerTokenKey);
    return true;
  }

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(accessTokenKey, accessToken);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(refreshTokenKey, refreshToken);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(refreshTokenKey);
  }

  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();

    return token != null && token.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(ownerTokenKey);
    await prefs.remove(ownerRefreshTokenKey);
    await prefs.remove(ownerHotelKey);
  }
}
