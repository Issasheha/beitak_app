import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_request_ui_model.dart';

class MarketplaceRequestDetailsSheet extends StatelessWidget {
  final MarketplaceRequestUiModel request;

  /// ✅ خيار A: نخفي الهاتف قبل القبول حتى لو موجود
  final bool showPhone;

  const MarketplaceRequestDetailsSheet({
    super.key,
    required this.request,
    this.showPhone = false, // ✅ افتراضيًا مخفي
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  request.title,
                  style: AppTextStyles.title18.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                _Line('العميل', request.customerName),
                _Line('الموقع', _locationLabel(request.cityName, request.areaName)),
                _Line('التاريخ', request.dateLabel),
                _Line('الوقت', request.timeLabel),
                _Line('الميزانية', _budgetLabel(request.budgetMin, request.budgetMax)),
                if ((request.categoryLabel ?? '').trim().isNotEmpty)
                  _Line('الفئة', request.categoryLabel!.trim()),

                // ✅ الهاتف — مخفي قبل القبول
                if (showPhone && (request.phone ?? '').trim().isNotEmpty)
                  _Line('الهاتف', request.phone!.trim())
                else
                  const _InfoBox(
                    icon: Icons.lock_outline_rounded,
                    text: 'رقم الهاتف مخفي حتى يتم قبول الطلب (إذا سمح العميل بإظهاره).',
                  ),

                const SizedBox(height: 12),
                Text(
                  'الوصف',
                  style: AppTextStyles.body14.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.description,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _locationLabel(String? city, String? area) {
    if ((city ?? '').trim().isEmpty && (area ?? '').trim().isEmpty) return '—';
    if ((city ?? '').trim().isEmpty) return area ?? '—';
    if ((area ?? '').trim().isEmpty) return city ?? '—';
    return '$city · $area';
  }

  static String _budgetLabel(double? min, double? max) {
    final a = min?.toStringAsFixed(0) ?? '—';
    final b = max?.toStringAsFixed(0) ?? '—';
    return '$a - $b';
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;

  const _Line(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: AppTextStyles.label12.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.label12.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBox({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.label12.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
