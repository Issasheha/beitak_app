// lib/features/auth/presentation/views/provider/widgets/provider_availability_step.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProviderAvailabilityStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final ValueChanged<Set<String>> onDaysChanged;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  // ✅ Optional cancellation policy
  final ValueChanged<String> onCancellationPolicyChanged;

  const ProviderAvailabilityStep({
    super.key,
    required this.formKey,
    required this.onDaysChanged,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onCancellationPolicyChanged,
  });

  @override
  State<ProviderAvailabilityStep> createState() => _ProviderAvailabilityStepState();
}

class _ProviderAvailabilityStepState extends State<ProviderAvailabilityStep> {
  final List<String> _days = const [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  final Set<String> _selectedDays = {
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  };

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

  final _cancellationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDaysChanged(_selectedDays);
      widget.onStartChanged(_startTime);
      widget.onEndChanged(_endTime);
      widget.onCancellationPolicyChanged(_cancellationController.text.trim());
    });

    _cancellationController.addListener(() {
      widget.onCancellationPolicyChanged(_cancellationController.text.trim());
    });
  }

  @override
  void dispose() {
    _cancellationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التوفر',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(17),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            'حدد أيام وساعات العمل.',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizeConfig.v(16),

          // الأيام المتاحة
          Text(
            'الأيام المتاحة *',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(8),
          Wrap(
            spacing: SizeConfig.w(8),
            runSpacing: SizeConfig.h(8),
            children: _days.map((day) {
              final selected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(
                  day,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                    widget.onDaysChanged(_selectedDays);
                  });
                },
              );
            }).toList(),
          ),
          SizeConfig.v(4),
          TextFormField(
            validator: (_) {
              if (_selectedDays.isEmpty) return 'اختر يومًا واحدًا على الأقل';
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizeConfig.v(16),

          // ساعات العمل
          Text(
            'ساعات العمل *',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(8),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'وقت البداية',
                  time: _startTime,
                  onTap: () => _pickTime(isStart: true),
                ),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: _buildTimeField(
                  label: 'وقت الانتهاء',
                  time: _endTime,
                  onTap: () => _pickTime(isStart: false),
                ),
              ),
            ],
          ),
          SizeConfig.v(4),
          TextFormField(
            validator: (_) {
              final startMinutes = _startTime.hour * 60 + _startTime.minute;
              final endMinutes = _endTime.hour * 60 + _endTime.minute;
              if (endMinutes <= startMinutes) {
                return 'وقت الانتهاء يجب أن يكون بعد وقت البداية';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizeConfig.v(16),

          // سياسة الإلغاء (اختياري Strict doc)
          Text(
            'سياسة الإلغاء (اختياري)',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(8),
          TextFormField(
            controller: _cancellationController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'مثال: يمكن إلغاء الموعد مجانًا قبل 24 ساعة من وقت الحجز.',
              hintStyle: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.all(SizeConfig.h(10)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              final v = (value ?? '').trim();
              if (v.isEmpty) return null; // optional
              if (v.length > 2000) return 'الحد الأقصى 2000 حرف';
              if (_looksLikeScriptOrHtml(v)) return 'نص غير صالح';
              return null;
            },
          ),
        ],
      ),
    );
  }

  static bool _looksLikeScriptOrHtml(String text) {
    final t = text.toLowerCase();
    if (t.contains('<') || t.contains('>')) return true;
    if (t.contains('script')) return true;
    return false;
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final formatted =
        '${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'ص' : 'م'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(
                vertical: SizeConfig.h(10),
                horizontal: SizeConfig.w(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                borderSide: BorderSide.none,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatted,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: SizeConfig.w(18),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          widget.onStartChanged(_startTime);
        } else {
          _endTime = picked;
          widget.onEndChanged(_endTime);
        }
      });
    }
  }
}
