import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/pulsing_avatar.dart';
import 'package:flutter/material.dart';


class HolographicServiceCard extends StatelessWidget {
  final Map<String, dynamic> provider;

  const HolographicServiceCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizeConfig.radius(16))),
      color: AppColors.cardBackground.withValues(alpha: 0.8),
      child: Padding(
        padding: SizeConfig.padding(all: 16),
        child: Row(
          children: [
            PulsingAvatar(initials: provider['avatar']),
            SizeConfig.hSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider['name'], style: TextStyle(fontSize: SizeConfig.ts(18), fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizeConfig.v(4),
                  Row(
                    children: List.generate(5, (i) => Icon(Icons.star, size: SizeConfig.ts(16), color: i < provider['rating'] ? AppColors.lightGreen : AppColors.borderLight)),
                  ),
                  SizeConfig.v(4),
                  Text(provider['description'], style: TextStyle(fontSize: SizeConfig.ts(13), color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(provider['price'], style: TextStyle(fontSize: SizeConfig.ts(15), color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}