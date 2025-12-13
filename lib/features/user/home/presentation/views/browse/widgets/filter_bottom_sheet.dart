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

  @override
  void initState() {
    super.initState();
    _categoryKey = widget.initialCategoryKey;
    _minRating = widget.initialMinRating;

    _minCtrl = TextEditingController(
      text: widget.initialMinPrice == null ? '' : widget.initialMinPrice!.toStringAsFixed(0),
    );
    _maxCtrl = TextEditingController(
      text: widget.initialMaxPrice == null ? '' : widget.initialMaxPrice!.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  double? _parseDouble(String s) {
    final x = s.trim();
    if (x.isEmpty) return null;
    return double.tryParse(x);
  }

  void _reset() {
    setState(() {
      _categoryKey = null;
      _minCtrl.clear();
      _maxCtrl.clear();
      _minRating = 0;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      BrowseFiltersResult(
        categoryKey: _categoryKey,
        minPrice: _parseDouble(_minCtrl.text),
        maxPrice: _parseDouble(_maxCtrl.text),
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
                  _chip(label: 'الكل', selected: _categoryKey == null, onTap: () => setState(() => _categoryKey = null)),
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

              SizedBox(height: SizeConfig.h(16)),
              _sectionTitle('التقييم الأدنى'),
              SizedBox(height: SizeConfig.h(6)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.lightGreen),
                  SizedBox(width: SizeConfig.w(8)),
                  Expanded(
                    child: Slider(
                      value: _minRating.clamp(0, 5),
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating.toStringAsFixed(1),
                      activeColor: AppColors.lightGreen,
                      onChanged: (v) => setState(() => _minRating = v),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(6)),
                  Text(
                    _minRating == 0 ? '—' : _minRating.toStringAsFixed(1),
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                  ),
                ],
              ),

              SizedBox(height: SizeConfig.h(18)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('إعادة ضبط'),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(10)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('تطبيق', style: TextStyle(color: Colors.white)),
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

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
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
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
