// lib/features/user/home/presentation/views/browse/models/service_summary.dart

import 'package:beitak_app/core/constants/fixed_service_categories.dart';

class ServiceSummary {
  final int id;

  /// بما إنك قررت “اسم الخدمة = الفئة”، نخلي title = اسم الفئة بالعربي
  final String title;

  final String providerName;

  /// نحتفظ بالمعلومة للفلاتر/العرض
  final String categoryKey;
  final String categoryLabelAr;

  final double rating;
  final double price; // base price
  final String imageUrl;

  const ServiceSummary({
    required this.id,
    required this.title,
    required this.providerName,
    required this.categoryKey,
    required this.categoryLabelAr,
    required this.rating,
    required this.price,
    required this.imageUrl,
  });

  factory ServiceSummary.fromJson(Map<String, dynamic> json) {
    final provider = (json['provider'] as Map?)?.cast<String, dynamic>();
    final providerUser = (provider?['user'] as Map?)?.cast<String, dynamic>();

    final images = json['images'];
    String firstImage = '';
    if (images is List && images.isNotEmpty) {
      firstImage = images.first?.toString() ?? '';
    }

    final fn = providerUser?['first_name']?.toString() ?? '';
    final ln = providerUser?['last_name']?.toString() ?? '';
    final providerName = ('$fn $ln').trim().isEmpty ? 'مزود خدمة' : ('$fn $ln').trim();

    final key = FixedServiceCategories.keyFromServiceJson(json) ?? '';
    final labelAr = FixedServiceCategories.labelArFromServiceJson(json);

    // ✅ title = اسم الفئة بالعربي (لأنه ما بدنا اختلافات أسماء)
    final title = labelAr.trim().isEmpty ? 'خدمة' : labelAr.trim();

    return ServiceSummary(
      id: (json['id'] as num).toInt(),
      title: title,
      providerName: providerName,
      categoryKey: key,
      categoryLabelAr: labelAr,
      rating: _toDouble(provider?['rating_avg'] ?? json['rating_avg'] ?? 0),
      price: _toDouble(json['base_price'] ?? 0),
      imageUrl: firstImage,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
