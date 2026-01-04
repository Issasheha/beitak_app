import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class LineIconText extends StatelessWidget {
  const LineIconText({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: SizeConfig.ts(16), color: AppColors.textSecondary),
        SizedBox(width: SizeConfig.w(8)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
