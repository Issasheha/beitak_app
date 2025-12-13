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
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse('${json['price']}') ?? 0,
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

  /// عربي من category_other (الأفضل للعرض)
  final String? categoryOther;

  final String? description;
  final double basePrice;
  final String priceType; // hourly | fixed
  final bool isActive;

  final List<ProviderServicePackage> packages;

  ProviderServiceModel({
    required this.id,
    required this.name,
    required this.categoryOther,
    required this.description,
    required this.basePrice,
    required this.priceType,
    required this.isActive,
    required this.packages,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    final pkgsRaw = (json['packages'] is List) ? (json['packages'] as List) : const [];
    return ProviderServiceModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      categoryOther: json['category_other']?.toString(),
      description: json['description']?.toString(),
      basePrice: (json['base_price'] is num)
          ? (json['base_price'] as num).toDouble()
          : double.tryParse('${json['base_price']}') ?? 0,
      priceType: (json['price_type'] ?? 'hourly').toString(),
      isActive: (json['is_active'] == true),
      packages: pkgsRaw.map((e) => ProviderServicePackage.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
