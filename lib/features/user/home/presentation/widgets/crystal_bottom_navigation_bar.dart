import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/viewmodels/home_nav_providers.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/quick_actions_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CrystalBottomNavigationBar extends ConsumerWidget {
  const CrystalBottomNavigationBar({super.key});

  void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
    // تحديث الحالة في Riverpod بدل setState
    ref.read(homeBottomNavIndexProvider.notifier).state = index;

    // نفس منطق التوجيه القديم بالضبط
    if (index == 0) context.go(AppRoutes.home);
    if (index == 1) context.push(AppRoutes.myServices);
    if (index == 2) context.go(AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(homeBottomNavIndexProvider);

    Widget buildNavItem({
      required IconData icon,
      required IconData activeIcon,
      required String label,
      required int index,
    }) {
      final bool isActive = selectedIndex == index;

      return GestureDetector(
        onTap: () => _onItemTapped(context, ref, index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                size: 28,
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

    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // الخلفية الزجاجية للـ Bottom Bar
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

                    // ظل ناعم من الأعلى بدل الخط الفاصل
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: "الرئيسية",
                        index: 0,
                      ),
                      buildNavItem(
                        icon: Icons.design_services_outlined,
                        activeIcon: Icons.design_services,
                        label: "خدماتي",
                        index: 1,
                      ),

                      // مسافة للدائرة الوسطية
                      const SizedBox(width: 80),

                      buildNavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: "الملف الشخصي",
                        index: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // الدائرة الوسطية الخاصة بـ Quick Actions (+)
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
                        color:
                            AppColors.lightGreen.withValues(alpha: 0.4),
                        blurRadius: 25,
                        spreadRadius: 8,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
