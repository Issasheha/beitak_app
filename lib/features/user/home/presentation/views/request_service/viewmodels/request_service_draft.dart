class RequestServiceDraft {
  final String fullName;
  final String phone;
  final String? email;

  final int? categoryId;
  final String serviceTypeLabel;

  final String description;
  final double? budget;

  final int? cityId;
  final int? areaId; // ✅ جديد
  final String? address;

  final String serviceDateType;
  final String? serviceDateValue;

  final int? hour24;
  final bool sharePhoneWithProvider;

  final List<String> imagePaths;

  const RequestServiceDraft({
    required this.fullName,
    required this.phone,
    required this.serviceTypeLabel,
    required this.description,
    required this.serviceDateType,
    required this.sharePhoneWithProvider,
    this.email,
    this.categoryId,
    this.budget,
    this.cityId,
    this.areaId, // ✅ جديد
    this.address,
    this.serviceDateValue,
    this.hour24,
    this.imagePaths = const [],
  });

  RequestServiceDraft copyWith({
    String? fullName,
    String? phone,
    String? email,
    int? categoryId,
    String? serviceTypeLabel,
    String? description,
    double? budget,
    int? cityId,
    int? areaId, // ✅ جديد
    String? address,
    String? serviceDateType,
    String? serviceDateValue,
    int? hour24,
    bool? sharePhoneWithProvider,
    List<String>? imagePaths,
  }) {
    return RequestServiceDraft(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      categoryId: categoryId ?? this.categoryId,
      serviceTypeLabel: serviceTypeLabel ?? this.serviceTypeLabel,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      cityId: cityId ?? this.cityId,
      areaId: areaId ?? this.areaId,
      address: address ?? this.address,
      serviceDateType: serviceDateType ?? this.serviceDateType,
      serviceDateValue: serviceDateValue ?? this.serviceDateValue,
      hour24: hour24 ?? this.hour24,
      sharePhoneWithProvider:
          sharePhoneWithProvider ?? this.sharePhoneWithProvider,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'categoryId': categoryId,
        'serviceTypeLabel': serviceTypeLabel,
        'description': description,
        'budget': budget,
        'cityId': cityId,
        'areaId': areaId, // ✅ جديد
        'address': address,
        'serviceDateType': serviceDateType,
        'serviceDateValue': serviceDateValue,
        'hour24': hour24,
        'sharePhoneWithProvider': sharePhoneWithProvider,
        'imagePaths': imagePaths,
      };

  static RequestServiceDraft? fromJson(Map<String, dynamic> json) {
    try {
      return RequestServiceDraft(
        fullName: (json['fullName'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        email: json['email']?.toString(),
        categoryId: (json['categoryId'] as num?)?.toInt(),
        serviceTypeLabel: (json['serviceTypeLabel'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        budget: (json['budget'] as num?)?.toDouble(),
        cityId: (json['cityId'] as num?)?.toInt(),
        areaId: (json['areaId'] as num?)?.toInt(),
        address: json['address']?.toString(),
        serviceDateType: (json['serviceDateType'] ?? 'today').toString(),
        serviceDateValue: json['serviceDateValue']?.toString(),
        hour24: (json['hour24'] as num?)?.toInt(),
        sharePhoneWithProvider:
            (json['sharePhoneWithProvider'] as bool?) ?? true,
        imagePaths: (json['imagePaths'] is List)
            ? (json['imagePaths'] as List).map((e) => e.toString()).toList()
            : const [],
      );
    } catch (_) {
      return null;
    }
  }
}
