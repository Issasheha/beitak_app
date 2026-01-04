import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/booking_card_utils.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/line_icon_text.dart';
import 'package:flutter/material.dart';


class AcceptedStyleBody extends StatelessWidget {
  const AcceptedStyleBody({
    super.key,
    required this.booking,
    required this.statusLabel,
    required this.statusColor,
    required this.initials,
    required this.avatarColor,
    required this.dateTimeLine,
    required this.locationLine,
    required this.priceText,
    required this.showNotes,
    required this.notes,
  });

  final ProviderBookingModel booking;

  final String statusLabel;
  final Color statusColor;

  final String initials;
  final Color avatarColor;

  final String dateTimeLine;
  final String locationLine;

  final String priceText;

  final bool showNotes;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final icon = BookingCardUtils.serviceIconFromServiceName(booking.serviceNameAr);
    final serviceTitle = '${booking.serviceNameAr}  $icon';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ AVATAR أولاً -> يمين (RTL)
            Container(
              width: SizeConfig.w(44),
              height: SizeConfig.w(44),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(14),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: SizeConfig.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          serviceTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title18.copyWith(
                            fontSize: SizeConfig.ts(15),
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: SizeConfig.w(8)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.label12.copyWith(
                            fontSize: SizeConfig.ts(11),
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.h(6)),
                  Text(
                    booking.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(12.6),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (showNotes) ...[
          SizedBox(height: SizeConfig.h(10)),
          _NotesBox(notes: notes),
        ],

        SizedBox(height: SizeConfig.h(10)),

        const LineIconText(icon: Icons.calendar_month_outlined, text: ''),
        LineIconText(
          icon: Icons.calendar_month_outlined,
          text: dateTimeLine,
        ),
        SizedBox(height: SizeConfig.h(6)),
        LineIconText(
          icon: Icons.location_on_outlined,
          text: locationLine,
        ),

        if (priceText.trim().isNotEmpty) ...[
          SizedBox(height: SizeConfig.h(10)),
          Align(
            alignment: Alignment.centerRight, // ✅ السعر يمين
            child: Text(
              priceText,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13.5),
                fontWeight: FontWeight.w900,
                color: AppColors.lightGreen,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NotesBox extends StatelessWidget {
  const _NotesBox({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Text('📝'),
          SizedBox(width: SizeConfig.w(8)),
          Expanded(
            child: Text(
              notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(12.2),
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
