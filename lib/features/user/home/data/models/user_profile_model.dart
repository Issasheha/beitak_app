import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  final String? firstName;
  final String? lastName;
  final String? address;

  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.profileImage,
    super.cityId,
    super.areaId,
    super.city, // ✅ NEW
    super.area, // ✅ NEW
    super.createdAt,
    super.updatedAt,
    this.firstName,
    this.lastName,
    this.address,
  });

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  static int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String? _tryParseString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// ✅ يدعم إن city/area تجي String أو Object
  static String? _extractName(dynamic v) {
    if (v == null) return null;
    if (v is String) return _tryParseString(v);

    if (v is Map) {
      final m = v.cast<String, dynamic>();
      // جرّب أكثر مفاتيح شائعة
      return _tryParseString(m['name']) ??
          _tryParseString(m['name_ar']) ??
          _tryParseString(m['name_en']) ??
          _tryParseString(m['title']) ??
          _tryParseString(m['label']);
    }

    return _tryParseString(v);
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final first = _tryParseString(json['first_name']);
    final last = _tryParseString(json['last_name']);
    final fullName = [
      (first ?? '').trim(),
      (last ?? '').trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    // ✅ city/area ممكن يكونوا:
    // city: "amman"  OR city: {name: "amman"} OR city_name: "amman"
    final cityText =
        _extractName(json['city']) ?? _tryParseString(json['city_name']);
    final areaText =
        _extractName(json['area']) ?? _tryParseString(json['area_name']);

    return UserProfileModel(
      id: _tryParseInt(json['id']) ?? 0,
      firstName: first,
      lastName: last,
      name: fullName.isNotEmpty ? fullName : (_tryParseString(json['name']) ?? ''),
      email: _tryParseString(json['email']) ?? '',
      phone: _tryParseString(json['phone']),
      address: _tryParseString(json['address']),
      profileImage: _tryParseString(json['profile_image']),
      cityId: _tryParseInt(json['city_id']),
      areaId: _tryParseInt(json['area_id']),
      city: cityText, // ✅ NEW
      area: areaText, // ✅ NEW
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
    );
  }

  /// الريسبونس عندك:
  /// { success, data: { user: {...}, provider_profile?... } }
  static UserProfileModel fromAny(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response format');
    }

    final d = data['data'];
    if (d is Map<String, dynamic>) {
      final u = d['user'];
      if (u is Map<String, dynamic>) return UserProfileModel.fromJson(u);
    }

    // fallback (لو رجع user مباشرة)
    final u2 = data['user'];
    if (u2 is Map<String, dynamic>) return UserProfileModel.fromJson(u2);

    throw const FormatException('Invalid profile response format');
  }
}
