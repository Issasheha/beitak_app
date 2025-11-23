// lib/features/provider/home/presentation/view/profile/viewmodels/provider_profile_viewmodel.dart

/// ViewModel لملف مزوّد الخدمة.
///
/// حالياً:
/// - يحتوي بيانات وهمية (dummy) لعرض الـ UI.
/// - يمكن تحديث بعض الحقول في الذاكرة فقط.
/// لاحقاً تربطه مع API / Repository حقيقي.
class ProviderProfileViewModel {
  // بيانات العمل
  String businessName;
  String ownerName;
  String category;
  String description;

  // معلومات التواصل
  String email;
  String phone;
  String location;

  // إحصائيات
  double rating;
  int reviewsCount;
  int totalBookings;
  int responseRate; // %
  Duration avgResponseTime; // متوسط وقت الرد
  DateTime memberSince;

  // تفضيلات الإشعارات
  bool notifyNewBookings;
  bool notifyBookingUpdates;
  bool notifyMessages;
  bool notifyReviews;

  ProviderProfileViewModel({
    this.businessName = 'خدمات كلين برو',
    this.ownerName = 'أحمد المنصوري',
    this.category = 'تنظيف المنازل',
    this.description =
        'شركة تنظيف محترفة مع أكثر من 10 سنوات من الخبرة في تنظيف المنازل والمكاتب، '
        'نقدم خدمات عالية الجودة بفريق موثوق ومدرَّب.',
    this.email = 'ahmed@cleanpro.ae',
    this.phone = '+971 50 987 6543',
    this.location = 'دبي، الإمارات العربية المتحدة',
    this.rating = 4.9,
    this.reviewsCount = 156,
    this.totalBookings = 234,
    this.responseRate = 98,
    Duration? avgResponseTime,
    DateTime? memberSince,
    this.notifyNewBookings = true,
    this.notifyBookingUpdates = true,
    this.notifyMessages = true,
    this.notifyReviews = true,
  })  : avgResponseTime = avgResponseTime ?? const Duration(hours: 2),
        memberSince = memberSince ?? DateTime(2024, 11, 1);

  /// الأحرف الأولى من اسم النشاط (مثلاً: خ ب من "خدمات برو")
  String get initials {
    final parts = businessName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2) : s;
    }
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final second = parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$second';
  }

  /// نص "مزود خدمات منذ ..."
  String get memberSinceLabel {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final monthName =
        memberSince.month >= 1 && memberSince.month <= 12
            ? months[memberSince.month]
            : '';
    final year = memberSince.year.toString();
    return 'مزود خدمات منذ $monthName $year';
  }

  /// متوسط وقت الرد كنص عربي
  String get avgResponseTimeLabel {
    if (avgResponseTime.inHours >= 1) {
      return '${avgResponseTime.inHours} ساعة';
    }
    final minutes = avgResponseTime.inMinutes;
    if (minutes <= 0) return 'أقل من دقيقة';
    return '$minutes دقيقة';
  }

  void updateNotifications({
    bool? notifyNewBookings,
    bool? notifyBookingUpdates,
    bool? notifyMessages,
    bool? notifyReviews,
  }) {
    if (notifyNewBookings != null) {
      this.notifyNewBookings = notifyNewBookings;
    }
    if (notifyBookingUpdates != null) {
      this.notifyBookingUpdates = notifyBookingUpdates;
    }
    if (notifyMessages != null) {
      this.notifyMessages = notifyMessages;
    }
    if (notifyReviews != null) {
      this.notifyReviews = notifyReviews;
    }
  }

  void updateBusinessInfo({
    String? businessName,
    String? ownerName,
    String? category,
    String? description,
  }) {
    if (businessName != null) this.businessName = businessName;
    if (ownerName != null) this.ownerName = ownerName;
    if (category != null) this.category = category;
    if (description != null) this.description = description;
  }

  void updateContactInfo({
    String? email,
    String? phone,
    String? location,
  }) {
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (location != null) this.location = location;
  }
}
