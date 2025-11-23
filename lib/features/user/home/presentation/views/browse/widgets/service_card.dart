import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // قراءة آمنة للقيم من الـ Map
    final String imageUrl = (service['imageUrl'] ?? '') as String;
    final String title = (service['title'] ?? '') as String;
    final String provider = (service['provider'] ?? '') as String;

    final double rating = () {
      final value = service['rating'];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }();

    final double price = () {
      final value = service['price'];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeConfig.radius(20)),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: imageUrl.isEmpty
                  ? Container(
                      color: AppColors.borderLight,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.lightGreen,
                                  ),
                                ),
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.borderLight,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
          ),
          // النصوص
          Expanded(
            child: Padding(
              padding: SizeConfig.padding(all: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(15),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizeConfig.v(6),
                  // المزود
                  Text(
                    provider,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(13),
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // التقييم + السعر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.goldAccent,
                            size: SizeConfig.ts(16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: SizeConfig.ts(13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${price.toStringAsFixed(0)} د.أ',
                        style: TextStyle(
                          fontSize: SizeConfig.ts(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGreen,
                        ),
                      ),
                    ],
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
