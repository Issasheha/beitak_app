// lib/core/cache/prefs_cache.dart
// ✅ P1: Pre-warmed SharedPreferences cache to avoid blocking I/O in routes

import 'package:shared_preferences/shared_preferences.dart';

/// Global cached SharedPreferences instance.
/// Must be initialized in main() before runApp().
class PrefsCache {
  PrefsCache._();

  static SharedPreferences? _instance;

  /// Initialize the cache. Call this in main() before runApp().
  static Future<void> init() async {
    _instance ??= await SharedPreferences.getInstance();
  }

  /// Get the cached instance. Throws if not initialized.
  static SharedPreferences get instance {
    if (_instance == null) {
      throw StateError(
        'PrefsCache not initialized. Call PrefsCache.init() in main() before runApp().',
      );
    }
    return _instance!;
  }

  /// Safe getter that returns null if not initialized (for fallback scenarios).
  static SharedPreferences? get instanceOrNull => _instance;

  // ========================
  // Convenience Getters (UI Flags)
  // ========================

  static bool get isLoggedIn => _instance?.getBool('is_logged_in') ?? false;
  static bool get isGuest => _instance?.getBool('is_guest') ?? false;
  static bool get seenSplash => _instance?.getBool('seen_splash') ?? false;
  static bool get seenOnboarding => _instance?.getBool('seen_onboarding') ?? false;
  static String? get userRole => _instance?.getString('user_role');

  // ========================
  // Convenience Setters
  // ========================

  static Future<void> setSeenSplash(bool value) async {
    await _instance?.setBool('seen_splash', value);
  }

  static Future<void> setSeenOnboarding(bool value) async {
    await _instance?.setBool('seen_onboarding', value);
  }

  static Future<void> setLoggedIn(bool value) async {
    await _instance?.setBool('is_logged_in', value);
  }

  static Future<void> setGuest(bool value) async {
    await _instance?.setBool('is_guest', value);
  }

  static Future<void> setUserRole(String? role) async {
    if (role == null || role.isEmpty) {
      await _instance?.remove('user_role');
    } else {
      await _instance?.setString('user_role', role);
    }
  }

  /// Clear all session-related flags (for logout).
  static Future<void> clearSessionFlags() async {
    await _instance?.setBool('is_logged_in', false);
    await _instance?.setBool('is_guest', false);
    await _instance?.remove('user_role');
    // Keep seen_splash and seen_onboarding
  }
}
