// lib/core/security/secure_token_storage.dart
// P0: Secure token storage using flutter_secure_storage
// Replaces SharedPreferences for sensitive auth data

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/network_constants.dart';

/// Secure storage wrapper for authentication tokens and sensitive session data.
/// Uses encrypted storage (Keychain on iOS, EncryptedSharedPreferences on Android).
class SecureTokenStorage {
  SecureTokenStorage._();

  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'auth_session';

  // ✅ P2: Use centralized constant for token expiry buffer
  static int get _expiryBufferMinutes => NetworkConstants.tokenExpiryBufferMinutes;

  /// Android: Uses EncryptedSharedPreferences
  /// iOS: Uses Keychain with first_unlock accessibility
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true, // Reset if decryption fails (e.g., after factory reset)
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      accountName: 'beitak_auth',
    ),
  );

  // ========================
  // Token Operations
  // ========================

  /// Get the stored auth token (raw, without Bearer prefix)
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.trim().isEmpty) return null;
      return token.trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.getToken error: $e');
      }
      return null;
    }
  }

  /// ✅ P0: Get token only if it's still valid (not expired or near-expiry)
  static Future<String?> getValidToken() async {
    try {
      final session = await getSession();
      if (session == null) return null;

      final token = session['token']?.toString().trim();
      if (token == null || token.isEmpty) return null;

      // Check expiry
      final expiresAtStr = session['expires_at']?.toString();
      if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
        final expiresAt = DateTime.tryParse(expiresAtStr);
        if (expiresAt != null) {
          final buffer = Duration(minutes: _expiryBufferMinutes);
          if (DateTime.now().isAfter(expiresAt.subtract(buffer))) {
            if (kDebugMode) {
              debugPrint('SecureTokenStorage: Token expired or expiring soon');
            }
            return null; // Token expired or will expire soon
          }
        }
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.getValidToken error: $e');
      }
      return null;
    }
  }

  /// ✅ P0: Check if token is expired or will expire within buffer time
  static Future<bool> isTokenExpired() async {
    try {
      final session = await getSession();
      if (session == null) return true;

      final expiresAtStr = session['expires_at']?.toString();
      if (expiresAtStr == null || expiresAtStr.isEmpty) {
        // No expiry info - assume valid but log warning
        if (kDebugMode) {
          debugPrint('SecureTokenStorage: No expires_at in session');
        }
        return false;
      }

      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null) return false;

      final buffer = Duration(minutes: _expiryBufferMinutes);
      return DateTime.now().isAfter(expiresAt.subtract(buffer));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.isTokenExpired error: $e');
      }
      return true; // Assume expired on error
    }
  }

  /// ✅ P0: Check if token will expire within specified minutes
  static Future<bool> isTokenExpiringSoon({int withinMinutes = 10}) async {
    try {
      final session = await getSession();
      if (session == null) return true;

      final expiresAtStr = session['expires_at']?.toString();
      if (expiresAtStr == null || expiresAtStr.isEmpty) return false;

      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null) return false;

      return DateTime.now().isAfter(expiresAt.subtract(Duration(minutes: withinMinutes)));
    } catch (e) {
      return true;
    }
  }

  /// Save the auth token securely
  static Future<void> saveToken(String token) async {
    final t = token.trim();
    if (t.isEmpty) return;

    try {
      await _storage.write(key: _tokenKey, value: t);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.saveToken error: $e');
      }
    }
  }

  /// Clear the stored token
  static Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.clearToken error: $e');
      }
    }
  }

  // ========================
  // Session Operations (for user data)
  // ========================

  /// Get the stored session JSON
  static Future<Map<String, dynamic>?> getSession() async {
    try {
      final sessionJson = await _storage.read(key: _sessionKey);
      if (sessionJson == null || sessionJson.trim().isEmpty) return null;

      final decoded = jsonDecode(sessionJson);
      if (decoded is! Map) return null;

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.getSession error: $e');
      }
      return null;
    }
  }

  /// ✅ P0: Get session only if token is valid
  static Future<Map<String, dynamic>?> getValidSession() async {
    try {
      final session = await getSession();
      if (session == null) return null;

      // Check if it's a guest session (invalid for auth)
      final isGuest = session['is_guest'] == true;
      if (isGuest) return null;

      // Check token exists
      final token = session['token']?.toString().trim();
      if (token == null || token.isEmpty) return null;

      // Check expiry
      if (await isTokenExpired()) {
        if (kDebugMode) {
          debugPrint('SecureTokenStorage: Session expired, returning null');
        }
        return null;
      }

      return session;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.getValidSession error: $e');
      }
      return null;
    }
  }

  /// Save session data securely
  static Future<void> saveSession(Map<String, dynamic> session) async {
    try {
      final json = jsonEncode(session);
      await _storage.write(key: _sessionKey, value: json);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.saveSession error: $e');
      }
    }
  }

  /// Update session with new token and expiry while preserving user data
  static Future<void> updateSessionToken(String token, {DateTime? expiresAt}) async {
    final t = token.trim();
    if (t.isEmpty) return;

    try {
      // Save standalone token
      await saveToken(t);

      // Update session if exists
      final session = await getSession();
      if (session != null) {
        session['token'] = t;
        session['is_guest'] = false;
        if (expiresAt != null) {
          session['expires_at'] = expiresAt.toIso8601String();
        }
        await saveSession(session);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.updateSessionToken error: $e');
      }
    }
  }

  /// Clear all stored session data
  static Future<void> clearSession() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _sessionKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.clearSession error: $e');
      }
    }
  }

  /// Clear all data (for logout or error recovery)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.clearAll error: $e');
      }
    }
  }

  /// Check if we have a valid token stored
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// ✅ P0: Check if we have a valid (non-expired) token
  static Future<bool> hasValidToken() async {
    final token = await getValidToken();
    return token != null && token.isNotEmpty;
  }

  // ========================
  // ✅ P0: Migration & Cleanup
  // ========================

  /// Clean up any stale/legacy session data.
  /// Call this during app startup to ensure clean state.
  static Future<void> migrateAndCleanup() async {
    try {
      final session = await getSession();
      if (session == null) return;

      bool needsCleanup = false;

      // Check for guest sessions that shouldn't persist
      if (session['is_guest'] == true) {
        if (kDebugMode) {
          debugPrint('SecureTokenStorage: Clearing stale guest session');
        }
        needsCleanup = true;
      }

      // Check for empty/null tokens
      final token = session['token']?.toString().trim();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('SecureTokenStorage: Clearing session with empty token');
        }
        needsCleanup = true;
      }

      // Check for expired sessions
      if (await isTokenExpired()) {
        if (kDebugMode) {
          debugPrint('SecureTokenStorage: Clearing expired session');
        }
        needsCleanup = true;
      }

      if (needsCleanup) {
        await clearSession();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SecureTokenStorage.migrateAndCleanup error: $e');
      }
      // On error, clear everything to ensure clean state
      await clearSession();
    }
  }
}
