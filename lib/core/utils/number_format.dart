class NumberFormat {
  NumberFormat._();

  /// يعزل النص الرقمي داخل RTL حتى يظل ترتيبه صحيح (مثل #BKM123 أو 14:00 أو 500.00)
  static String ltrIsolate(String s) => '\u2066$s\u2069'; // LRI ... PDI

  /// إذا النص فيه أرقام/رموز، خلّيه LTR مع عزل
  static String smart(String s) {
    final v = s.trim();
    if (v.isEmpty) return v;

    final hasDigit = RegExp(r'\d').hasMatch(v);
    if (!hasDigit) return v;

    return ltrIsolate(v);
  }

  /// رقم مع كسور (ويزيل .00 إذا كان عدد صحيح)
  static String money(num value) {
    final isInt = value == value.roundToDouble();
    final txt = isInt ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return ltrIsolate(txt);
  }
}
