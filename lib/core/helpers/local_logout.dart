import 'package:shared_preferences/shared_preferences.dart';

class LocalLogout {
  LocalLogout._();

  /// يمسح مفاتيح الجلسة فقط (Token/User/Flags) ويحافظ على أي settings.
  static Future<void> clearSessionOnly() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ هذه مفاتيح شائعة. إذا عندك keys مختلفة في auth_local_datasource
    // فقط عدّل القائمة لتطابق مشروعك.
    const keys = <String>[
  'token', 'auth_token', 'access_token',
  'session', 'auth_session',
  'user', 'auth_user',
  'is_guest', 'is_new_user', 'expires_at',
  'is_logged_in', 'user_role',
];


    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
