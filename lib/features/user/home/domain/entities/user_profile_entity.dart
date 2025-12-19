class UserProfileEntity {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final int? cityId;
  final int? areaId;
  final String? city;
  final String? area;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.cityId,
    this.areaId,
    this.city,
    this.area,
    this.createdAt,
    this.updatedAt,
  });

  UserProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    int? cityId,
    int? areaId,
    String? city,
    String? area,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      cityId: cityId ?? this.cityId,
      areaId: areaId ?? this.areaId,
      city: city ?? this.city,
      area: area ?? this.area,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
