import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderServiceInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProviderServiceInfoRow({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary)),
      ],
    );
  }
}
