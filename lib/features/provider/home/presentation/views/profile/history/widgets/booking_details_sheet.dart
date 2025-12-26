import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/viewmodels/provider_history_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/viewmodels/provider_history_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/widgets/history_booking_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/widgets/history_details_widgets.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/widgets/provider_rating_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showBookingDetailsSheet({
  required BuildContext context,
  required BookingHistoryItem item,
  required Color statusColor,
  required String statusLabel,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => BookingDetailsSheet(
      item: item,
      statusColor: statusColor,
      statusLabel: statusLabel,
    ),
  );
}

class BookingDetailsSheet extends ConsumerWidget {
  final BookingHistoryItem item;
  final Color statusColor;
  final String statusLabel;

  const BookingDetailsSheet({
    super.key,
    required this.item,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final async = ref.watch(providerHistoryControllerProvider);
    final state = async.asData?.value;

    final localRated = state?.isRated(item.id) == true;
    final localSubmitting = state?.isSubmittingRating(item.id) == true;

    // ✅ مهم: rated من الباك أو من لوكال (بعد الإرسال)
    final rated = item.providerRated || localRated;
    final submitting = localSubmitting;

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

                HistoryDetailsCard(
                  child: Column(
                    children: [
                      HistoryDetailRow(
                        icon: Icons.person_outline_rounded,
                        label: 'العميل',
                        value: item.customerName,
                      ),
                      SizeConfig.v(10),
                      HistoryDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'التاريخ',
                        value: item.dateLabel,
                      ),
                      SizeConfig.v(10),
                      HistoryDetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'الوقت',
                        value: item.timeLabel,
                      ),
                      SizeConfig.v(10),
                      HistoryDetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'الموقع',
                        value: HistoryBookingCard.buildAddress(item),
                      ),
                      SizeConfig.v(10),
                      HistoryDetailRow(
                        icon: Icons.payments_outlined,
                        label: 'الإجمالي',
                        value: '${item.totalPrice.toStringAsFixed(2)} د.أ',
                        valueWeight: FontWeight.w900,
                      ),
                    ],
                  ),
                ),

                // ✅ تقييم مزود الخدمة (فقط مكتمل)
                if (item.isCompleted) ...[
                  SizeConfig.v(12),
                  HistoryDetailsCard(
                    borderColor: AppColors.lightGreen.withValues(alpha: 0.25),
                    bgColor: AppColors.lightGreen.withValues(alpha: 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: SizeConfig.w(36),
                              height: SizeConfig.w(36),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.star_rounded,
                                color: AppColors.lightGreen,
                                size: SizeConfig.w(22),
                              ),
                            ),
                            SizeConfig.hSpace(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تقييم العميل',
                                    style: AppTextStyles.body14.copyWith(
                                      fontSize: SizeConfig.ts(13.8),
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizeConfig.v(2),
                                  Text(
                                    'أرسل تقييمك للعميل مع مبلغ الدفع (الرسالة اختيارية).',
                                    style: AppTextStyles.body14.copyWith(
                                      fontSize: SizeConfig.ts(12.2),
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizeConfig.v(10),

                        // ✅ إذا تم التقييم: لا نعرض الزر نهائياً
                        if (rated) ...[
                          Container(
                            padding: SizeConfig.padding(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                              border: Border.all(
                                color: AppColors.lightGreen.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.lightGreen,
                                  size: SizeConfig.w(20),
                                ),
                                SizeConfig.hSpace(8),
                                Expanded(
                                  child: Text(
                                    'تم تقييم الخدمة',
                                    style: AppTextStyles.body14.copyWith(
                                      fontSize: SizeConfig.ts(13),
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      final ok = await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        barrierColor: Colors.black.withValues(alpha: 0.35),
                                        builder: (_) => ProviderRatingSheet(
                                          bookingId: item.id,
                                          serviceTitle: item.serviceTitle,
                                          customerName: item.customerName,
                                        ),
                                      );

                                      if (ok == true && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم إرسال التقييم بنجاح')),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGreen,
                                foregroundColor: Colors.white,
                                padding: SizeConfig.padding(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                                ),
                              ),
                              child: submitting
                                  ? SizedBox(
                                      width: SizeConfig.w(18),
                                      height: SizeConfig.w(18),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'إرسال تقييم',
                                      style: AppTextStyles.body14.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (item.isCancelled &&
                    item.cancellationReason != null &&
                    item.cancellationReason!.trim().isNotEmpty) ...[
                  SizeConfig.v(12),
                  HistoryDetailsCard(
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

                if (item.isIncomplete &&
                    item.providerNotes != null &&
                    item.providerNotes!.trim().isNotEmpty) ...[
                  SizeConfig.v(12),
                  HistoryDetailsCard(
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
                          HistoryBookingCard.incompleteNoteArabic(item.providerNotes!),
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
  }
}
