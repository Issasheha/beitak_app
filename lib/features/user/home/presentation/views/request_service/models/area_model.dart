// class AreaModel {
//   final int id;
//   final String name;
//   final String nameAr;
//   final String nameEn;
//   final String slug;

//   const AreaModel({
//     required this.id,
//     required this.name,
//     required this.nameAr,
//     required this.nameEn,
//     required this.slug,
//   });

//   factory AreaModel.fromJson(Map<String, dynamic> json) {
//     return AreaModel(
//       id: (json['id'] as num?)?.toInt() ?? 0,
//       name: (json['name'] ?? '').toString(),
//       nameAr: (json['name_ar'] ?? '').toString(),
//       nameEn: (json['name_en'] ?? '').toString(),
//       slug: (json['slug'] ?? '').toString(),
//     );
//   }

//   String get displayName {
//     if (nameAr.trim().isNotEmpty) return nameAr.trim();
//     if (name.trim().isNotEmpty) return name.trim();
//     return nameEn.trim();
//   }
// }
