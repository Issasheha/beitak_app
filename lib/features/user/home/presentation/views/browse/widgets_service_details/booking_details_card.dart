import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'location_models.dart';

class BookingDetailsCard extends StatelessWidget {
  const BookingDetailsCard({
    super.key,
    required this.loading,
    required this.selectedDateLabel,
    required this.onPickDate,
    required this.selectedTimeLabel,
    required this.onPickTime,
    required this.notesCtrl,
    required this.cityNameAr,
    required this.isCityLocked,
    required this.areas,
    required this.selectedArea,
    required this.onAreaChanged,
    required this.areaEnabled,
  });

  final bool loading;

  final String selectedDateLabel;
  final VoidCallback onPickDate;

  final String selectedTimeLabel;
  final VoidCallback onPickTime;

  final TextEditingController notesCtrl;

  final String cityNameAr;
  final bool isCityLocked;

  final List<AreaOption> areas;
  final AreaOption? selectedArea;
  final ValueChanged<AreaOption?> onAreaChanged;
  final bool areaEnabled;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Column(
      children: [
        _FieldShell(
          label: 'تاريخ الحجز',
          icon: Icons.calendar_month_rounded,
          value: selectedDateLabel,
          placeholder: 'اختر تاريخ الحجز',
          isDropdown: false,
          enabled: !loading,
          onTap: loading ? null : onPickDate,
        ),
        const SizedBox(height: 12),

        _FieldShell(
          label: 'وقت الحجز',
          icon: Icons.access_time_rounded,
          value: selectedTimeLabel,
          placeholder: 'اختر وقت الحجز',
          isDropdown: true,
          enabled: !loading,
          onTap: loading ? null : onPickTime,
        ),
        const SizedBox(height: 12),

        // المحافظة (عرض فقط حسب حالتك الحالية)
        _FieldShell(
          label: 'المحافظة',
          icon: Icons.location_on_rounded,
          value: cityNameAr == '—' ? '' : cityNameAr,
          placeholder: 'اختر المحافظة',
          isDropdown: !isCityLocked, // فقط شكل
          enabled: false, // لأن المنطق الحالي عندك ما فيه اختيار محافظة هون
          onTap: null,
        ),
        const SizedBox(height: 12),

        // المنطقة (Dropdown)
        _AreaDropdown(
          label: 'المنطقة',
          icon: Icons.place_rounded,
          enabled: areaEnabled,
          areas: areas,
          value: selectedArea,
          onChanged: onAreaChanged,
        ),
        const SizedBox(height: 12),

        // الوصف (TextArea)
        _NotesField(controller: notesCtrl),
      ],
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({
    required this.label,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.isDropdown,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final String placeholder;
  final bool isDropdown;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showValue = value.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: SizeConfig.ts(13),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: SizeConfig.h(52),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.lightGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    showValue ? value : placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontSize: SizeConfig.ts(13.5),
                      fontWeight: FontWeight.w700,
                      color: showValue ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isDropdown)
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AreaDropdown extends StatelessWidget {
  const _AreaDropdown({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.areas,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final List<AreaOption> areas;
  final AreaOption? value;
  final ValueChanged<AreaOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: SizeConfig.ts(13),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: SizeConfig.h(52),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.lightGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AreaOption>(
                    isExpanded: true,
                    value: areas.any((e) => e.id == value?.id) ? value : null,
                    hint: Text(
                      'اختر المنطقة',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: SizeConfig.ts(13.5),
                      ),
                    ),
                    items: areas
                        .map(
                          (a) => DropdownMenuItem<AreaOption>(
                            value: a,
                            child: Text(
                              (a.nameAr.trim().isEmpty ? a.nameEn : a.nameAr).trim(),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: SizeConfig.ts(13.5),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: enabled ? onChanged : null,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الوصف',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: SizeConfig.ts(13),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            minLines: 4,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: SizeConfig.ts(13.5),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'أضف تفاصيل إضافية حول الخدمة المطلوبة...',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: SizeConfig.ts(13.2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
