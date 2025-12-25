// lib/core/network/token_provider.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider {
  TokenProvider._();

  static const String _sessionKey = 'auth_session';

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      if (sessionJson == null || sessionJson.trim().isEmpty) return null;

      final decoded = jsonDecode(sessionJson);
      if (decoded is! Map) return null;

      final token = (decoded['token'] ?? '').toString().trim();
      if (token.isEmpty) return null;

      // token خام (بدون Bearer)
      return token;
    } catch (_) {
      return null;
    }
  }
}
