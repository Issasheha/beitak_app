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
  final TextEditingController fixedPriceController;

  final TextEditingController descriptionController;

  final ValueChanged<Set<String>> onLanguagesChanged;
  final ValueChanged<Set<String>> onServiceAreasChanged;

  final ValueChanged<String?> onCategoryChanged;

  const ProviderBusinessInfoStep({
    super.key,
    required this.formKey,
    required this.businessNameController,
    required this.experienceYearsController,
    required this.hourlyRateController,
    required this.fixedPriceController,
    required this.descriptionController,
    required this.onLanguagesChanged,
    required this.onServiceAreasChanged,
    required this.onCategoryChanged,
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

  final List<String> _languages = const ['العربية', 'الإنجليزية', 'لغات أخرى'];

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
      widget.onCategoryChanged(_selectedCategory);
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
              fontWeight: FontWeight.w700,
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
          AuthTextField(
            label: 'اسم العمل (اختياري)',
            hint: 'اسم شركتك أو عملك',
            icon: Icons.business_center_outlined,
            controller: widget.businessNameController,
            validator: _optionalSafeTextMin3,
            onDarkBackground: false,
          ),
          SizeConfig.v(16),
          _buildDropdown(
            label: 'فئة الخدمة *',
            hint: 'اختر فئة الخدمة',
            value: _selectedCategory,
            items: _serviceCategories,
            onChanged: (v) {
              setState(() => _selectedCategory = v);
              widget.onCategoryChanged(v);
            },
            validator: (v) =>
                (v == null || v.isEmpty) ? 'فئة الخدمة مطلوبة' : null,
          ),
          SizeConfig.v(16),
          AuthTextField(
            label: 'سنوات الخبرة *',
            hint: 'مثال: 5',
            icon: Icons.timer_outlined,
            keyboardType: TextInputType.number,
            controller: widget.experienceYearsController,
            validator: (value) {
              final v = (value ?? '').trim();
              if (v.isEmpty) return 'سنوات الخبرة مطلوبة';
              final years = int.tryParse(v);
              if (years == null) return 'أدخل رقمًا صحيحًا';
              if (years < 0 || years > 70) return 'أدخل رقمًا منطقياً (0 - 70)';
              return null;
            },
            onDarkBackground: false,
          ),
          SizeConfig.v(16),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'السعر الثابت (دينار)',
                  hint: 'مثال: 20',
                  icon: Icons.payments_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: widget.fixedPriceController,
                  validator: _nonNegativePriceOptional,
                  onDarkBackground: false,
                ),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: AuthTextField(
                  label: 'السعر بالساعة (دينار)',
                  hint: 'مثال: 15',
                  icon: Icons.monetization_on_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: widget.hourlyRateController,
                  validator: _nonNegativePriceOptional,
                  onDarkBackground: false,
                ),
              ),
            ],
          ),
          SizeConfig.v(4),
          TextFormField(
            validator: (_) {
              final fixed = _parsePrice(widget.fixedPriceController.text);
              final hourly = _parsePrice(widget.hourlyRateController.text);
              if ((fixed ?? 0) <= 0 && (hourly ?? 0) <= 0) {
                return 'يرجى إدخال سعر ثابت أو سعر بالساعة (واحد على الأقل أكبر من صفر)';
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
              if (_selectedLanguages.isEmpty) return 'اختر لغة واحدة على الأقل';
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizeConfig.v(14),
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
              if (_selectedServiceAreas.isEmpty)
                return 'اختر منطقة خدمة واحدة على الأقل';
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizeConfig.v(16),
          Text(
            'وصف العمل (اختياري)',
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
            validator: _optionalSafeLongTextMax1000,
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

  static double? _parsePrice(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;
    final normalized = v.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  static String? _nonNegativePriceOptional(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final p = _parsePrice(v);
    if (p == null) return 'أدخل رقمًا صحيحًا';
    if (p < 0) return 'لا يمكن أن يكون السعر سالبًا';
    return null;
  }

  static bool _looksLikeScriptOrHtml(String text) {
    final t = text.toLowerCase();
    if (t.contains('<') || t.contains('>')) return true;
    if (t.contains('script')) return true;
    return false;
  }

  static String? _optionalSafeTextMin3(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length < 3) return 'يرجى إدخال 3 أحرف على الأقل';
    if (_looksLikeScriptOrHtml(v)) return 'نص غير صالح';
    return null;
  }

  static String? _optionalSafeLongTextMax1000(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (v.length > 1000) return 'الحد الأقصى 1000 حرف';
    if (_looksLikeScriptOrHtml(v)) return 'نص غير صالح';
    return null;
  }
}
