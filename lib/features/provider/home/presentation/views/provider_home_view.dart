// lib/features/provider/home/presentation/views/provider_home_view.dart
// (تأكد من المسار عندك حسب مشروعك)

import 'package:beitak_app/features/provider/home/presentation/providers/provider_home_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_home_background_decoration.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';
import 'package:beitak_app/features/provider/home/presentation/viewmodels/provider_home_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_bottom_navigation_bar.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_green_header.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_home_content.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_action_buttons.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_sheet_handle.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_today_task_details_sheet.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderHomeView extends ConsumerStatefulWidget {
  const ProviderHomeView({super.key});

  @override
  ConsumerState<ProviderHomeView> createState() => _ProviderHomeViewState();
}

class _ProviderHomeViewState extends ConsumerState<ProviderHomeView> {
  bool _expandNewRequests = true;
  bool _expandTodayTask = true;

  bool _todayBusy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(providerHomeViewModelProvider).refresh());
  }

  void _goToPendingRequests() {
    context.go('${AppRoutes.providerBrowse}?tab=pending');
  }

  // ✅ UPDATED: افتح الشيت الجديد بدل ProviderBookingDetailsSheet القديم
  void _openTodayTaskDetails(ProviderHomeViewModel vm) {
    final booking = vm.todayTask;
    if (booking == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ مهم (الشيت الجديد فيه scroll)
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderTodayTaskDetailsSheet(
        booking: booking,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _runToday(Future<void> Function() fn) async {
    if (_todayBusy) return;
    setState(() => _todayBusy = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _todayBusy = false);
    }
  }

  Future<void> _openCancelDialog(ProviderBookingModel booking) async {
    final categories = <String>[
      'تغيير موعد',
      'لا أستطيع الحضور',
      'العميل لم يرد',
      'عنوان غير صحيح',
      'سبب آخر',
    ];

    String selected = categories.first;
    final reasonCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(SizeConfig.radius(22)),
                ),
              ),
              padding: SizeConfig.padding(horizontal: 16, vertical: 14),
              child: StatefulBuilder(
                builder: (context, setLocal) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProviderSheetHandle(),
                      SizedBox(height: SizeConfig.h(10)),
                      Center(
                        child: Text(
                          'إلغاء الخدمة',
                          style: AppTextStyles.title18.copyWith(
                            fontSize: SizeConfig.ts(16),
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(12)),
                      Text(
                        'تصنيف الإلغاء',
                        style: AppTextStyles.body16.copyWith(
                          fontSize: SizeConfig.ts(12.5),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(6)),
                      Container(
                        padding: SizeConfig.padding(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                          border: Border.all(color: AppColors.borderLight),
                          color: AppColors.background,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selected,
                            isExpanded: true,
                            alignment: Alignment.centerRight,
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        c,
                                        textAlign: TextAlign.right,
                                        style: AppTextStyles.body14.copyWith(
                                          fontSize: SizeConfig.ts(13.5),
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setLocal(
                              () => selected = v ?? categories.first,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(10)),
                      TextField(
                        controller: reasonCtrl,
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(13.5),
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'سبب الإلغاء (اختياري)',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: AppTextStyles.body14.copyWith(
                            fontSize: SizeConfig.ts(13),
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(12)),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: ProviderOutlineActionBtn(
                              label: 'رجوع',
                              onTap: _todayBusy ? null : () => Navigator.pop(context, false),
                            ),
                          ),
                          SizedBox(width: SizeConfig.w(10)),
                          Expanded(
                            child: ProviderPrimaryActionBtn(
                              label: 'تأكيد الإلغاء',
                              isLoading: false,
                              onTap: _todayBusy ? null : () => Navigator.pop(context, true),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.h(10)),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (ok == true) {
      final reason = reasonCtrl.text.trim();
      await _runToday(() async {
        await ref.read(providerHomeViewModelProvider).cancel(
              bookingId: booking.id,
              cancellationCategory: selected,
              cancellationReason: reason.isEmpty ? null : reason,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final vm = ref.watch(providerHomeViewModelProvider);

    final hasNew = vm.newRequestPreview != null;
    final hasToday = vm.todayTask != null;

    final stats = _buildHeaderStats(vm);
    final providerName = vm.providerName;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;

              final headerHeight =
                  (h * 0.40).clamp(SizeConfig.h(240), SizeConfig.h(340)).toDouble();

              return Stack(
                children: [
                  const ProviderHomeBackgroundDecoration(),
                  Column(
                    children: [
                      ProviderGreenHeader(
                        height: headerHeight,
                        providerName: providerName,
                        onProfileTap: () => context.go(AppRoutes.providerProfile),
                        onNotificationsTap: () {},
                        stats: stats,
                      ),
                      Expanded(
                        child: ProviderHomeContent(
                          vm: vm,
                          expandNewRequests: _expandNewRequests,
                          expandTodayTask: _expandTodayTask,
                          todayBusy: _todayBusy,
                          hasNew: hasNew,
                          hasToday: hasToday,
                          onToggleNewRequests: () =>
                              setState(() => _expandNewRequests = !_expandNewRequests),
                          onToggleTodayTask: () =>
                              setState(() => _expandTodayTask = !_expandTodayTask),
                          onNewRequestsTap: _goToPendingRequests,
                          todayTaskUi: hasToday ? _mapTodayTask(vm) : null,
                          newRequestUi: hasNew
                              ? ProviderNewRequestUI(
                                  serviceName: vm.newRequestPreview!.serviceName,
                                  customerName: vm.newRequestPreview!.customerName,
                                )
                              : null,
                          onTodayDetailsTap: () => _openTodayTaskDetails(vm),
                          onTodayCompleteTap: hasToday
                              ? () async {
                                  final booking = vm.todayTask!;
                                  await _runToday(() async {
                                    await ref
                                        .read(providerHomeViewModelProvider)
                                        .complete(booking.id);
                                  });
                                }
                              : null,
                          onTodayCancelTap: hasToday ? () async => _openCancelDialog(vm.todayTask!) : null,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: const ProviderBottomNavigationBar(),
      ),
    );
  }

  List<ProviderHeaderStat> _buildHeaderStats(ProviderHomeViewModel vm) {
    String jd(double v) {
      final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
      return '$s أ.د';
    }

    return [
      ProviderHeaderStat(
        title: 'إجمالي الطلبات',
        value: vm.totalRequestsCount.toString(),
        emoji: '📥',
      ),
      ProviderHeaderStat(
        title: 'أرباح الشهر',
        value: jd(vm.stats.thisMonthEarnings),
        emoji: '💰',
      ),
      ProviderHeaderStat(
        title: ' القادمة',
        value: vm.upcomingCount.toString(),
        emoji: '🧳',
      ),
    ];
  }

  ProviderTodayTaskUI _mapTodayTask(ProviderHomeViewModel vm) {
    final b = vm.todayTask!;
    final timeText = _formatTime(b.bookingTime);
    final durationText = (b.durationHours <= 0) ? '—' : _formatDurationHours(b.durationHours);
    final locationText = b.locationText.isEmpty ? '—' : b.locationText;
    final priceText = b.totalPrice <= 0 ? '—' : '${b.totalPrice.toStringAsFixed(0)} أ.د';

    return ProviderTodayTaskUI(
      serviceName: b.serviceName,
      customerName: b.customerName,
      timeText: timeText,
      durationText: durationText,
      locationText: locationText,
      priceText: priceText,
    );
  }

  String _formatDurationHours(double h) {
    final v = h.round();
    if (v <= 0) return '—';
    if (v == 1) return 'ساعة';
    if (v == 2) return 'ساعتين';
    return '$v ساعات';
  }

  String _formatTime(String hhmmss) {
    final s = hhmmss.trim();
    if (s.isEmpty) return '—';
    final parts = s.split(':');
    if (parts.length < 2) return s;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
