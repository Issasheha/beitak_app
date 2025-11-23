// lib/features/home/presentation/views/browse_service_widgets/rating_filter.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class RatingFilter extends StatelessWidget {
  final double selectedRating;
  final ValueChanged<double?> onChanged;

  const RatingFilter({
    super.key,
    required this.selectedRating,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> options = [
    {'label': 'أي تقييم', 'value': 0.0},
    {'label': '3 نجوم فما فوق', 'value': 3.0},
    {'label': '4 نجوم فما فوق', 'value': 4.0},
    {'label': '4.5 نجوم فما فوق', 'value': 4.5},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التقييم الأدنى', style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary)),
        SizeConfig.v(8),
        DropdownButtonFormField<double>(
          initialValue: selectedRating,
          decoration: InputDecoration(
            contentPadding: SizeConfig.padding(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: options
              .map<DropdownMenuItem<double>>((opt) => DropdownMenuItem<double>(
                    value: opt['value'] as double,
                    child: Text(opt['label'] as String),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}