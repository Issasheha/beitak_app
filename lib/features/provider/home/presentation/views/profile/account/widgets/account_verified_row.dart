// lib/features/provider/home/presentation/views/profile/account/widgets/account_verified_row.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class AccountVerifiedRow extends StatelessWidget {
  final bool isVerified;
  final String labelWhenVerified;
  final String labelWhenNotVerified;

  const AccountVerifiedRow({
    super.key,
    required this.isVerified,
    required this.labelWhenVerified,
    required this.labelWhenNotVerified,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppColors.lightGreen : AppColors.textSecondary;
    final icon = isVerified ? Icons.check_circle : Icons.error_outline;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isVerified ? labelWhenVerified : labelWhenNotVerified,
            style: AppTextStyles.caption11.copyWith(
              fontSize: SizeConfig.ts(11.5),
              color: color,
              fontWeight: isVerified ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          SizeConfig.hSpace(4),
          Icon(icon, size: SizeConfig.ts(16), color: color),
        ],
      ),
    );
  }
}
