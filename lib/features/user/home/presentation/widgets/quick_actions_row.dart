import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:beitak_app/features/auth/presentation/viewmodels/auth_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({
    super.key,
    required this.parentContext,
  });

  /// ✅ Context الصفحة الأصلية (Home) وليس Context الـ BottomSheet
  final BuildContext parentContext;

  // ✅ cache blur filter (avoid re-creating every build)
  static final ImageFilter _blur = ImageFilter.blur(sigmaX: 10, sigmaY: 10);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    // ✅ watch only what we need (less rebuilds, same UI)
    final authStatus =
        ref.watch(authControllerProvider.select((s) => s.status));
    final isProvider =
        ref.watch(authControllerProvider.select((s) => s.isProvider));

    // ✅ يظهر فقط للـ Guest + User (مش Provider)
    final showProviderJoin =
        authStatus == AuthStatus.guest ||
        (authStatus == AuthStatus.authenticated && isProvider == false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RepaintBoundary( // ✅ isolate repaints of the blurred sheet
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SizeConfig.radius(16)),
          ),
          child: BackdropFilter(
            filter: _blur,
            child: Container(
              color: AppColors.white.withValues(alpha: 0.20),
              padding: SizeConfig.padding(all: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إجراءات سريعة',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.screenTitle.copyWith(
                      fontSize: SizeConfig.ts(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(14),

                  _quickTile(
                    context,
                    title: 'احجز خدمة',
                    subtitle: 'اختر مزود خدمة واحجز مباشرة',
                    icon: Icons.receipt_long,
                    iconBg: AppColors.lightGreen.withValues(alpha: 0.18),
                    iconColor: AppColors.lightGreen,
                    onTap: () => _closeThenPush(AppRoutes.requestService),
                  ),
                  SizeConfig.v(12),

                  _quickTile(
                    context,
                    title: 'ارسل طلب',
                    subtitle: 'ارسل طلب مع تحديد ميزانيتك',
                    icon: Icons.add,
                    iconBg: AppColors.lightGreen.withValues(alpha: 0.18),
                    iconColor: AppColors.lightGreen,
                    onTap: () => _closeThenPush(AppRoutes.search),
                  ),

                  if (showProviderJoin) ...[
                    SizeConfig.v(12),
                    _quickTile(
                      context,
                      title: 'انضم كمزود خدمة',
                      subtitle: 'سجّل وابدأ باستقبال الطلبات',
                      icon: Icons.handshake_rounded,
                      iconBg: Colors.blue.shade700.withValues(alpha: 0.14),
                      iconColor: Colors.blue.shade700,
                      onTap: () => _closeThenPush(AppRoutes.providerApplication),
                    ),
                  ],

                  SizeConfig.v(12),
                  SafeArea(top: false, child: SizedBox(height: SizeConfig.h(2))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ سكّر الشيت وبعدين push من parentContext
  void _closeThenPush(String route) {
    Navigator.of(parentContext, rootNavigator: true).pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!parentContext.mounted) return;
      parentContext.push(route);
    });
  }

  Widget _quickTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          onTap: onTap,
          child: RepaintBoundary( // ✅ each tile becomes cheaper to repaint
            child: Container(
              padding: SizeConfig.padding(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.60),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: SizeConfig.ts(16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizeConfig.v(4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.helper.copyWith(
                            fontSize: SizeConfig.ts(12.5),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(12)),
                  Container(
                    width: SizeConfig.w(44),
                    height: SizeConfig.w(44),
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: SizeConfig.ts(22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
