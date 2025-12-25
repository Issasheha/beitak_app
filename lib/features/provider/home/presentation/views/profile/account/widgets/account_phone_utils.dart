// lib/features/provider/home/presentation/views/profile/account/widgets/account_phone_utils.dart
class AccountPhoneUtils {
  static String? normalizeJordanPhone(String input) {
    var s = input.trim().replaceAll(' ', '').replaceAll('-', '');
    if (s.startsWith('+')) s = s.substring(1);

    // 07xxxxxxxx -> 9627xxxxxxxx
    if (s.startsWith('07') && s.length == 10) {
      s = '962${s.substring(1)}';
    }

    final ok = RegExp(r'^9627[789]\d{7}$').hasMatch(s);
    if (!ok) return null;
    return s;
  }
}
