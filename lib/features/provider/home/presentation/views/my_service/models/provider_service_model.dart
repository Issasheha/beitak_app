class ProviderServicePackage {
  final String name;
  final double price;
  final String? description;

  /// موجودة بالباك-إند حتى لو UI ما صار يظهرها… لازم نحافظ عليها عند التعديل
  final List<dynamic> features;

  ProviderServicePackage({
    required this.name,
    required this.price,
    this.description,
    this.features = const [],
  });

  factory ProviderServicePackage.fromJson(Map<String, dynamic> json) {
    return ProviderServicePackage(
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0,
      description: json['description']?.toString(),
      features: (json['features'] is List) ? (json['features'] as List) : const [],
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'name': name,
      'price': price,
    };
    if ((description ?? '').trim().isNotEmpty) m['description'] = description!.trim();
    if (features.isNotEmpty) m['features'] = features; // ✅ نحافظ عليها
    return m;
  }

  ProviderServicePackage copyWith({
    String? name,
    double? price,
    String? description,
  }) {
    return ProviderServicePackage(
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      features: features,
    );
  }
}

class ProviderServiceModel {
  final int id;

  /// اسم داخلي (مثل plumbing) — لا نعرضه بالضرورة
  final String name;

  /// ✅ اسم عربي (المفروض للعرض) - يرجع من الباك
  final String? nameAr;

  /// (اختياري)
  final String? nameEn;

  /// عربي من category_other (أحياناً null)
  final String? categoryOther;

  final String? description;
  final String? descriptionAr;
  final String? descriptionEn;

  final double basePrice;
  final String priceType; // hourly | fixed

  final bool isActive;

  /// ✅ جديد: إذا موجود من الباك-إند نستخدمه لإظهار Badge "جديد"
  final bool isNew;

  /// (مفيد للـ fallback)
  final DateTime? createdAt;

  final List<ProviderServicePackage> packages;

  ProviderServiceModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    required this.categoryOther,
    required this.description,
    this.descriptionAr,
    this.descriptionEn,
    required this.basePrice,
    required this.priceType,
    this.isActive = true,
    this.isNew = false,
    this.createdAt,
    required this.packages,
  });

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v == 1;
    final s = v.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.tryParse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static bool _fallbackIsNew(DateTime? createdAt) {
    if (createdAt == null) return false;
    final now = DateTime.now().toUtc();
    final t = createdAt.toUtc();
    // ✅ مرن شوي للـ QA: آخر 48 ساعة
    return now.difference(t).inHours <= 48;
  }

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    final pkgsRaw = (json['packages'] is List) ? (json['packages'] as List) : const [];
    final isNewRaw = json['is_new'] ?? json['isNew'] ?? json['new'] ?? json['is_new_service'];

    final createdAt = _parseDate(json['created_at'] ?? json['createdAt']);

    final bool isNew = (isNewRaw != null) ? _toBool(isNewRaw) : _fallbackIsNew(createdAt);

    return ProviderServiceModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      nameAr: json['name_ar']?.toString(),
      nameEn: json['name_en']?.toString(),
      categoryOther: json['category_other']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      basePrice: (json['base_price'] is num)
          ? (json['base_price'] as num).toDouble()
          : double.tryParse('${json['base_price']}') ?? 0,
      priceType: (json['price_type'] ?? 'hourly').toString(),
      isActive: _toBool(json['is_active']),
      isNew: isNew,
      createdAt: createdAt,
      packages: pkgsRaw.map((e) => ProviderServicePackage.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  /// ✅ اسم العرض بالعربي (الأولوية: name_ar ثم category_other ثم name)
  String get displayNameAr {
    final a = (nameAr ?? '').trim();
    if (a.isNotEmpty) return a;
    final c = (categoryOther ?? '').trim();
    if (c.isNotEmpty) return c;
    final n = name.trim();
    return n.isEmpty ? 'الخدمة' : n;
  }

  /// ✅ وصف العرض (الأولوية: description_ar ثم description)
  String get displayDescAr {
    final a = (descriptionAr ?? '').trim();
    if (a.isNotEmpty) return a;
    final d = (description ?? '').trim();
    return d;
  }
}
