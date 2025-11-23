// lib/features/home/presentation/views/my_service_widgets/empty_services_state.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class EmptyServicesState extends StatelessWidget {
  final String message;

  const EmptyServicesState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          SizeConfig.v(20),
          Text(
            message,
            style: TextStyle(fontSize: SizeConfig.ts(18), color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}