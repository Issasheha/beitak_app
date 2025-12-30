// lib/features/user/home/presentation/views/request_service/models/service_type_option.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';

class ServiceTypeOption {
  /// ✅ المفتاح الموحد داخل التطبيق
  /// مثال: plumbing / cleaning / home_maintenance / appliance_maintenance / electricity
  final String categoryKey;

  /// ✅ الأيقونة
  final IconData icon;

  const ServiceTypeOption({
    required this.categoryKey,
    required this.icon,
  });

  /// ✅ الاسم العربي دائماً من FixedServiceCategories
  String get labelAr => FixedServiceCategories.labelArFromKey(categoryKey);
}

class ServiceTypeOptions {
  ServiceTypeOptions._();

  /// ✅ اربط كل key بأيقونة مناسبة
  static const Map<String, IconData> _icons = {
    'plumbing': Icons.plumbing,
    'cleaning': Icons.cleaning_services,
    'home_maintenance': Icons.home_repair_service,
    'appliance_maintenance': Icons.handyman,
    'electricity': Icons.electrical_services,
  };

  /// ✅ المصدر الوحيد للخيارات: FixedServiceCategories
  static List<ServiceTypeOption> get all {
    return FixedServiceCategories.all.map((c) {
      return ServiceTypeOption(
        categoryKey: c.key,
        icon: _icons[c.key] ?? Icons.miscellaneous_services,
      );
    }).toList(growable: false);
  }
}
