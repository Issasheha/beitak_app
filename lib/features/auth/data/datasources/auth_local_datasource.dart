// lib/features/auth/data/datasources/auth_local_datasource.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_session_model.dart';

abstract class AuthLocalDataSource {
  /// حفظ جلسة المستخدم (token + user + guest flag ...)
  Future<void> cacheAuthSession(AuthSessionModel session);

  /// استرجاع الجلسة المحفوظة (إن وجدت)، وإلا ترجع null.
  Future<AuthSessionModel?> getCachedAuthSession();

  /// حذف الجلسة كاملة (تسجيل خروج).
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _sessionKey = 'auth_session';

  // مفاتيح للمنطق المركزي في AppRouter
  static const _isLoggedInKey = 'is_logged_in';
  static const _isGuestKey = 'is_guest';
  static const _seenOnboardingKey = 'seen_onboarding';

  @override
  Future<void> cacheAuthSession(AuthSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(session.toJson());

    final success = await prefs.setString(_sessionKey, jsonString);
    if (!success) {
      throw const CacheException('Failed to cache auth session');
    }

    // ✅ مهم جداً: نحافظ على نفس سلوك التطبيق السابق + منطق الضيف
    // أي جلسة (ضيف أو مستخدم حقيقي) نعتبره "داخل التطبيق"
    await prefs.setBool(_isLoggedInKey, true);
    // بما إن المستخدم دخل بعد الـ Onboarding، نضمن إنه ما يرجع لها
    await prefs.setBool(_seenOnboardingKey, true);
    // نحدد إذا كان ضيف أو لا بناءً على الـ session
    await prefs.setBool(_isGuestKey, session.isGuest);
  }

  @override
  Future<AuthSessionModel?> getCachedAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);

    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return AuthSessionModel.fromJson(jsonMap);
    } catch (_) {
      throw const CacheException('Failed to parse cached auth session');
    }
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);

    // تسجيل خروج: مش مسجّل دخول، ومش ضيف
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setBool(_isGuestKey, false);
    // ما بنرجّع الـ onboarding، نخلي seen_onboarding زي ما هو (غالباً true)
  }
}
