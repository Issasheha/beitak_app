// lib/core/cache/session_store.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionSnapshot {
  final bool isLoggedIn;
  final bool isGuest;
  final String? phone;
  final String? fullName;

  const SessionSnapshot({
    required this.isLoggedIn,
    required this.isGuest,
    this.phone,
    this.fullName,
  });
}

/// مصدر واحد للحقيقة بخصوص حالة المستخدم الحالية:
/// - هل هو مسجّل؟
/// - هل هو ضيف؟
/// - ما هو اسمه؟
/// - ما هو رقم هاتفه؟
class SessionStore {
  static const String _sessionKey = 'auth_session';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isGuestKey = 'is_guest';

  static Future<SessionSnapshot> read() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final isGuest = prefs.getBool(_isGuestKey) ?? false;

    String? phone;
    String? fullName;

    final rawSession = prefs.getString(_sessionKey);
    if (rawSession != null) {
      try {
        final decoded = jsonDecode(rawSession);

        if (decoded is Map) {
          final user = decoded['user'];
          if (user is Map) {
            final firstName = user['first_name']?.toString() ?? '';
            final lastName = user['last_name']?.toString() ?? '';
            final combined = '$firstName $lastName'.trim();
            if (combined.isNotEmpty) {
              fullName = combined;
            }

            final p = user['phone']?.toString();
            if (p != null && p.trim().isNotEmpty) {
              phone = p.trim();
            }
          }
        }
      } catch (_) {
        // لو فشل الـ decode ما بنكسر التطبيق
      }
    }

    return SessionSnapshot(
      isLoggedIn: isLoggedIn,
      isGuest: isGuest,
      phone: phone,
      fullName: fullName,
    );
  }
}
