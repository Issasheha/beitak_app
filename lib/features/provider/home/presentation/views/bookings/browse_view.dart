import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/provider_manage_availability_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/provider_manage_availability_sheet.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/provider_request_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/provider_request_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/provider/home/presentation/views/bookings/viewmodels/provider_browse_viewmodel.dart';

class ProviderBrowseView extends StatefulWidget {
  const ProviderBrowseView({super.key, this.initialTab});

  final String? initialTab;

  @override
  State<ProviderBrowseView> createState() => _ProviderBrowseViewState();
}

class _ProviderBrowseViewState extends State<ProviderBrowseView> {
  late final ProviderBrowseViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ProviderBrowseViewModel();

    final tab = (widget.initialTab ?? '').toLowerCase().trim();
    if (tab == 'pending') {
      _vm.setTab(ProviderBrowseTab.pending);
    } else if (tab == 'upcoming') {
      _vm.setTab(ProviderBrowseTab.upcoming);
    }

    Future.microtask(_vm.refresh);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<bool> _confirmSimple({
    required String title,
    required String desc,
    required String confirmText,
  }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeConfig.radius(22)),
              ),
            ),
            padding: SizeConfig.padding(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.h(10)),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title18.copyWith(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: SizeConfig.h(10)),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(12.8),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: SizeConfig.h(14)),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.borderLight),
                          padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                          ),
                        ),
                        child: Text(
                          'رجوع',
                          style: AppTextStyles.body14.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: SizeConfig.ts(13),
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.w(10)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          elevation: 0,
                          padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: AppTextStyles.body14.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: SizeConfig.ts(13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(10)),
              ],
            ),
          ),
        );
      },
    );

    return ok == true;
  }

  void _openDetails(BuildContext context, ProviderBookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderBookingDetailsSheet(
        booking: booking,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _openAvailabilitySheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProviderManageAvailabilitySheet(),
    );
  }

  Future<void> _openCancelDialog(
    BuildContext context,
    ProviderBookingModel booking,
  ) async {
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(10)),
                      Center(
                        child: Text(
                          'إلغاء الخدمة',
                          textAlign: TextAlign.center,
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
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body14.copyWith(
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
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setLocal(() => selected = v ?? categories.first),
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(10)),
                      TextField(
                        controller: reasonCtrl,
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body14.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'سبب الإلغاء (اختياري)',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: AppTextStyles.body14.copyWith(
                            color: AppColors.textSecondary,
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
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.borderLight),
                                padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                                ),
                              ),
                              child: Text(
                                'رجوع',
                                style: AppTextStyles.body14.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: SizeConfig.ts(13),
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: SizeConfig.w(10)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGreen,
                                elevation: 0,
                                padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                                ),
                              ),
                              child: Text(
                                'تأكيد الإلغاء',
                                style: AppTextStyles.body14.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: SizeConfig.ts(13),
                                ),
                              ),
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
      await _vm.cancel(
        bookingId: booking.id,
        cancellationCategory: selected,
        cancellationReason: reason.isEmpty ? null : reason,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go(AppRoutes.providerHome),
          ),
          title: Text(
            'حجوزاتي وطلباتي',
            style: AppTextStyles.headline22.copyWith(
              fontSize: SizeConfig.ts(18.5),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: AnimatedBuilder(
          animation: _vm,
          builder: (context, _) {
            return Column(
              children: [
                Padding(
                  padding: SizeConfig.padding(horizontal: 16, vertical: 10),
                  child: ProviderManageAvailabilityCard(
                    onTap: _openAvailabilitySheet,
                  ),
                ),
                _TabChipsRow(
                  pendingCount: _vm.pendingCount,
                  upcomingCount: _vm.upcomingCount,
                  tab: _vm.tab,
                  onTabChanged: _vm.setTab,
                ),
                const SizedBox(height: 6),
                if (_vm.errorMessage != null)
                  Padding(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 6),
                    child: Container(
                      padding: SizeConfig.padding(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        _vm.errorMessage!,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(12.6),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _vm.refresh,
                    child: _buildBody(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_vm.isLoading && _vm.all.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: SizeConfig.h(120)),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final items = _vm.visibleBookings;

    if (items.isEmpty) {
      final emptyText = _vm.tab == ProviderBrowseTab.pending
          ? 'لا توجد طلبات حالياً'
          : 'لا توجد خدمات قادمة حالياً';

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: SizeConfig.padding(horizontal: 16, vertical: 18),
        children: [
          Container(
            padding: SizeConfig.padding(all: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Text(
                emptyText,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.5),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: SizeConfig.padding(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final b = items[index];
        final busy = _vm.isBusy(b.id);

        final isPending = _vm.tab == ProviderBrowseTab.pending &&
            b.status == 'pending_provider_accept';

        final isUpcoming = _vm.tab == ProviderBrowseTab.upcoming;

        return ProviderBookingCard(
          booking: b,
          busy: busy,
          onDetailsTap: () => _openDetails(context, b),

          onAccept: isPending
              ? () async {
                  if (busy) return;
                  final ok = await _confirmSimple(
                    title: 'قبول الطلب',
                    desc: 'هل أنت متأكد أنك تريد قبول هذا الطلب؟',
                    confirmText: 'تأكيد القبول',
                  );
                  if (!ok) return;
                  await _vm.accept(b.id);
                }
              : null,

          onReject: isPending
              ? () async {
                  if (busy) return;
                  final ok = await _confirmSimple(
                    title: 'رفض الطلب',
                    desc: 'هل أنت متأكد أنك تريد رفض هذا الطلب؟',
                    confirmText: 'تأكيد الرفض',
                  );
                  if (!ok) return;
                  await _vm.reject(b.id);
                }
              : null,

          onComplete: isUpcoming
              ? () async {
                  if (busy) return;
                  final ok = await _confirmSimple(
                    title: 'إتمام المهمة',
                    desc: 'هل أنت متأكد أنك تريد إتمام هذه المهمة؟',
                    confirmText: 'تأكيد الإتمام',
                  );
                  if (!ok) return;
                  await _vm.complete(b.id);
                }
              : null,

          onCancel: isUpcoming ? () => _openCancelDialog(context, b) : null,
        );
      },
    );
  }
}

class _TabChipsRow extends StatelessWidget {
  const _TabChipsRow({
    required this.tab,
    required this.onTabChanged,
    required this.pendingCount,
    required this.upcomingCount,
  });

  final ProviderBrowseTab tab;
  final ValueChanged<ProviderBrowseTab> onTabChanged;
  final int pendingCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SizeConfig.padding(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _Chip(
              label: 'الطلبات',
              count: pendingCount,
              isSelected: tab == ProviderBrowseTab.pending,
              onTap: () => onTabChanged(ProviderBrowseTab.pending),
            ),
          ),
          SizedBox(width: SizeConfig.w(10)),
          Expanded(
            child: _Chip(
              label: 'الخدمات القادمة',
              count: upcomingCount,
              isSelected: tab == ProviderBrowseTab.upcoming,
              onTap: () => onTabChanged(ProviderBrowseTab.upcoming),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.lightGreen : Colors.white;
    final fg = isSelected ? Colors.white : AppColors.textPrimary;
    final border = isSelected ? AppColors.lightGreen : AppColors.borderLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        child: Container(
          padding: SizeConfig.padding(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
            border: Border.all(color: border.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13.2),
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Container(
                width: SizeConfig.w(26),
                height: SizeConfig.w(26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : AppColors.lightGreen.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(12),
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : AppColors.lightGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
