import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ServiceDetailsHeaderCard extends StatelessWidget {
  const ServiceDetailsHeaderCard({
    super.key,
    required this.serviceName,
    required this.description,
    required this.providerName,
    required this.rating,
    required this.locationLabelAr,
    required this.priceLabel,
  });

  final String serviceName;
  final String description;
  final String providerName;
  final double rating;
  final String locationLabelAr;
  final String priceLabel;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '??';
    final a = parts.first.isNotEmpty ? parts.first[0] : '?';
    final b = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1][0]
        : (parts.first.length > 1 ? parts.first[1] : '?');
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [BoxShadow(blurRadius: 14, color: Color(0x0F000000), offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGreen.withValues(alpha: 0.18),
                  border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.25),),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(providerName),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: SizeConfig.ts(14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.lightGreen),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationLabelAr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.20),),
                ),
                child: Text(
                  priceLabel,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            serviceName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: SizeConfig.ts(16),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: SizeConfig.ts(13),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
