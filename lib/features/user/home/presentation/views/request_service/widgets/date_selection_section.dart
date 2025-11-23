// lib/features/home/presentation/views/request_widgets/date_selection_section.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class DateSelectionSection extends StatelessWidget {
  final DateTime? selectedDate;
  final String selectedDateLabel;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;
  final VoidCallback onDayAfter;
  final VoidCallback onCustom;

  const DateSelectionSection({
    super.key,
    required this.selectedDate,
    required this.selectedDateLabel,
    required this.onToday,
    required this.onTomorrow,
    required this.onDayAfter,
    required this.onCustom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التاريخ *', style: TextStyle(fontSize: SizeConfig.ts(15), color: Colors.red.shade600)),
        SizeConfig.v(12),
        Row(
          children: [
            _dateChip('اليوم', 'اليوم', selectedDateLabel, onToday),
            _dateChip('غدًا', 'غدًا', selectedDateLabel, onTomorrow),
            _dateChip('بعد غد', 'بعد غد', selectedDateLabel, onDayAfter),
            _dateChip('تاريخ آخر', 'تاريخ مخصص', selectedDateLabel, onCustom),
          ],
        ),
        if (selectedDate != null) ...[
          SizeConfig.v(8),
          Text(
            'التاريخ المحدد: ${intl.DateFormat('yyyy/MM/dd').format(selectedDate!)}',
            style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.lightGreen, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _dateChip(String label, String value, String selected, VoidCallback onTap) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: SizeConfig.padding(horizontal: 4),
          padding: SizeConfig.padding(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightGreen : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? AppColors.lightGreen : AppColors.borderLight),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}