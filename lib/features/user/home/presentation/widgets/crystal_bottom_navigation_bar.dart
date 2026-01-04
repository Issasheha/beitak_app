import 'dart:ui';

import 'package:beitak_app/core/constants/color_x.dart';
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

  // ✅ cache blur filter (avoid re-creating every build)
  static final ImageFilter _blur = ImageFilter.blur(sigmaX: 15, sigmaY: 15);

  void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
    ref.read(homeBottomNavIndexProvider.notifier).state = index;

    if (index == 0) context.go(AppRoutes.home);
    if (index == 1) context.push(AppRoutes.myServices);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final selectedIndex = ref.watch(homeBottomNavIndexProvider);

    Widget buildNavItem({
      required IconData icon,
      required IconData activeIcon,
      required String label,
      required int index,
    }) {
      final isActive = selectedIndex == index;

      const activeColor = AppColors.lightGreen;
      const inactiveColor = AppColors.textSecondary;

      final iconWidget = Icon(
        isActive ? activeIcon : icon,
        color: isActive ? activeColor : inactiveColor,
        size: 26,
      );

      final textWidget = Text(
        label,
        style: TextStyle(
          fontSize: SizeConfig.ts(12),
          color: isActive ? activeColor : inactiveColor,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
          height: 1.1,
        ),
      );

      final child = AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(isActive ? 18 : 10),
          vertical: SizeConfig.h(10),
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor.o(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          border: Border.all(
            color: isActive ? activeColor.o(0.25) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            SizedBox(height: SizeConfig.h(4)),
            textWidget,
          ],
        ),
      );

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(context, ref, index),
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary( // ✅ isolate navbar repaints
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(SizeConfig.radius(24)),
                ),
                child: BackdropFilter(
                  filter: _blur,
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildNavItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: "الرئيسية",
                          index: 0,
                        ),
                        const SizedBox(width: 84),
                        buildNavItem(
                          icon: Icons.calendar_today_outlined,
                          activeIcon: Icons.calendar_month_rounded,
                          label: "حجوزاتي",
                          index: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(SizeConfig.radius(24)),
                        ),
                      ),
                      builder: (_) => QuickActionsRow(
                        parentContext: context,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightGreen,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightGreen.withValues(alpha: 0.40),
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
          ),
        ],
      ),
    );
  }
}
