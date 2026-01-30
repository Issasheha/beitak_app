// lib/core/network/token_provider.dart
// P0: Now uses SecureTokenStorage for encrypted token storage
// P1: Uses PrefsCache for non-blocking UI flag access

import 'package:flutter/foundation.dart';
import '../cache/prefs_cache.dart';
import '../security/secure_token_storage.dart';

/// Token provider for the ApiClient interceptor.
/// Uses secure storage for token, PrefsCache for UI flags.
class TokenProvider {
  TokenProvider._();

  /// ✅ P0: Get token only if valid (not expired or near-expiry)
  static Future<String?> getToken() async {
    try {
      return await SecureTokenStorage.getValidToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TokenProvider.getToken error: $e');
      }
      return null;
    }
  }

  /// Get token regardless of expiry (for refresh flow)
  static Future<String?> getRawToken() async {
    try {
      return await SecureTokenStorage.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TokenProvider.getRawToken error: $e');
      }
      return null;
    }
  }

  /// ✅ P0: Save token with expiry to secure storage and update flags
  static Future<void> saveToken(String token, {DateTime? expiresAt}) async {
    final t = token.trim();
    if (t.isEmpty) return;

    try {
      // Save token securely with expiry
      await SecureTokenStorage.updateSessionToken(t, expiresAt: expiresAt);

      // Update UI flags via PrefsCache (non-blocking)
      await PrefsCache.setLoggedIn(true);
      await PrefsCache.setGuest(false);
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

      // Clear UI flags via PrefsCache
      await PrefsCache.clearSessionFlags();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TokenProvider.clearToken error: $e');
      }
    }
  }

  /// Check if user has valid (non-expired) token
  static Future<bool> hasValidToken() async {
    return await SecureTokenStorage.hasValidToken();
  }

  /// ✅ P0: Check if token is expired or expiring soon
  static Future<bool> isTokenExpired() async {
    return await SecureTokenStorage.isTokenExpired();
  }
}
