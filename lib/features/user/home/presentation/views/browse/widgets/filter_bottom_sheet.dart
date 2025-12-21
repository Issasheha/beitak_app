// lib/features/user/home/presentation/views/browse/widgets/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/models/browse_filters_result.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.initialCategoryKey,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.initialMinRating,
  });

  final String? initialCategoryKey;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final double initialMinRating;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _categoryKey;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;

  double _minRating = 0;

  // ✅ بسيط: نعرض خطأ إذا min > max
  String? _priceError;

  String? _normalizeCategoryKey(String? k) {
    final v = k?.trim();
    if (v == null || v.isEmpty) return null;
    return v;
  }

  @override
  void initState() {
    super.initState();

    _categoryKey = _normalizeCategoryKey(widget.initialCategoryKey);
    _minRating = widget.initialMinRating.clamp(0, 5);

    _minCtrl = TextEditingController(
      text: widget.initialMinPrice == null
          ? ''
          : widget.initialMinPrice!.toStringAsFixed(0),
    );
    _maxCtrl = TextEditingController(
      text: widget.initialMaxPrice == null
          ? ''
          : widget.initialMaxPrice!.toStringAsFixed(0),
    );

    _minCtrl.addListener(_validatePrices);
    _maxCtrl.addListener(_validatePrices);

    WidgetsBinding.instance.addPostFrameCallback((_) => _validatePrices());
  }

  @override
  void dispose() {
    _minCtrl.removeListener(_validatePrices);
    _maxCtrl.removeListener(_validatePrices);
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  double? _parseDouble(String s) {
    final x = s.trim();
    if (x.isEmpty) return null;
    final normalized = x.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _validatePrices() {
    final minV = _parseDouble(_minCtrl.text);
    final maxV = _parseDouble(_maxCtrl.text);

    String? err;

    if (minV != null && maxV != null) {
      if (minV < 0 || maxV < 0) {
        err = 'السعر لا يمكن أن يكون سالباً';
      } else if (minV > maxV) {
        err = 'أقل سعر يجب أن يكون أقل من أعلى سعر';
      }
    } else {
      if (minV != null && minV < 0) err = 'أقل سعر لا يمكن أن يكون سالباً';
      if (maxV != null && maxV < 0) err = 'أعلى سعر لا يمكن أن يكون سالباً';
    }

    if (_priceError != err && mounted) {
      setState(() => _priceError = err);
    }
  }

  void _reset() {
    setState(() {
      _categoryKey = null;
      _minCtrl.clear();
      _maxCtrl.clear();
      _minRating = 0;
      _priceError = null;
    });
  }

  void _apply() {
    final minV = _parseDouble(_minCtrl.text);
    final maxV = _parseDouble(_maxCtrl.text);

    if (_priceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_priceError!),
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    final normalizedCategoryKey = _normalizeCategoryKey(_categoryKey);

    Navigator.pop(
      context,
      BrowseFiltersResult(
        categoryKey: normalizedCategoryKey,
        minPrice: minV,
        maxPrice: maxV,
        minRating: _minRating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 14,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.h(12)),
              Text(
                'فلترة النتائج',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: SizeConfig.h(12)),

              _sectionTitle('الفئة'),
              SizedBox(height: SizeConfig.h(8)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    label: 'الكل',
                    selected: _categoryKey == null,
                    onTap: () => setState(() => _categoryKey = null),
                  ),
                  for (final c in FixedServiceCategories.all)
                    _chip(
                      label: c.labelAr,
                      selected: _categoryKey == c.key,
                      onTap: () => setState(() => _categoryKey = c.key),
                    ),
                ],
              ),

              SizedBox(height: SizeConfig.h(16)),
              _sectionTitle('السعر'),
              SizedBox(height: SizeConfig.h(8)),
              Row(
                children: [
                  Expanded(child: _priceField(_minCtrl, 'أقل سعر')),
                  SizedBox(width: SizeConfig.w(10)),
                  Expanded(child: _priceField(_maxCtrl, 'أعلى سعر')),
                ],
              ),
              if (_priceError != null) ...[
                SizedBox(height: SizeConfig.h(8)),
                Text(
                  _priceError!,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: SizeConfig.ts(12),
                  ),
                ),
              ],

              SizedBox(height: SizeConfig.h(16)),
              _sectionTitle('التقييم الأدنى'),
              SizedBox(height: SizeConfig.h(8)),

              // ✅ نجوم واضحة + بدون تكرار نص
              _StarRatingPicker(
                value: _minRating,
                onChanged: (v) => setState(() => _minRating = v),
              ),

              SizedBox(height: SizeConfig.h(18)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'تطبيق',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(10)),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('إعادة ضبط'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: SizeConfig.ts(14),
          fontWeight: FontWeight.w900,
        ),
      );

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.lightGreen,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _priceField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

/// ✅ نجوم أوضح: filled = star, empty = star_border + لون واضح
class _StarRatingPicker extends StatelessWidget {
  const _StarRatingPicker({
    required this.value,
    required this.onChanged,
  });

  final double value; // 0..5
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final selected = value.round().clamp(0, 5);

    return Row(
      children: [
        // النجوم
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(10),
            vertical: SizeConfig.h(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final filled = starIndex <= selected;

              return InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () {
                  // ✅ UX: ضغط نفس الرقم = يرجع درجة أقل (ويقدر يوصل 0)
                  if (selected == starIndex) {
                    onChanged((starIndex - 1).toDouble());
                  } else {
                    onChanged(starIndex.toDouble());
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(2)),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: SizeConfig.ts(28),
                    color: filled
                        ? const Color(0xFFFFC107)
                        : AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              );
            }),
          ),
        ),

        const Spacer(),

        // ✅ قيمة مختصرة يمين مثل شكل الصورة
        Text(
          selected == 0 ? '—' : '$selected',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
