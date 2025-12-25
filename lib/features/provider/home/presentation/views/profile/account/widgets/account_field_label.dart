// lib/features/provider/home/presentation/views/profile/account/widgets/account_field_label.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class AccountFieldLabel extends StatelessWidget {
  final String text;
  final bool requiredStar;

  const AccountFieldLabel({
    super.key,
    required this.text,
    required this.requiredStar,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (requiredStar) ...[
            SizeConfig.hSpace(4),
            Text(
              '*',
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
