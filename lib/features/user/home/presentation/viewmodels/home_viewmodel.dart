// lib/features/user/home/presentation/viewmodels/home_viewmodel.dart

/// ViewModel بسيط للـ HomeView.
///
/// حالياً مسؤول عن:
/// - توليد عبارة الترحيب حسب الوقت
/// - توفير قائمة مزوّدي خدمات مقترحين (داتا وهمية مؤقتاً)
///
/// لاحقاً ممكن نطوّره ليتصل بالـ HomeRepository
/// ويجلب بيانات حقيقية من الـ backend.
class HomeViewModel {
  // نستخدم دالة للوقت عشان يسهل اختبار الكلاس لاحقاً إن حبيت (Dependency Injection بسيط)
  final DateTime Function() _now;

  HomeViewModel({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// نص الترحيب حسب الساعة الحالية
  String get greeting {
    final hour = _now().hour;
    if (hour < 12) return 'صباح الخير، مرحباً بعودتك!';
    if (hour < 18) return 'مساء الخير، مرحباً بعودتك!';
    return 'مساء الخير، مرحباً بعودتك!';
  }

  /// قائمة مزودين خدمات (نفس الداتا اللي كانت داخل HomeView)
  List<HomeFeaturedProvider> get featuredProviders => const [
        HomeFeaturedProvider(
          name: 'أكاديمية التدريس النخبة',
          avatar: 'MC',
          rating: 5.0,
          description:
              'مدرس رياضيات وعلم للطلاب الثانويين والجامعيين. دكتوراه في الرياضيات.',
          price: '50.00 دينار/ساعة',
        ),
        HomeFeaturedProvider(
          name: 'ستوديو موسيقى جيمس',
          avatar: 'JM',
          rating: 4.9,
          description:
              'مدرب موسيقى محترف يعلم البيانو والغيتار والغناء. 12 عاماً من الخبرة.',
          price: '45.00 دينار/ساعة',
        ),
      ];
}

/// موديل بسيط لبطاقة المزود المميز في صفحة الـ Home.
/// (مستخدم فقط في الـ ViewModel، وتقدر تبنيه في الـ UI حسب احتياجك)
class HomeFeaturedProvider {
  final String name;
  final String avatar;
  final double rating;
  final String description;
  final String price;

  const HomeFeaturedProvider({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar': avatar,
      'rating': rating,
      'description': description,
      'price': price,
    };
  }
}
