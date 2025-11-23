// lib/features/home/presentation/views/browse_service_widgets/filter_bottom_sheet.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/category_filter.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/price_range_filter.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/rating_filter.dart';
import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedCategory;
  late double selectedRating;
  late TextEditingController minPriceCtrl;
  late TextEditingController maxPriceCtrl;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.currentFilters['category'] ?? 'الكل';
    selectedRating = widget.currentFilters['minRating'] ?? 0.0;
    minPriceCtrl = TextEditingController(text: widget.currentFilters['minPrice']?.toStringAsFixed(0) ?? '0');
    maxPriceCtrl = TextEditingController(text: widget.currentFilters['maxPrice']?.toStringAsFixed(0) ?? '150');
  }

  @override
  void dispose() {
    minPriceCtrl.dispose();
    maxPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [AppColors.primaryShadow],
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('خيارات التصفية', style: TextStyle(fontSize: SizeConfig.ts(20), fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizeConfig.v(24),

            CategoryFilter(selectedCategory: selectedCategory, onChanged: (v) => setState(() => selectedCategory = v!)),
            SizeConfig.v(20),
            PriceRangeFilter(minController: minPriceCtrl, maxController: maxPriceCtrl),
            SizeConfig.v(20),
            RatingFilter(selectedRating: selectedRating, onChanged: (v) => setState(() => selectedRating = v!)),
            SizeConfig.v(32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = 'الكل';
                        selectedRating = 0.0;
                        minPriceCtrl.text = '0';
                        maxPriceCtrl.text = '150';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.lightGreen),
                      padding: SizeConfig.padding(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('إعادة تعيين', style: TextStyle(color: AppColors.lightGreen, fontSize: SizeConfig.ts(16))),
                  ),
                ),
                SizeConfig.hSpace(16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final minPrice = double.tryParse(minPriceCtrl.text) ?? 0.0;
                      final maxPrice = double.tryParse(maxPriceCtrl.text) ?? 150.0;
                      if (minPrice > maxPrice) {
                        ScaffoldMessenger.of(context).showSnackBar(
                         const  SnackBar(content: Text('السعر الأدنى يجب أن يكون أقل من الأقصى'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      widget.onApply({
                        'category': selectedCategory,
                        'minPrice': minPrice,
                        'maxPrice': maxPrice,
                        'minRating': selectedRating,
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      padding: SizeConfig.padding(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('تطبيق الفلاتر', style: TextStyle(color: Colors.white, fontSize: SizeConfig.ts(16), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}