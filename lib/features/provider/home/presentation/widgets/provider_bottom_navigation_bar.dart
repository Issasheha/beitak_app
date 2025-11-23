import 'dart:ui';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_quick_actions_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderBottomNavigationBar extends StatefulWidget {
  const ProviderBottomNavigationBar({super.key});

  @override
  State<ProviderBottomNavigationBar> createState() =>
      _ProviderBottomNavigationBarState();
}

class _ProviderBottomNavigationBarState
    extends State<ProviderBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go(AppRoutes.providerHome);
        break;
      case 1:
        context.go(AppRoutes.providerBrowse);
        break;
      case 2:
        context.go(AppRoutes.providerMyService);
        break;
      case 3:
        context.go(AppRoutes.providerProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ===== الشريط السفلي الزجاجي =====
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeConfig.radius(24)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.borderLight.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'الرئيسية',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.search,
                        activeIcon: Icons.manage_search_rounded,
                        label: 'الاستكشاف',
                        index: 1,
                      ),
                      const SizedBox(width: 80), // فراغ للزر الأوسط
                      _buildNavItem(
                        icon: Icons.event_note_outlined,
                        activeIcon: Icons.event_available,
                        label: 'الحجوزات',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'الحساب',
                        index: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== زر الإضافة (+) في المنتصف =====
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(SizeConfig.radius(24)),
                      ),
                    ),
                    builder: (_) => const ProviderQuickActionsRow(),
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

  // ===== عنصر في شريط التنقل السفلي =====
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
              color:
                  isActive ? AppColors.primaryGreen : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
