import 'package:beitak_app/features/provider/home/domain/entities/marketplace_request_entity.dart';

class MarketplaceRequestUiModel {
  final int id;

  final int? cityId;
  final int? areaId;

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

  const MarketplaceRequestUiModel({
    required this.id,
    required this.cityId,
    required this.areaId,
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

  factory MarketplaceRequestUiModel.fromEntity(MarketplaceRequestEntity e) {
    return MarketplaceRequestUiModel(
      id: e.id,
      cityId: e.cityId,
      areaId: e.areaId,
      customerName: e.customerName,
      phone: e.phone,
      cityName: e.cityName,
      areaName: e.areaName,
      title: e.title,
      description: e.description,
      categoryLabel: e.categoryLabel,
      dateLabel: e.dateLabel,
      timeLabel: e.timeLabel,
      budgetMin: e.budgetMin,
      budgetMax: e.budgetMax,
      createdAt: e.createdAt,
    );
  }
}
