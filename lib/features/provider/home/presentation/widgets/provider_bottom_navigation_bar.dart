import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_quick_actions_row.dart';

class ProviderBottomNavigationBar extends StatelessWidget {
  const ProviderBottomNavigationBar({super.key});

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.providerHome)) return 0;
    if (location.startsWith(AppRoutes.providerMarketplace)) return 1;
    if (location.startsWith(AppRoutes.providerBrowse)) return 2;
    if (location.startsWith(AppRoutes.providerMyService)) return 3;
    return 0;
  }

  void _go(BuildContext context, String route) {
    final current = GoRouterState.of(context).uri.toString();
    if (current.startsWith(route)) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexFromLocation(location);

    final items = <_NavConfig>[
      const _NavConfig(
        label: 'الرئيسية',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        route: AppRoutes.providerHome,
      ),
      const _NavConfig(
        label: 'السوق',
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront,
        route: AppRoutes.providerMarketplace,
      ),
      const _NavConfig(
        label: 'الحجوزات',
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_available,
        route: AppRoutes.providerBrowse,
      ),
      const _NavConfig(
        label: 'خدماتي',
        icon: Icons.design_services_outlined,
        activeIcon: Icons.design_services,
        route: AppRoutes.providerMyService,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: SizeConfig.h(90),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _GlassNavBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      config: items[0],
                      isActive: selectedIndex == 0,
                      onTap: () => _go(context, items[0].route),
                    ),
                    _NavItem(
                      config: items[1],
                      isActive: selectedIndex == 1,
                      onTap: () => _go(context, items[1].route),
                    ),
                    SizedBox(width: SizeConfig.w(80)),
                    _NavItem(
                      config: items[2],
                      isActive: selectedIndex == 2,
                      onTap: () => _go(context, items[2].route),
                    ),
                    _NavItem(
                      config: items[3],
                      isActive: selectedIndex == 3,
                      onTap: () => _go(context, items[3].route),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _CenterFab(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _NavConfig {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({required this.child});

  final Widget child;

  // ✅ cache blur filter
  static final ImageFilter _blur = ImageFilter.blur(sigmaX: 15, sigmaY: 15);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // ✅ isolate navbar repaint cost
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.radius(24)),
        ),
        child: BackdropFilter(
          filter: _blur,
          child: Container(
            height: SizeConfig.h(76),
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
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.config,
    required this.isActive,
    required this.onTap,
  });

  final _NavConfig config;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryGreen : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.h(8),
          horizontal: SizeConfig.w(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? config.activeIcon : config.icon,
              color: color,
              size: SizeConfig.ts(26),
            ),
            SizedBox(height: SizeConfig.h(4)),
            Text(
              config.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SizeConfig.ts(11),
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = SizeConfig.w(68);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGreen,
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGreen.withValues(alpha: 0.60),
              blurRadius: 25,
              spreadRadius: 8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.add, size: SizeConfig.ts(38), color: Colors.white),
      ),
    );
  }
}
