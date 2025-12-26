import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/viewmodels/provider_history_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/widgets/booking_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryBookingCard extends ConsumerWidget {
  final BookingHistoryItem item;

  const HistoryBookingCard({super.key, required this.item});

  static bool _hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  static String _toArabicDigits(String input) {
    const map = {
      '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
    };
    final b = StringBuffer();
    for (final ch in input.runes) {
      final c = String.fromCharCode(ch);
      b.write(map[c] ?? c);
    }
    return b.toString();
  }

  static String incompleteNoteArabic(String raw) {
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

  static String buildAddress(BookingHistoryItem item) {
    final city = item.city.trim();
    final area = (item.area ?? '').trim();
    if (city.isEmpty && area.isEmpty) return '—';
    if (area.isEmpty) return city;
    if (city.isEmpty) return area;
    return '$city، $area';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    Color statusColor;
    String statusLabel;

    if (item.isCancelled) {
      statusColor = Colors.redAccent;
      statusLabel = 'ملغي';
    } else if (item.isCompleted) {
      statusColor = AppColors.lightGreen;
      statusLabel = 'مكتمل';
    } else {
      statusColor = const Color(0xFF6B7280);
      statusLabel = 'غير مكتملة';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        onTap: () => showBookingDetailsSheet(
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
                            buildAddress(item),
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
                        incompleteNoteArabic(item.providerNotes!),
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
}
