// lib/features/provider/home/presentation/viewmodels/provider_home_viewmodel.dart

/// ViewModel مبسّط للوحة مزوّد الخدمة.
/// حالياً فيه بيانات وهمية (dummy) للـ UI:
/// - تحية حسب الوقت.
/// - إحصائيات بسيطة.
/// - قائمة حجوزات اليوم.
class ProviderHomeViewModel {
  final String providerName;

  ProviderHomeViewModel({
    this.providerName = 'مزود الخدمة',
  });

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير، $providerName 👋';
    if (hour < 18) return 'مساء الخير، $providerName 👋';
    return 'مساء الخير، $providerName 👋';
  }

  int get newRequestsCount => 3;
  int get todayBookingsCount => 5;
  double get rating => 4.7;
  double get todayEarnings => 85.0;

  List<Map<String, dynamic>> get todayBookings => [
        {
          'service': 'تنظيف شقة مفروشة',
          'time': '10:00 ص',
          'location': 'عمان - عبدون',
        },
        {
          'service': 'صيانة تكييف',
          'time': '1:30 م',
          'location': 'عمان - خلدا',
        },
        {
          'service': 'تنظيف درجات',
          'time': '5:00 م',
          'location': 'عمان - الدوار الخامس',
        },
      ];
}
