class MarketplaceRequestEntity {
  final int id;

  final int? cityId;
  final int? areaId;

  final int? categoryId; // ✅ NEW

  final String customerName;
  final String? phone;
  final String? cityName;
  final String? areaName;

  final String title;
  final String description;
  final String? categoryLabel;

  final String dateLabel;
  final String timeLabel;

  final double? budgetMin;
  final double? budgetMax;

  final DateTime createdAt;

  const MarketplaceRequestEntity({
    required this.id,
    required this.cityId,
    required this.areaId,
    required this.categoryId, // ✅ NEW
    required this.customerName,
    required this.phone,
    required this.cityName,
    required this.areaName,
    required this.title,
    required this.description,
    required this.categoryLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.budgetMin,
    required this.budgetMax,
    required this.createdAt,
  });
}
