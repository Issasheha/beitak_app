import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/number_format.dart';

class BookingHeaderCard extends StatelessWidget {
  final String bookingNumber;
  final String serviceName;
  final String statusLabel;
  final Color statusColor;
  final Color background;

  const BookingHeaderCard({
    super.key,
    required this.bookingNumber,
    required this.serviceName,
    required this.statusLabel,
    required this.statusColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(all: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رقم الحجز',
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormat.smart(bookingNumber),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: SizeConfig.ts(14),
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(16),
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: SizeConfig.ts(13),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'الحالة: '),
                        TextSpan(
                          text: statusLabel,
                          style: TextStyle(color: statusColor),
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
