import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/provider/home/presentation/viewmodels/provider_home_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_empty_white_box.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_expandable_section_header.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_new_request_card.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_today_task_card.dart';

@immutable
class ProviderNewRequestUI {
  final String serviceName;
  final String customerName;
  const ProviderNewRequestUI({required this.serviceName, required this.customerName});
}

@immutable
class ProviderTodayTaskUI {
  final String serviceName;
  final String customerName;
  final String timeText;
  final String durationText;
  final String locationText;
  final String priceText;

  const ProviderTodayTaskUI({
    required this.serviceName,
    required this.customerName,
    required this.timeText,
    required this.durationText,
    required this.locationText,
    required this.priceText,
  });
}

class ProviderHomeContent extends StatelessWidget {
  const ProviderHomeContent({
    super.key,
    required this.vm,
    required this.expandNewRequests,
    required this.expandTodayTask,
    required this.todayBusy,
    required this.hasNew,
    required this.hasToday,
    required this.onToggleNewRequests,
    required this.onToggleTodayTask,
    required this.onNewRequestsTap,
    required this.todayTaskUi,
    required this.newRequestUi,
    required this.onTodayDetailsTap,
    required this.onTodayCompleteTap,
    required this.onTodayCancelTap,
  });

  final ProviderHomeViewModel vm;

  final bool expandNewRequests;
  final bool expandTodayTask;
  final bool todayBusy;

  final bool hasNew;
  final bool hasToday;

  final VoidCallback onToggleNewRequests;
  final VoidCallback onToggleTodayTask;

  final VoidCallback onNewRequestsTap;

  final ProviderTodayTaskUI? todayTaskUi;
  final ProviderNewRequestUI? newRequestUi;

  final VoidCallback onTodayDetailsTap;
  final VoidCallback? onTodayCompleteTap;
  final VoidCallback? onTodayCancelTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SizeConfig.padding(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vm.isLoading)
              const ProviderEmptyWhiteBox(text: 'جاري التحميل...')
            else if (vm.errorMessage != null)
              ProviderEmptyWhiteBox(text: vm.errorMessage!)
            else
              const SizedBox.shrink(),

            SizedBox(height: SizeConfig.h(8)),

            ProviderExpandableSectionHeader(
              title: 'طلبات خدمات جديدة',
              subtitle: 'بانتظار قبولك وتقديم عروضك',
              count: vm.totalRequestsCount,
              emoji: '📥',
              expanded: expandNewRequests,
              onTap: onToggleNewRequests,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: expandNewRequests
                  ? Padding(
                      padding: EdgeInsets.only(top: SizeConfig.h(10)),
                      child: (!hasNew || newRequestUi == null)
                          ? const ProviderEmptyWhiteBox(text: 'لا توجد طلبات جديدة حالياً')
                          : ProviderNewRequestCard(
                              serviceName: newRequestUi!.serviceName,
                              customerName: newRequestUi!.customerName,
                              onTap: onNewRequestsTap,
                            ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: SizeConfig.h(10)),

            ProviderExpandableSectionHeader(
              title: 'مهمة اليوم',
              subtitle: 'خدماتك المجدولة لهذا اليوم',
              count: hasToday ? 1 : 0,
              emoji: '📌',
              expanded: expandTodayTask,
              onTap: onToggleTodayTask,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: expandTodayTask
                  ? Padding(
                      padding: EdgeInsets.only(top: SizeConfig.h(10)),
                      child: (!hasToday || todayTaskUi == null)
                          ? const ProviderEmptyWhiteBox(text: 'لا يوجد شغل مجدول لليوم')
                          : ProviderTodayTaskCard(
                              item: todayTaskUi!,
                              busy: todayBusy,
                              onDetailsTap: onTodayDetailsTap,
                              onCompleteTap: onTodayCompleteTap,
                              onCancelTap: onTodayCancelTap,
                            ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: SizeConfig.h(24)),
          ],
        ),
      ),
    );
  }
}
