// lib/core/cache/session_store.dart
// ✅ P0: Updated to use SecureTokenStorage (not SharedPreferences) for session data

import 'package:beitak_app/core/cache/prefs_cache.dart';
import 'package:beitak_app/core/security/secure_token_storage.dart';

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
/// 
/// ✅ P0: Now uses SecureTokenStorage for session data (not SharedPreferences)
class SessionStore {
  /// ✅ Read session from secure storage (not stale SharedPreferences)
  static Future<SessionSnapshot> read() async {
    // Use PrefsCache for flags (pre-warmed, fast)
    final isLoggedIn = PrefsCache.isLoggedIn;
    final isGuest = PrefsCache.isGuest;

    String? phone;
    String? fullName;

    try {
      // ✅ P0: Read from SecureTokenStorage (not SharedPreferences)
      final session = await SecureTokenStorage.getSession();

      if (session != null) {
        final user = session['user'];
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

    return SessionSnapshot(
      isLoggedIn: isLoggedIn,
      isGuest: isGuest,
      phone: phone,
      fullName: fullName,
    );
  }
}
