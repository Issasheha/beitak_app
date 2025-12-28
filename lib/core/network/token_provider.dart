// lib/core/network/token_provider.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider {
  TokenProvider._();

  static const String _sessionKey = 'auth_session';

  // نفس مفاتيح AuthLocalDataSourceImpl عشان ما يصير لخبطة
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isGuestKey = 'is_guest';
  static const String _userRoleKey = 'user_role';

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      if (sessionJson == null || sessionJson.trim().isEmpty) return null;

      final decoded = jsonDecode(sessionJson);
      if (decoded is! Map) return null;

      final token = (decoded['token'] ?? '').toString().trim();
      if (token.isEmpty) return null;

      return token; // خام بدون Bearer
    } catch (_) {
      return null;
    }
  }

  /// ✅ تحديث token داخل auth_session بدون تخريب user/flags
  static Future<void> saveToken(String token) async {
    final t = token.trim();
    if (t.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> sessionMap = <String, dynamic>{};

    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null && sessionJson.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(sessionJson);
        if (decoded is Map) {
          sessionMap = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        sessionMap = <String, dynamic>{};
      }
    }

    sessionMap['token'] = t;

    // (اختياري) نخلي is_guest false داخل الجلسة إذا موجود
    sessionMap['is_guest'] = false;

    await prefs.setString(_sessionKey, jsonEncode(sessionMap));

    // ✅ حدّث flags الأساسية حتى ما يصير تناقض
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setBool(_isGuestKey, false);

    // user_role خلّيه زي ما هو (لا نمسّه هنا)
  }

  /// ✅ مسح الجلسة (عند فشل refresh مثلاً)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_sessionKey);

    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setBool(_isGuestKey, false);
    await prefs.remove(_userRoleKey);
  }
}
