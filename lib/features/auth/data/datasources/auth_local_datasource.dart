// lib/features/auth/data/datasources/auth_local_datasource.dart
// P0: Updated to use SecureTokenStorage for token, PrefsCache for flags

import 'package:flutter/foundation.dart';

import '../../../../core/cache/prefs_cache.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/security/secure_token_storage.dart';
import '../models/auth_session_model.dart';

abstract class AuthLocalDataSource {
  /// حفظ جلسة المستخدم (token + user + guest flag ...)
  Future<void> cacheAuthSession(AuthSessionModel session);

  /// استرجاع الجلسة المحفوظة (إن وجدت)، وإلا ترجع null.
  Future<AuthSessionModel?> getCachedAuthSession();

  /// حذف الجلسة كاملة (تسجيل خروج).
  Future<void> clearSession();

  /// ✅ تحديث بيانات المستخدم داخل الجلسة المخزنة (بدون ما نخرب التوكن)
  Future<void> updateCachedUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // ✅ P1: Use PrefsCache (pre-warmed in main.dart) instead of getInstance()

  // مفاتيح للمنطق المركزي في AppRouter (non-sensitive, OK in SharedPreferences)
  static const _isLoggedInKey = 'is_logged_in';
  static const _isGuestKey = 'is_guest';
  static const _seenOnboardingKey = 'seen_onboarding';
  static const _userRoleKey = 'user_role';

  @override
  Future<void> cacheAuthSession(AuthSessionModel session) async {
    final prefs = PrefsCache.instance;

    // ✅ تنظيف التوكن
    final raw = (session.token ?? '').trim();
    final clean = raw.toLowerCase().startsWith('bearer ')
        ? raw.substring(7).trim()
        : raw;
    final hasToken = clean.isNotEmpty;

    // ✅ مهم: الضيف لا يُخزَّن نهائيًا (جلسة مؤقتة داخل runtime فقط)
    if (!hasToken) {
      // Clear secure storage as well
      await SecureTokenStorage.clearSession();

      // اعتبرهغير مسجّل دخول عند إعادة فتح التطبيق
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.setBool(_isGuestKey, false);

      // onboarding نتركه true بعد أول مرة
      await prefs.setBool(_seenOnboardingKey, true);

      await prefs.remove(_userRoleKey);
      return;
    }

    // ✅ مستخدم حقيقي فقط
    final fixedSession = AuthSessionModel(
      token: clean,
      user: session.user,
      isGuest: false,
      isNewUser: session.isNewUser,
      expiresAt: session.expiresAt,
    );

    // ✅ P0: Store token securely (NOT in SharedPreferences)
    await SecureTokenStorage.saveToken(clean);

    // Store session (with user info) securely
    await SecureTokenStorage.saveSession(fixedSession.toJson());

    // Update UI flags in SharedPreferences (non-sensitive)
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setBool(_seenOnboardingKey, true);
    await prefs.setBool(_isGuestKey, false);

    final role = fixedSession.user?.role;
    if (role != null && role.isNotEmpty) {
      await prefs.setString(_userRoleKey, role);
    } else {
      await prefs.remove(_userRoleKey);
    }
  }

  @override
  Future<AuthSessionModel?> getCachedAuthSession() async {
    final prefs = PrefsCache.instance;

    try {
      // ✅ P0: Get session from secure storage
      final sessionMap = await SecureTokenStorage.getSession();

      if (sessionMap == null) return null;

      final session = AuthSessionModel.fromJson(sessionMap);

      // ✅ Migration + Safety:
      // لو لأي سبب session طلعت Guest (token فاضي) → اعتبرها null وامسحها.
      if (session.isGuest || session.token == null || session.token!.isEmpty) {
        await SecureTokenStorage.clearSession();
        await prefs.setBool(_isLoggedInKey, false);
        await prefs.setBool(_isGuestKey, false);
        await prefs.remove(_userRoleKey);
        return null;
      }

      return session;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getCachedAuthSession error: $e');
      }
      throw const CacheException('Failed to parse cached auth session');
    }
  }

  @override
  Future<void> updateCachedUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
  }) async {
    final session = await getCachedAuthSession();
    if (session == null) return;

    final currentUser = session.user;
    if (session.isGuest || currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      email: email ?? currentUser.email,
      phone: phone ?? currentUser.phone,
      role: role ?? currentUser.role,
    );

    final updatedSession = session.copyWith(user: updatedUser);

    // ✅ يعيد تخزين session كمستخدم حقيقي فقط
    await cacheAuthSession(updatedSession);
  }

  @override
  Future<void> clearSession() async {
    final prefs = PrefsCache.instance;
    
    // ✅ P0: Clear secure storage
    await SecureTokenStorage.clearSession();

    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setBool(_isGuestKey, false);

    // seen_onboarding نخليه زي ما هو

    await prefs.remove(_userRoleKey);
  }
}
