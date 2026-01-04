import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';

class PackageSelectorCard extends StatelessWidget {
  const PackageSelectorCard({
    super.key,
    required this.packages,
    required this.selectedPackageName,
    required this.onChanged,
  });

  final List<ServicePackage> packages;

  final String? selectedPackageName;

  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined,
                  color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الباقات (اختياري)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: SizeConfig.ts(15),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ خيار "بدون باقة"
          _PackageRadioTile(
            title: 'بدون باقة (الخدمة الأساسية)',
            subtitle: 'احجز الخدمة بالسعر الأساسي.',
            priceLabel: null,
            value: null,
            groupValue: selectedPackageName,
            onChanged: onChanged,
            isDefault: true,
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),

          ...packages.map((p) {
            final priceLabel = '${p.price.toStringAsFixed(0)} د.أ';
            final subtitle =
                (p.description).trim().isEmpty ? '—' : p.description.trim();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PackageRadioTile(
                title: p.name,
                subtitle: subtitle,
                priceLabel: priceLabel,
                value: p.name,
                groupValue: selectedPackageName,
                onChanged: onChanged,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PackageRadioTile extends StatelessWidget {
  const _PackageRadioTile({
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.isDefault = false,
  });

  final String title;
  final String subtitle;
  final String? priceLabel;

  final String? value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightGreen.withValues(alpha: 0.7)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.lightGreen.withValues(alpha: 0.35)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Radio<String?>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: (v) => onChanged(v),
              activeColor: AppColors.lightGreen,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (priceLabel != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.lightGreen.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  priceLabel!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else if (isDefault)
              const Icon(Icons.check_circle_outline,
                  color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
