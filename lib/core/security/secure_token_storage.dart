// lib/core/security/secure_token_storage.dart
// P0: Secure token storage using flutter_secure_storage
// Replaces SharedPreferences for sensitive auth data

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for authentication tokens and sensitive session data.
/// Uses encrypted storage (Keychain on iOS, EncryptedSharedPreferences on Android).
class SecureTokenStorage {
  SecureTokenStorage._();

  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'auth_session';

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

  /// Update session with new token while preserving user data
  static Future<void> updateSessionToken(String token) async {
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
}
