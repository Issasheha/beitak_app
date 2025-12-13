import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

enum ServiceDateType { today, tomorrow, dayAfter, other }

class DateSelectionSection extends StatelessWidget {
  final ServiceDateType selectedType;
  final DateTime? selectedOtherDate;
  final ValueChanged<ServiceDateType> onTypeSelected;
  final ValueChanged<DateTime?> onOtherPicked;

  const DateSelectionSection({
    super.key,
    required this.selectedType,
    required this.selectedOtherDate,
    required this.onTypeSelected,
    required this.onOtherPicked,
  });

  String _label(ServiceDateType t) {
    switch (t) {
      case ServiceDateType.today:
        return 'اليوم';
      case ServiceDateType.tomorrow:
        return 'غدًا';
      case ServiceDateType.dayAfter:
        return 'بعد غد';
      case ServiceDateType.other:
        return 'تاريخ آخر';
    }
  }

  String _selectedText() {
    if (selectedType != ServiceDateType.other) return 'تم اختيار: ${_label(selectedType)}';
    if (selectedOtherDate == null) return 'لم يتم اختيار تاريخ';
    final d = selectedOtherDate!;
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'تم اختيار: ${d.year}-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    const items = ServiceDateType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ *',
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: SizeConfig.h(10)),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final t in items)
              _Chip(
                label: _label(t),
                selected: selectedType == t,
                onTap: () async {
                  onTypeSelected(t);
                  if (t == ServiceDateType.other) {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedOtherDate ?? now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                      builder: (context, child) {
                        return Directionality(textDirection: TextDirection.rtl, child: child!);
                      },
                    );
                    onOtherPicked(picked);
                  } else {
                    onOtherPicked(null);
                  }
                },
              ),
          ],
        ),
        SizedBox(height: SizeConfig.h(8)),
        Text(
          _selectedText(),
          style: TextStyle(
            fontSize: SizeConfig.ts(12),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: SizeConfig.padding(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightGreen.withValues(alpha: 0.18): AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.lightGreen : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.ts(12),
            fontWeight: FontWeight.w900,
            color: selected ? AppColors.lightGreen : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
