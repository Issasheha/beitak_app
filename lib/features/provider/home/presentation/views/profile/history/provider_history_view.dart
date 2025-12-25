import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/provider_history_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/provider_history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProviderHistoryView extends ConsumerWidget {
  const ProviderHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final asyncState = ref.watch(providerHistoryControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'السجل',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.read(providerHistoryControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            final controller = ref.read(providerHistoryControllerProvider.notifier);

            List<BookingHistoryItem> items;
            switch (state.activeTab) {
              case HistoryTab.completed:
                items = state.completed;
                break;
              case HistoryTab.incomplete:
                items = state.incomplete; // ✅ only incomplete
                break;
              case HistoryTab.cancelled:
                items = state.cancelled;
                break;
            }

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 8),
                    child: Text(
                      'عرض الخدمات الملغية والمكتملة وغير المكتملة',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(13),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FilterChip(
                            label: 'مكتمل',
                            selected: state.activeTab == HistoryTab.completed,
                            onTap: () => controller.setTab(HistoryTab.completed),
                          ),
                        ),
                        SizeConfig.hSpace(8),
                        Expanded(
                          child: _FilterChip(
                            label: 'غير مكتملة',
                            selected: state.activeTab == HistoryTab.incomplete,
                            onTap: () => controller.setTab(HistoryTab.incomplete),
                            selectedColor: const Color(0xFF6B7280), // رمادي
                          ),
                        ),
                        SizeConfig.hSpace(8),
                        Expanded(
                          child: _FilterChip(
                            label: 'ملغي',
                            selected: state.activeTab == HistoryTab.cancelled,
                            onTap: () => controller.setTab(HistoryTab.cancelled),
                            selectedColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizeConfig.v(8),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              'لا يوجد حجوزات في هذا القسم حالياً',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13),
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: SizeConfig.padding(horizontal: 16, vertical: 8),
                            itemBuilder: (ctx, index) {
                              final item = items[index];
                              return _BookingCard(item: item);
                            },
                            separatorBuilder: (_, __) => SizeConfig.v(8),
                            itemCount: items.length,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===================== Widgets مساعدة =====================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? (selectedColor ?? AppColors.lightGreen) : Colors.white;
    final borderColor = selected
        ? (selectedColor ?? AppColors.lightGreen)
        : AppColors.borderLight.withValues(alpha: 0.9);
    final textColor = selected ? Colors.white : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
      child: Container(
        height: SizeConfig.h(38),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingHistoryItem item;

  const _BookingCard({required this.item});

  static bool _hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  static String _toArabicDigits(String input) {
    const map = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    final b = StringBuffer();
    for (final ch in input.runes) {
      final c = String.fromCharCode(ch);
      b.write(map[c] ?? c);
    }
    return b.toString();
  }

  /// ✅ نفس فكرة المستخدم: نحول provider_notes لنص عربي لطيف
  static String _incompleteNoteArabic(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';
    if (_hasArabic(r)) return r;

    final lower = r.toLowerCase();
    if (lower.contains('automatically marked as incomplete')) {
      final isoMatch = RegExp(r'on\s+([0-9T:\.\-Z]+)').firstMatch(r);
      final hoursMatch = RegExp(r'\(([\d\.]+)\s*hours').firstMatch(r);

      final iso = isoMatch?.group(1) ?? '';
      final hours = hoursMatch?.group(1) ?? '';

      String when = '';
      if (iso.isNotEmpty && iso.contains('T')) {
        final parts = iso.split('T');
        final date = parts[0];
        final time = parts[1].replaceAll('Z', '');
        final hhmm = time.length >= 5 ? time.substring(0, 5) : time;
        when = '${_toArabicDigits(date)} ${_toArabicDigits(hhmm)}';
      } else if (iso.isNotEmpty) {
        when = _toArabicDigits(iso);
      }

      final hoursText = hours.isEmpty ? '' : _toArabicDigits(hours);

      final w = when.isEmpty ? '' : ' بتاريخ $when';
      final h = hoursText.isEmpty ? '' : ' بعد تأخر $hoursText ساعة عن الموعد';

      return 'تم تحويل الحجز إلى "غير مكتمل"$w$h.';
    }

    return 'ملاحظة: $r';
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    if (item.isCancelled) {
      statusColor = Colors.redAccent;
      statusLabel = 'ملغي';
    } else if (item.isCompleted) {
      statusColor = AppColors.lightGreen;
      statusLabel = 'مكتمل';
    } else if (item.isIncomplete) {
      statusColor = const Color(0xFF6B7280);
      statusLabel = 'غير مكتملة';
    } else {
      // fallback لأي حالة غريبة
      statusColor = const Color(0xFFFFB300);
      statusLabel = 'غير مكتملة';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        onTap: () => _openDetailsSheet(
          context: context,
          item: item,
          statusColor: statusColor,
          statusLabel: statusLabel,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.8),
            ),
          ),
          child: Padding(
            padding: SizeConfig.padding(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.w(10),
                        vertical: SizeConfig.h(4),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.caption11.copyWith(
                          fontSize: SizeConfig.ts(11.5),
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                    SizeConfig.hSpace(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.serviceTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(14),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizeConfig.v(2),
                          Text(
                            item.customerName,
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(12),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_left,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                  ],
                ),
                SizeConfig.v(8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.dateLabel} في ${item.timeLabel}',
                            style: AppTextStyles.caption11.copyWith(
                              fontSize: SizeConfig.ts(11.5),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizeConfig.v(2),
                          Text(
                            _buildAddress(item),
                            style: AppTextStyles.caption11.copyWith(
                              fontSize: SizeConfig.ts(11.5),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(2)} د.أ',
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(13),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                if (item.isCancelled &&
                    item.cancellationReason != null &&
                    item.cancellationReason!.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.h(8)),
                    child: Container(
                      padding: SizeConfig.padding(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'سبب الإلغاء: ${item.cancellationReason}',
                        style: AppTextStyles.caption11.copyWith(
                          fontSize: SizeConfig.ts(11.5),
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // ✅ NEW: show hint for incomplete (short)
                if (item.isIncomplete && item.providerNotes != null)
                  Padding(
                    padding: EdgeInsets.only(top: SizeConfig.h(8)),
                    child: Container(
                      padding: SizeConfig.padding(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                        border: Border.all(
                          color: const Color(0xFF6B7280).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        _incompleteNoteArabic(item.providerNotes!),
                        style: AppTextStyles.caption11.copyWith(
                          fontSize: SizeConfig.ts(11.5),
                          color: const Color(0xFF374151),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _buildAddress(BookingHistoryItem item) {
    final city = (item.city).trim();
    final area = (item.area ?? '').trim();

    if (city.isEmpty && area.isEmpty) return '—';
    if (area.isEmpty) return city;
    if (city.isEmpty) return area;
    return '$city، $area';
  }

  static void _openDetailsSheet({
    required BuildContext context,
    required BookingHistoryItem item,
    required Color statusColor,
    required String statusLabel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.only(top: SizeConfig.h(70)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeConfig.radius(22)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: SizeConfig.padding(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'تفاصيل الحجز',
                            style: AppTextStyles.title18.copyWith(
                              fontSize: SizeConfig.ts(17),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    SizeConfig.v(6),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.w(10),
                            vertical: SizeConfig.h(5),
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(SizeConfig.radius(999)),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppTextStyles.caption11.copyWith(
                              fontSize: SizeConfig.ts(11.8),
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                            ),
                          ),
                        ),
                        SizeConfig.hSpace(10),
                        Expanded(
                          child: Text(
                            item.serviceTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(14.5),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizeConfig.v(12),
                    _DetailsCard(
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.person_outline_rounded,
                            label: 'العميل',
                            value: item.customerName,
                          ),
                          SizeConfig.v(10),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'التاريخ',
                            value: item.dateLabel,
                          ),
                          SizeConfig.v(10),
                          _DetailRow(
                            icon: Icons.access_time_rounded,
                            label: 'الوقت',
                            value: item.timeLabel,
                          ),
                          SizeConfig.v(10),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'الموقع',
                            value: _buildAddress(item),
                          ),
                          SizeConfig.v(10),
                          _DetailRow(
                            icon: Icons.payments_outlined,
                            label: 'الإجمالي',
                            value: '${item.totalPrice.toStringAsFixed(2)} د.أ',
                            valueWeight: FontWeight.w900,
                          ),
                        ],
                      ),
                    ),

                    if (item.isCancelled &&
                        item.cancellationReason != null &&
                        item.cancellationReason!.trim().isNotEmpty) ...[
                      SizeConfig.v(12),
                      _DetailsCard(
                        borderColor: Colors.redAccent.withValues(alpha: 0.25),
                        bgColor: Colors.redAccent.withValues(alpha: 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'سبب الإلغاء',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13.5),
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent,
                              ),
                            ),
                            SizeConfig.v(6),
                            Text(
                              item.cancellationReason!,
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ✅ NEW: show provider_notes when incomplete
                    if (item.isIncomplete &&
                        item.providerNotes != null &&
                        item.providerNotes!.trim().isNotEmpty) ...[
                      SizeConfig.v(12),
                      _DetailsCard(
                        borderColor: const Color(0xFF6B7280).withValues(alpha: 0.25),
                        bgColor: const Color(0xFF6B7280).withValues(alpha: 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'ملاحظة النظام',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13.5),
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF374151),
                              ),
                            ),
                            SizeConfig.v(6),
                            Text(
                              _incompleteNoteArabic(item.providerNotes!),
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizeConfig.v(14),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                        ),
                        padding: SizeConfig.padding(vertical: 12),
                      ),
                      child: Text(
                        'إغلاق',
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(14),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? bgColor;

  const _DetailsCard({
    required this.child,
    this.borderColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: borderColor ?? AppColors.borderLight.withValues(alpha: 0.8),
        ),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final FontWeight? valueWeight;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: SizeConfig.w(36),
          height: SizeConfig.w(36),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.lightGreen, size: SizeConfig.w(20)),
        ),
        SizeConfig.hSpace(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption11.copyWith(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizeConfig.v(2),
              Text(
                value.trim().isEmpty ? '—' : value,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.5),
                  color: AppColors.textPrimary,
                  fontWeight: valueWeight ?? FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizeConfig.v(12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
