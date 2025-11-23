import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderEmptyServicesState extends StatelessWidget {
  final String message;

  const ProviderEmptyServicesState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline,
              size: 80, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          SizeConfig.v(20),
          Text(message,
              style: TextStyle(
                  fontSize: SizeConfig.ts(18),
                  color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
