// lib/features/home/presentation/views/home_widgets/crystal_bottom_navigation_bar.dart

import 'dart:ui';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/quick_actions_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CrystalBottomNavigationBar extends StatefulWidget {
  const CrystalBottomNavigationBar({super.key});

  @override
  State<CrystalBottomNavigationBar> createState() => _CrystalBottomNavigationBarState();
}

class _CrystalBottomNavigationBarState extends State<CrystalBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) context.go(AppRoutes.home);
    if (index == 1) context.push(AppRoutes.myServices);
    if (index == 2) context.go(AppRoutes.profile); // الملف الشخصي صار index 2
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // البار الشفاف
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(24))),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    border: Border(top: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.6), width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // الرئيسية
                      _buildNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: "الرئيسية", index: 0),

                      // خدماتي
                      _buildNavItem(icon: Icons.design_services_outlined, activeIcon: Icons.design_services, label: "خدماتي", index: 1),

                      // مسافة فارغة للدائرة (مهم جدًا)
                      const SizedBox(width: 80),

                      // الملف الشخصي
                      _buildNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "الملف الشخصي", index: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // الدائرة الخضراء في النص تمامًا
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(24))),
                    ),
                    builder: (_) => const QuickActionsRow(),
                  );
                },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGreen,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightGreen.withValues(alpha: 0.6),
                        blurRadius: 25,
                        spreadRadius: 8,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, size: 38, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryGreen : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.primaryGreen : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}