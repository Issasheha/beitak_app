class SearchNormalizer {
  SearchNormalizer._();

  static final Map<String, String> _arToEn = {
    // Plumbing
    'سباكة': 'plumbing',
    'سباك': 'plumber',
    'مواسرجي': 'plumber',
    'مواسير': 'plumbing',

    // Cleaning
    'تنظيف': 'cleaning',
    'نظافة': 'cleaning',
    'تنظيف المنازل': 'house cleaning',

    // Electrical
    'كهرباء': 'electric',
    'كهربائي': 'electrician',

    // Maintenance / repair
    'صيانة': 'maintenance',
    'صيانه': 'maintenance',
    'تصليح': 'repair',
    'إصلاح': 'repair',

    // Design / drawing
    'رسم': 'design',
    'تصميم': 'design',
    'ديزاين': 'design',
  };

  static bool _containsArabic(String s) {
    // Arabic Unicode blocks (basic heuristic)
    return RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(s);
  }

  /// returns query to send to API.
  /// - if Arabic keyword matched -> returns English keyword.
  /// - else returns original.
  static String normalizeForApi(String input) {
    final q = input.trim();
    if (q.isEmpty) return q;

    // exact match
    final exact = _arToEn[q];
    if (exact != null) return exact;

    // keyword contains (e.g. "تنظيف شقة")
    if (_containsArabic(q)) {
      for (final entry in _arToEn.entries) {
        if (q.contains(entry.key)) return entry.value;
      }
    }
    return q;
  }

  static bool isArabicQuery(String input) => _containsArabic(input.trim());
}
