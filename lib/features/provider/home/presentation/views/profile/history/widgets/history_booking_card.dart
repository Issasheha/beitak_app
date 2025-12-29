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

    final _StatusInfo st = _statusInfo(item);

    final hasUserReview = (item.userRating != null && item.userRating! > 0) ||
        (item.userReview != null && item.userReview!.trim().isNotEmpty);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        onTap: () => showBookingDetailsSheet(
          context: context,
          item: item,
          statusColor: st.color,
          statusLabel: st.label,
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
                // ====== Top row: status + title ======
                Row(
                  children: [
                    _StatusPill(label: st.label, color: st.color),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

                // ====== Middle row: date/address + price ======
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

                // ====== User review block (stars + message) ======
                if (hasUserReview) ...[
                  SizeConfig.v(10),
                  _UserReviewMiniBox(
                    rating: item.userRating,
                    review: item.userReview,
                  ),
                ],

                // ====== Cancel reason ======
                if (item.isCancelled &&
                    item.cancellationReason != null &&
                    item.cancellationReason!.trim().isNotEmpty) ...[
                  SizeConfig.v(8),
                  _InfoBox(
                    bg: Colors.redAccent.withValues(alpha: 0.08),
                    border: Colors.redAccent.withValues(alpha: 0.25),
                    textColor: Colors.redAccent,
                    text: 'سبب الإلغاء: ${item.cancellationReason}',
                    fontWeight: FontWeight.w600,
                  ),
                ],

                // ====== Incomplete note ======
                if (item.isIncomplete && item.providerNotes != null) ...[
                  SizeConfig.v(8),
                  _InfoBox(
                    bg: const Color(0xFF6B7280).withValues(alpha: 0.08),
                    border: const Color(0xFF6B7280).withValues(alpha: 0.25),
                    textColor: const Color(0xFF374151),
                    text: incompleteNoteArabic(item.providerNotes!),
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static _StatusInfo _statusInfo(BookingHistoryItem item) {
    if (item.isCancelled) {
      return const _StatusInfo(label: 'ملغي', color: Colors.redAccent);
    }
    if (item.isCompleted) {
      return const _StatusInfo(label: 'مكتمل', color: AppColors.lightGreen);
    }
    return const _StatusInfo(label: 'غير مكتملة', color: Color(0xFF6B7280));
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  const _StatusInfo({required this.label, required this.color});
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(10),
        vertical: SizeConfig.h(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption11.copyWith(
          fontSize: SizeConfig.ts(11.5),
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Color bg;
  final Color border;
  final Color textColor;
  final String text;
  final FontWeight fontWeight;

  const _InfoBox({
    required this.bg,
    required this.border,
    required this.textColor,
    required this.text,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption11.copyWith(
          fontSize: SizeConfig.ts(11.5),
          color: textColor,
          fontWeight: fontWeight,
          height: 1.25,
        ),
      ),
    );
  }
}

class _UserReviewMiniBox extends StatelessWidget {
  final int? rating;
  final String? review;

  const _UserReviewMiniBox({
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final r = (rating ?? 0).clamp(0, 5);
    final msg = (review ?? '').trim();

    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'تقييم العميل',
                style: AppTextStyles.caption11.copyWith(
                  fontSize: SizeConfig.ts(11.5),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (i) {
                final filled = (i + 1) <= r;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: SizeConfig.ts(18),
                  color: filled ? const Color(0xFFFFC107) : AppColors.textSecondary,
                );
              }),
            ],
          ),
          if (msg.isNotEmpty) ...[
            SizeConfig.v(6),
            Text(
              msg,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption11.copyWith(
                fontSize: SizeConfig.ts(11.5),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
