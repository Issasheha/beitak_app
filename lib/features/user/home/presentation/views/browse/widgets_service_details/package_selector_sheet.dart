import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';

class PackageSelectorSheet extends StatefulWidget {
  const PackageSelectorSheet({
    super.key,
    required this.packages,
    required this.initialSelectedName,
  });

  final List<ServicePackage> packages;
  final String? initialSelectedName;

  static Future<String?> show(
    BuildContext context, {
    required List<ServicePackage> packages,
    String? selectedName,
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: PackageSelectorSheet(
          packages: packages,
          initialSelectedName: selectedName,
        ),
      ),
    );
  }

  @override
  State<PackageSelectorSheet> createState() => _PackageSelectorSheetState();
}

class _PackageSelectorSheetState extends State<PackageSelectorSheet> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelectedName; // null = بدون باقة
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final sheetRadius = BorderRadius.circular(22);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: sheetRadius,
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              color: Color(0x1A000000),
              offset: Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'اختيار باقة (اختياري)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: SizeConfig.ts(16),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Flexible(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  _radioTileNone(),
                  const SizedBox(height: 6),
                  ...widget.packages.map(_radioTilePackage),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioTileNone() {
    final selected = _selected == null;

    return _RadioCard(
      selected: selected,
      title: 'بدون باقة',
      subtitle: 'احجز الخدمة بسعرها الأساسي',
      trailingText: null,
      onTap: () => setState(() => _selected = null),
    );
  }

  Widget _radioTilePackage(ServicePackage p) {
    final selected = (_selected?.trim() == p.name.trim());

    final priceText = p.price > 0 ? '${p.price.toStringAsFixed(0)} د.أ' : null;
    final subtitle = p.description.trim().isNotEmpty
        ? p.description.trim()
        : (p.features.isNotEmpty ? p.features.first : ' ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _RadioCard(
        selected: selected,
        title: p.name,
        subtitle: subtitle,
        trailingText: priceText,
        onTap: () => setState(() => _selected = p.name),
      ),
    );
  }
}

class _RadioCard extends StatelessWidget {
  const _RadioCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightGreen.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.lightGreen.withValues(alpha: 0.35)
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.lightGreen : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle.trim().isEmpty ? ' ' : subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 10),
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
                  trailingText!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
