// lib/features/auth/presentation/views/provider/widgets/provider_business_info_step.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class ProviderBusinessInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController businessNameController;
  final TextEditingController experienceYearsController;
  final TextEditingController hourlyRateController;
  final TextEditingController descriptionController;

  final ValueChanged<Set<String>> onLanguagesChanged;
  final ValueChanged<Set<String>> onServiceAreasChanged;

  const ProviderBusinessInfoStep({
    super.key,
    required this.formKey,
    required this.businessNameController,
    required this.experienceYearsController,
    required this.hourlyRateController,
    required this.descriptionController,
    required this.onLanguagesChanged,
    required this.onServiceAreasChanged,
  });

  @override
  State<ProviderBusinessInfoStep> createState() =>
      _ProviderBusinessInfoStepState();
}

class _ProviderBusinessInfoStepState extends State<ProviderBusinessInfoStep> {
  final List<String> _serviceCategories = const [
    'تنظيف المنازل',
    'سباكة',
    'نجارة',
    'أعمال كهربائية',
    'تكييف وتبريد',
    'دهان وديكور',
    'أعمال ألمنيوم',
  ];

  final List<String> _languages = const [
    'العربية',
    'الإنجليزية',
    'لغات أخرى',
  ];

  final List<String> _governorates = const [
    'عمان',
    'إربد',
    'الزرقاء',
    'العقبة',
    'مادبا',
    'السلط',
    'الكرك',
    'المفرق',
    'جرش',
    'عجلون',
    'الطفيلة',
  ];

  String? _selectedCategory;
  final Set<String> _selectedLanguages = {'العربية'};
  final Set<String> _selectedServiceAreas = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLanguagesChanged(_selectedLanguages);
      widget.onServiceAreasChanged(_selectedServiceAreas);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات العمل',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(17),
              fontWeight: FontWeight.w700, // كان bold
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            'أخبرنا عن عملك والخدمات التي تقدمها.',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizeConfig.v(16),

          // اسم العمل
          AuthTextField(
            label: 'اسم العمل *',
            hint: 'اسم شركتك أو عملك',
            icon: Icons.business_center_outlined,
            controller: widget.businessNameController,
            validator: _requiredValidator,
            onDarkBackground: false,
          ),
          SizeConfig.v(16),

          // فئة الخدمة
          _buildDropdown(
            label: 'فئة الخدمة *',
            hint: 'اختر فئة الخدمة (اختياري حالياً)',
            value: _selectedCategory,
            items: _serviceCategories,
            onChanged: (v) => setState(() => _selectedCategory = v),
            validator: (_) => null,
          ),
          SizeConfig.v(16),

          // سنوات الخبرة
          AuthTextField(
            label: 'سنوات الخبرة *',
            hint: 'مثال: 5',
            icon: Icons.timer_outlined,
            keyboardType: TextInputType.number,
            controller: widget.experienceYearsController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'سنوات الخبرة مطلوبة';
              }
              final years = int.tryParse(value);
              if (years == null || years < 0 || years > 50) {
                return 'أدخل رقمًا منطقياً (0 - 50)';
              }
              return null;
            },
            onDarkBackground: false,
          ),
          SizeConfig.v(16),

          // السعر بالساعة
          AuthTextField(
            label: 'السعر بالساعة (دينار) *',
            hint: 'مثال: 15',
            icon: Icons.monetization_on_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: widget.hourlyRateController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'السعر بالساعة مطلوب';
              }
              final price = double.tryParse(value.replaceAll(',', '.'));
              if (price == null || price <= 0) {
                return 'أدخل سعرًا صحيحًا أكبر من صفر';
              }
              return null;
            },
            onDarkBackground: false,
          ),
          SizeConfig.v(16),

          // اللغات
          Text(
            'اللغات المتقنة *',
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
            children: _languages.map((lang) {
              final selected = _selectedLanguages.contains(lang);
              return FilterChip(
                label: Text(
                  lang,
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
                      _selectedLanguages.add(lang);
                    } else if (_selectedLanguages.length > 1) {
                      _selectedLanguages.remove(lang);
                    }
                    widget.onLanguagesChanged(_selectedLanguages);
                  });
                },
              );
            }).toList(),
          ),
          SizeConfig.v(4),
          TextFormField(
            validator: (_) {
              if (_selectedLanguages.isEmpty) {
                return 'اختر لغة واحدة على الأقل';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizeConfig.v(14),

          // مناطق الخدمة
          Text(
            'مناطق الخدمة *',
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
            children: _governorates.map((gov) {
              final selected = _selectedServiceAreas.contains(gov);
              return FilterChip(
                label: Text(
                  gov,
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
                      _selectedServiceAreas.add(gov);
                    } else {
                      _selectedServiceAreas.remove(gov);
                    }
                    widget.onServiceAreasChanged(_selectedServiceAreas);
                  });
                },
              );
            }).toList(),
          ),
          SizeConfig.v(4),
          TextFormField(
            validator: (_) {
              if (_selectedServiceAreas.isEmpty) {
                return 'اختر منطقة خدمة واحدة على الأقل';
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

          // وصف العمل
          Text(
            'وصف العمل *',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(8),
          TextFormField(
            controller: widget.descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'صف خدماتك وطريقة عملك بإيجاز.',
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
              if (value == null || value.isEmpty) {
                return 'وصف العمل مطلوب';
              }
              if (value.length < 20) {
                return 'يرجى إدخال وصف أكثر تفصيلاً (20 حرفًا على الأقل)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(13.5),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
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
        ),
      ],
    );
  }

  static String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }
}
