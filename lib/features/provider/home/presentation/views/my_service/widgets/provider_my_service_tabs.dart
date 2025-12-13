import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderMyServiceTabs extends StatelessWidget {
  final TabController controller;
  final int servicesCount;
  final int packagesCount;

  const ProviderMyServiceTabs({
    super.key,
    required this.controller,
    required this.servicesCount,
    required this.packagesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SizeConfig.padding(horizontal: 18, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.65),
        ),
        child: TabBar(
          controller: controller,
          labelColor: AppColors.lightGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicator: BoxDecoration(
            color: AppColors.lightGreen.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(16),
          ),
          tabs: [
            Tab(text: 'الخدمات ($servicesCount)'),
            Tab(text: 'الباقات ($packagesCount)'),
          ],
        ),
      ),
    );
  }
}
