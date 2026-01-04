import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/contact_hidden_hint.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/meta.dart';
import 'package:beitak_app/features/provider/home/presentation/views/bookings/widgets/mini_chip.dart';
import 'package:flutter/material.dart';



class DefaultStyleBody extends StatelessWidget {
  const DefaultStyleBody({
    super.key,
    required this.booking,
    required this.statusLabel,
    required this.statusColor,
    required this.initials,
    required this.avatarColor,
    required this.showContactHint,
    required this.showNotes,
    required this.notes,
    required this.hasCity,
    required this.hasArea,
    required this.cityShown,
    required this.areaShown,
    required this.dateText,
    required this.timeText,
  });

  final ProviderBookingModel booking;
  final String statusLabel;
  final Color statusColor;

  final String initials;
  final Color avatarColor;

  final bool showContactHint;

  final bool showNotes;
  final String notes;

  final bool hasCity;
  final bool hasArea;
  final String cityShown;
  final String areaShown;

  final String dateText;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                booking.serviceNameAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title18.copyWith(
                  fontSize: SizeConfig.ts(15),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: AppTextStyles.label12.copyWith(
                  fontSize: SizeConfig.ts(11),
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(10)),
        Row(
          children: [
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
            SizedBox(width: SizeConfig.w(10)),
            Expanded(
              child: Text(
                booking.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.2),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: SizeConfig.w(10)),
            Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
              size: SizeConfig.ts(22),
            ),
          ],
        ),
        if (showContactHint) ...[
          SizedBox(height: SizeConfig.h(10)),
          const ContactHiddenHint(),
        ],
        if (showNotes) ...[
          SizedBox(height: SizeConfig.h(10)),
          _NotesBox(notes: notes),
        ],
        SizedBox(height: SizeConfig.h(12)),
        Row(
          children: [
            MetaRow(icon: Icons.calendar_today_outlined, text: dateText),
            SizedBox(width: SizeConfig.w(12)),
            MetaRow(icon: Icons.access_time, text: timeText),
            const Spacer(),
            Container(
              width: SizeConfig.w(44),
              height: SizeConfig.w(44),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                color: AppColors.lightGreen.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Text(
                booking.status == 'pending_provider_accept' ? '📩' : '🧳',
                style: AppTextStyles.body16.copyWith(
                  fontSize: SizeConfig.ts(20),
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        if (hasCity || hasArea) ...[
          SizedBox(height: SizeConfig.h(10)),
          Wrap(
            spacing: SizeConfig.w(8),
            runSpacing: SizeConfig.h(8),
            alignment: WrapAlignment.start,
            children: [
              if (hasCity)
                MiniChip(icon: Icons.location_city_outlined, text: cityShown),
              if (hasArea) MiniChip(icon: Icons.place_outlined, text: areaShown),
            ],
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
