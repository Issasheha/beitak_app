import 'package:flutter/material.dart';

class ServiceTypeOption {
  final String labelAr;
  final String categorySlug; // must match backend slug in /api/categories
  final IconData icon;

  const ServiceTypeOption({
    required this.labelAr,
    required this.categorySlug,
    required this.icon,
  });
}

class ServiceTypeOptions {
  static const List<ServiceTypeOption> all = [
    ServiceTypeOption(labelAr: 'مواسرجي', categorySlug: 'plumbing', icon: Icons.plumbing),
    ServiceTypeOption(labelAr: 'تنظيف', categorySlug: 'cleaning', icon: Icons.cleaning_services),
    ServiceTypeOption(labelAr: 'صيانة المنازل', categorySlug: 'general maintenance', icon: Icons.home_repair_service),
    ServiceTypeOption(labelAr: 'صيانة الأجهزة', categorySlug: 'appliance repair', icon: Icons.handyman),
    ServiceTypeOption(labelAr: 'كهرباء', categorySlug: 'electrical', icon: Icons.electrical_services),
  ];
}
