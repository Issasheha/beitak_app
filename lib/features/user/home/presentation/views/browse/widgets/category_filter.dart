// lib/features/home/presentation/views/browse_service_widgets/category_filter.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String?> onChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<String> categories = const [
    'الكل',
    'تنظيف منازل',
    'تكييف',
    'مواسرجي',
    'كهربائي',
    'الدهان',
    'البناء',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الفئة', style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary)),
        SizeConfig.v(8),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          decoration: InputDecoration(
            contentPadding: SizeConfig.padding(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}