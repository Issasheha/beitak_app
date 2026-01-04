// lib/core/network/token_provider.dart
// P0: Now uses SecureTokenStorage for encrypted token storage

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/secure_token_storage.dart';

/// Token provider for the ApiClient interceptor.
/// Uses secure storage for token, but still uses SharedPreferences for UI flags.
class TokenProvider {
  TokenProvider._();

  // Cache SharedPreferences instance to avoid repeated async calls
  static SharedPreferences? _prefsCache;

  // Keys for non-sensitive flags (OK in SharedPreferences)
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isGuestKey = 'is_guest';
  static const String _userRoleKey = 'user_role';

  /// Get cached SharedPreferences instance
  static Future<SharedPreferences> get _prefs async {
    return _prefsCache ??= await SharedPreferences.getInstance();
  }

  /// Get token from secure storage
  static Future<String?> getToken() async {
    try {
      return await SecureTokenStorage.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TokenProvider.getToken error: $e');
      }
      return null;
    }
  }

  /// Save token to secure storage and update flags
  static Future<void> saveToken(String token) async {
    final t = token.trim();
    if (t.isEmpty) return;

    try {
      // Save token securely
      await SecureTokenStorage.updateSessionToken(t);

      // Update UI flags in SharedPreferences
      final prefs = await _prefs;
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_isGuestKey, false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TokenProvider.saveToken error: $e');
      }
    }
  }

  /// Clear token and session (on logout or refresh failure)
  static Future<void> clearToken() async {
    try {
      // Clear secure storage
      await SecureTokenStorage.clearSession();

      // Clear UI flags
      final prefs = await _prefs;
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.setBool(_isGuestKey, false);
      await prefs.remove(_userRoleKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TokenProvider.clearToken error: $e');
      }
    }
  }

  /// Check if user has valid token
  static Future<bool> hasValidToken() async {
    return await SecureTokenStorage.hasToken();
  }
}
