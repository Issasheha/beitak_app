import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/provider/home/presentation/providers/provider_home_providers.dart';

class ProviderEarningsView extends ConsumerWidget {
  const ProviderEarningsView({super.key});

  String _jd(num v) {
    final d = v.toDouble();
    final s = d.toStringAsFixed(d.truncateToDouble() == d ? 0 : 2);
    return '$s د.أ';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final vm = ref.watch(providerHomeViewModelProvider);

    final totalEarnings = vm.totalEarnings;
    final monthEarnings = vm.stats.thisMonthEarnings;
    final completedJobs = vm.completedCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.textPrimary,
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'الأرباح',
                style: AppTextStyles.title18.copyWith(
                  fontSize: SizeConfig.ts(16.5),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: SizeConfig.h(2)),
              Text(
                'معلوماتك المالية',
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(providerHomeViewModelProvider).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _GreenHeaderWithSummaryCard(
                totalEarningsText: _jd(totalEarnings),
                completedText: '$completedJobs',
              ),
              SizedBox(height: SizeConfig.h(14)),
              Padding(
                padding: SizeConfig.padding(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'قسم الأرباح',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body16.copyWith(
                        fontSize: SizeConfig.ts(13.5),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(10)),

                    // ✅ هذا الشهر (بدون مقارنات)
                    _EarningsTile(
                      title: 'هذا الشهر',
                      valueText: _jd(monthEarnings),
                      subtitle: 'إجمالي أرباحك خلال الشهر الحالي',
                      iconBg: AppColors.lightGreen.o(0.12),
                      icon: Icons.calendar_month_outlined,
                      iconColor: AppColors.lightGreen,
                      onTap: null, // لو بدك لاحقاً تفتح تفاصيل شهرية حط callback هون
                    ),

                    SizedBox(height: SizeConfig.h(10)),

                    // ✅ الوظائف المكتملة (نكتفي فيها)
                    _EarningsTile(
                      title: 'الوظائف المكتملة',
                      valueText: '$completedJobs وظيفة',
                      subtitle: 'عدد الطلبات التي تم إنهاؤها بنجاح',
                      iconBg: const Color(0xFF8B5CF6).o(0.12),
                      icon: Icons.inventory_2_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: null,
                    ),

                    SizedBox(height: SizeConfig.h(18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenHeaderWithSummaryCard extends StatelessWidget {
  const _GreenHeaderWithSummaryCard({
    required this.totalEarningsText,
    required this.completedText,
  });

  final String totalEarningsText;
  final String completedText;

  @override
  Widget build(BuildContext context) {
    final headerH = SizeConfig.h(190);

    return SizedBox(
      height: headerH + SizeConfig.h(60),
      child: Stack(
        children: [
          Container(
            height: headerH,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.lightGreen,
                  AppColors.lightGreen.o(0.90),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(SizeConfig.radius(26)),
              ),
            ),
            child: Padding(
              padding: SizeConfig.padding(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: SizeConfig.h(10)),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Text(
                          'الأرباح',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.title18.copyWith(
                            fontSize: SizeConfig.ts(16),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.paid_rounded,
                        color: Colors.white.o(0.95),
                        size: SizeConfig.ts(22),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.h(4)),
                  Text(
                    'معلوماتك المالية',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(12.5),
                      fontWeight: FontWeight.w700,
                      color: Colors.white.o(0.90),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              padding: SizeConfig.padding(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.o(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: SizeConfig.w(40),
                    height: SizeConfig.w(40),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen.o(0.12),
                      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                      border: Border.all(color: AppColors.lightGreen.o(0.25)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.attach_money_rounded,
                      color: AppColors.lightGreen,
                      size: SizeConfig.ts(20),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'إجمالي الأرباح طول الوقت',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.body14.copyWith(
                            fontSize: SizeConfig.ts(12.5),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(6)),
                        Text(
                          totalEarningsText,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.title18.copyWith(
                            fontSize: SizeConfig.ts(22),
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(6)),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: SizeConfig.ts(16),
                              color: AppColors.textSecondary.o(0.85),
                            ),
                            SizedBox(width: SizeConfig.w(6)),
                            Text(
                              'من $completedText وظيفة مكتملة',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(12),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsTile extends StatelessWidget {
  const _EarningsTile({
    required this.title,
    required this.valueText,
    required this.subtitle,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String valueText;
  final String subtitle;

  final Color iconBg;
  final IconData icon;
  final Color iconColor;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final clickable = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: SizeConfig.padding(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
            // ✅ Border أقوى + مميز “كليكابل”
            border: Border.all(
              color: AppColors.lightGreen.o(clickable ? 0.55 : 0.22),
              width: clickable ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.o(clickable ? 0.08 : 0.05),
                blurRadius: clickable ? 18 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: SizeConfig.w(40),
                height: SizeConfig.w(40),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                  border: Border.all(color: iconColor.o(0.18)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: SizeConfig.ts(20)),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(12.8),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(6)),
                    Text(
                      valueText,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.title18.copyWith(
                        fontSize: SizeConfig.ts(16.5),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(4)),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(11.8),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Chevron يعطي إحساس “تفاصيل/دخول” حتى لو onTap فاضي حالياً
              SizedBox(width: SizeConfig.w(10)),
              Icon(
                Icons.chevron_left_rounded,
                size: SizeConfig.ts(22),
                color: AppColors.textSecondary.o(0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
