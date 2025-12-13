// lib/features/user/home/presentation/views/browse/widgets_service_details/booking_details_card.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'location_models.dart';

class BookingDetailsCard extends StatelessWidget {
  const BookingDetailsCard({
    super.key,
    required this.loading,
    required this.selectedDateLabel,
    required this.onPickDate,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'معلومات الحجز',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: SizeConfig.ts(15),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.lightGreen),
                ),
            ],
          ),
          const SizedBox(height: 12),

          _ActionTile(
            icon: Icons.calendar_month,
            title: 'اختر تاريخ الحجز',
            value: selectedDateLabel,
            onTap: onPickDate,
          ),

          const SizedBox(height: 10),

          _InfoTile(
            icon: Icons.location_city,
            label: 'المدينة',
            value: cityNameAr.isEmpty ? 'غير محددة' : cityNameAr,
            locked: isCityLocked,
          ),

          const SizedBox(height: 10),

          _AreaDropdown(
            areas: areas,
            selected: selectedArea,
            enabled: areaEnabled,
            onChanged: onAreaChanged,
          ),

          const SizedBox(height: 12),

          Text(
            'ملاحظات (اختياري)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesCtrl,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: 'اكتب أي تفاصيل تساعد المزود…',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.6),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 6),
            // ✅ سهم لليمين
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.locked,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: locked ? AppColors.borderLight.withValues(alpha: 0.25) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          if (locked) const Icon(Icons.lock_outline, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _AreaDropdown extends StatelessWidget {
  const _AreaDropdown({
    required this.areas,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final List<AreaOption> areas;
  final AreaOption? selected;
  final bool enabled;
  final ValueChanged<AreaOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.borderLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'المنطقة',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<AreaOption>(
              value: selected,
              hint: const Text('اختر المنطقة'),
              onChanged: enabled ? onChanged : null,
              items: areas
                  .map(
                    (a) => DropdownMenuItem<AreaOption>(
                      value: a,
                      child: Text(a.nameAr.isEmpty ? a.nameEn : a.nameAr),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
