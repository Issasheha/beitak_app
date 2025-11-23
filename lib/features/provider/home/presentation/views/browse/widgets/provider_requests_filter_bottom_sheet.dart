import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/category_filter.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/price_range_filter.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/rating_filter.dart';
import 'package:flutter/material.dart';

class ProviderRequestsFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApply;

  const ProviderRequestsFilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<ProviderRequestsFilterBottomSheet> createState() =>
      _ProviderRequestsFilterBottomSheetState();
}

class _ProviderRequestsFilterBottomSheetState
    extends State<ProviderRequestsFilterBottomSheet> {
  late String selectedCategory;
  late double selectedRating;
  late TextEditingController minPriceCtrl;
  late TextEditingController maxPriceCtrl;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.currentFilters['category'] ?? 'الكل';
    selectedRating = widget.currentFilters['minRating'] ?? 0.0;
    minPriceCtrl = TextEditingController(
        text: (widget.currentFilters['minPrice'] ?? 0).toStringAsFixed(0));
    maxPriceCtrl = TextEditingController(
        text: (widget.currentFilters['maxPrice'] ?? 200).toStringAsFixed(0));
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
                Text(
                  'تصفية الطلبات',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizeConfig.v(24),

            // الفئة
            CategoryFilter(
              selectedCategory: selectedCategory,
              onChanged: (v) => setState(() => selectedCategory = v ?? 'الكل'),
            ),
            SizeConfig.v(20),

            // نطاق الميزانية
            const Text(
              'نطاق الميزانية',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizeConfig.v(8),
            PriceRangeFilter(
              minController: minPriceCtrl,
              maxController: maxPriceCtrl,
            ),
            SizeConfig.v(20),

            // التقييم الأدنى (مستقبلاً لو الطلب فيه تقييم)
            RatingFilter(
              selectedRating: selectedRating,
              onChanged: (v) => setState(() => selectedRating = v ?? 0.0),
            ),
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
                        maxPriceCtrl.text = '200';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.lightGreen),
                      padding: SizeConfig.padding(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'إعادة تعيين',
                      style: TextStyle(
                        color: AppColors.lightGreen,
                        fontSize: SizeConfig.ts(16),
                      ),
                    ),
                  ),
                ),
                SizeConfig.hSpace(16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final minPrice =
                          double.tryParse(minPriceCtrl.text) ?? 0.0;
                      final maxPrice =
                          double.tryParse(maxPriceCtrl.text) ?? 200.0;

                      if (minPrice > maxPrice) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'الحد الأدنى يجب أن يكون أقل من أو يساوي الحد الأقصى'),
                            backgroundColor: Colors.red,
                          ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'تطبيق الفلاتر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.ts(16),
                        fontWeight: FontWeight.bold,
                      ),
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
}
