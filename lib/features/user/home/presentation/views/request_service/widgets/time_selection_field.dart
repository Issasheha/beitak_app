import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class TimeSelectionField extends StatelessWidget {
  final String? selectedHour; // "HH:00"
  final ValueChanged<String> onPickHour;

  const TimeSelectionField({
    super.key,
    required this.selectedHour,
    required this.onPickHour,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوقت *',
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showModalBottomSheet<String>(
              context: context,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              builder: (ctx) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: SizeConfig.h(10)),
                        Text(
                          'اختر الساعة',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: SizeConfig.ts(15),
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(10)),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: 24,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (c, i) {
                              final hh = i.toString().padLeft(2, '0');
                              final value = '$hh:00';
                              final selected = selectedHour == value;
                              return ListTile(
                                leading: Icon(Icons.schedule, color: selected ? AppColors.lightGreen : AppColors.textSecondary),
                                title: Text(
                                  value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: selected ? AppColors.lightGreen : AppColors.textPrimary,
                                  ),
                                ),
                                onTap: () => Navigator.of(c).pop(value),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(10)),
                      ],
                    ),
                  ),
                );
              },
            );

            if (picked != null) onPickHour(picked);
          },
          child: Container(
            width: double.infinity,
            padding: SizeConfig.padding(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.textSecondary),
                SizedBox(width: SizeConfig.w(10)),
                Expanded(
                  child: Text(
                    selectedHour ?? 'اختر الوقت',
                    style: TextStyle(
                      fontSize: SizeConfig.ts(13),
                      fontWeight: FontWeight.w800,
                      color: selectedHour == null ? AppColors.textSecondary.withValues(alpha: 0.7) : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
