// lib/features/home/presentation/views/browse_service_widgets/price_range_filter.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class PriceRangeFilter extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;

  const PriceRangeFilter({
    super.key,
    required this.minController,
    required this.maxController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نطاق السعر', style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary)),
        SizeConfig.v(12),
        Row(
          children: [
            Expanded(
              child: _buildPriceField(minController, 'الأدنى'),
            ),
            Padding(
              padding: SizeConfig.padding(horizontal: 8),
              child: Text('-', style: TextStyle(fontSize: SizeConfig.ts(20), color: AppColors.textSecondary)),
            ),
            Expanded(
              child: _buildPriceField(maxController, 'الأقصى'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixText: 'د.أ ',
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: SizeConfig.padding(horizontal: 16, vertical: 16),
      ),
    );
  }
}