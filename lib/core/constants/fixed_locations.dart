class FixedLocations {
  FixedLocations._();

  static String _normKey(String s) {
    var x = s.trim().toLowerCase();
    x = x.replaceAll(RegExp(r'\s+'), '_');
    x = x.replaceAll('-', '_');
    x = x.replaceAll(RegExp(r'_+'), '_');
    return x;
  }

  /// يحول "amman - abdoun" => "عمان - عبدون"
  /// إذا map موجودة (من API) بتكون النتيجة 100% عربي
  static String labelArFromAny(String raw, {Map<String, String>? map}) {
    final s = raw.trim();
    if (s.isEmpty) return '—';

    final parts = s
        .split(RegExp(r'\s*[-–—/|]\s*'))
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final tokens = parts.isEmpty ? [s] : parts;

    final out = <String>[];
    for (final t in tokens) {
      final k = _normKey(t);

      final v = map != null ? map[k] : null;

      // إذا لقينا ترجمة من السيرفر نستخدمها
      if (v != null && v.trim().isNotEmpty) {
        out.add(v.trim());
      } else {
        // fallback: نخليها كما هي (بس نظيفة)
        out.add(t.trim());
      }
    }

    final joined = out.where((e) => e.trim().isNotEmpty).join(' - ').trim();
    return joined.isEmpty ? '—' : joined;
  }
}
