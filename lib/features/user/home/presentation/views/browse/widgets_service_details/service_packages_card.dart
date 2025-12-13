import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';

class ServicePackagesCard extends StatelessWidget {
  const ServicePackagesCard({
    super.key,
    required this.packages,
    required this.selected,
    required this.onSelect,
  });

  final List<ServicePackage> packages;
  final ServicePackage? selected;
  final ValueChanged<ServicePackage> onSelect;

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'لا توجد باقات لهذه الخدمة.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.layers_outlined, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'اختر باقة',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final p in packages) ...[
            _PackageTile(
              pkg: p,
              selected: selected?.name == p.name,
              onTap: () => onSelect(p),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.pkg,
    required this.selected,
    required this.onTap,
  });

  final ServicePackage pkg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.lightGreen : AppColors.borderLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 1.4 : 1.0),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.lightGreen : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.name.trim().isEmpty ? 'باقة' : pkg.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (pkg.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      pkg.description.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (pkg.features.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: pkg.features.take(4).map((f) {
                        final t = f.trim();
                        if (t.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.lightGreen.withOpacity(0.22)),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.lightGreen.withOpacity(0.20)),
              ),
              child: Text(
                '${pkg.price.toStringAsFixed(0)} د.أ',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
