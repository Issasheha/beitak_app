import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/providers/provider_onboarding_data_provider.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProviderBusinessInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController businessNameController;
  final TextEditingController experienceYearsController;
  final TextEditingController hourlyRateController;
  final TextEditingController descriptionController;

  final List<CategoryOption> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;

  final Set<String> selectedLanguages;
  final ValueChanged<Set<String>> onLanguagesChanged;

  // ✅ service areas نخزنها كـ slug (متوافق مع الباك لأنه string list)
  final Set<String> selectedServiceAreas;
  final ValueChanged<Set<String>> onServiceAreasChanged;

  // ✅ قائمة المدن (نستعملها لاختيار مناطق الخدمة)
  final List<CityOption> cities;

  const ProviderBusinessInfoStep({
    super.key,
    required this.formKey,
    required this.businessNameController,
    required this.experienceYearsController,
    required this.hourlyRateController,
    required this.descriptionController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.selectedLanguages,
    required this.onLanguagesChanged,
    required this.selectedServiceAreas,
    required this.onServiceAreasChanged,
    required this.cities,
  });

  @override
  State<ProviderBusinessInfoStep> createState() => _ProviderBusinessInfoStepState();
}

class _ProviderBusinessInfoStepState extends State<ProviderBusinessInfoStep> {
  final List<String> _languages = const ['العربية', 'الإنجليزية', 'لغات أخرى'];

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
            validator: _optionalBusinessNameMin3,
            onDarkBackground: false,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s{2,}')),
            ],
          ),
          SizeConfig.v(16),

          _buildCategoryDropdown(),
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          SizeConfig.v(16),

          AuthTextField(
            label: 'السعر بالساعة (دينار) *',
            hint: 'مثال: 15',
            icon: Icons.monetization_on_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: widget.hourlyRateController,
            validator: _hourlyRateRequired,
            onDarkBackground: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
          ),
          SizeConfig.v(10),
          Text(
            'ملاحظة: يجب أن يكون السعر أكبر من 0 وبحدود منطقية.',
            style: AppTextStyles.label12.copyWith(
              fontSize: SizeConfig.ts(12),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
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
              final selected = widget.selectedLanguages.contains(lang);
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
                  final next = {...widget.selectedLanguages};
                  if (v) {
                    next.add(lang);
                  } else if (next.length > 1) {
                    next.remove(lang);
                  }
                  widget.onLanguagesChanged(next);
                  setState(() {});
                },
              );
            }).toList(),
          ),
          SizeConfig.v(4),
          TextFormField(
            validator: (_) {
              if (widget.selectedLanguages.isEmpty) return 'اختر لغة واحدة على الأقل';
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
            children: widget.cities.map((c) {
              final slug = (c.slug ?? c.id.toString()).trim();
              final selected = widget.selectedServiceAreas.contains(slug);

              return FilterChip(
                label: Text(
                  c.displayName,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                selected: selected,
                onSelected: (v) {
                  final next = {...widget.selectedServiceAreas};
                  if (v) {
                    next.add(slug);
                  } else {
                    next.remove(slug);
                  }
                  widget.onServiceAreasChanged(next);
                  setState(() {});
                },
              );
            }).toList(),
          ),
          SizeConfig.v(4),
          TextFormField(
            validator: (_) {
              if (widget.selectedServiceAreas.isEmpty) {
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
            maxLength: 1000,
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
            validator: _optionalCleanLongTextMax1000,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فئة الخدمة *',
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(6),
        DropdownButtonFormField<int>(
          value: widget.selectedCategoryId,
          items: widget.categories
              .map(
                (c) => DropdownMenuItem<int>(
                  value: c.id,
                  child: Text(
                    c.displayName,
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(13.5),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => widget.onCategoryChanged(v),
          validator: (v) => v == null ? 'فئة الخدمة مطلوبة' : null,
          decoration: InputDecoration(
            hintText: 'اختر فئة الخدمة',
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

  // ✅ Required hourly, >0, منطقي
  static String? _hourlyRateRequired(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'السعر بالساعة مطلوب';
    final p = _parsePrice(v);
    if (p == null) return 'أدخل رقمًا صحيحًا';

    // حدود منطقية (عدلها إذا بدكم)
    if (p <= 0) return 'يجب أن يكون السعر أكبر من 0';
    if (p > 500) return 'السعر غير منطقي (أقصى حد 500)';

    return null;
  }

  // ✅ اسم عمل: حروف/أرقام/مسافات فقط (بدون رموز/إيموجي) + min 3
  static String? _optionalBusinessNameMin3(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;

    if (v.length < 3) return 'يرجى إدخال 3 أحرف على الأقل';
    if (_looksLikeScriptOrHtml(v)) return 'نص غير صالح';
    if (_containsEmojiOrSymbols(v)) return 'يرجى إدخال نص صالح بدون رموز';

    final ok = RegExp(r'^[a-zA-Z0-9\u0600-\u06FF]+(?:\s[a-zA-Z0-9\u0600-\u06FF]+)*$')
        .hasMatch(v);
    if (!ok) return 'يرجى إدخال نص صالح بدون رموز';
    return null;
  }

  // ✅ وصف: نص نظيف ≤1000 بدون رموز/إيموجي
  static String? _optionalCleanLongTextMax1000(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;

    if (v.length > 1000) return 'الحد الأقصى 1000 حرف';
    if (_looksLikeScriptOrHtml(v)) return 'نص غير صالح';
    if (_containsEmojiOrSymbols(v)) return 'يرجى إدخال نص فقط بدون رموز';

    return null;
  }

  static bool _looksLikeScriptOrHtml(String text) {
    final t = text.toLowerCase();
    if (t.contains('<') || t.contains('>')) return true;
    if (t.contains('script')) return true;
    return false;
  }

  // ✅ يمنع emoji + رموز غير مرغوبة
  static bool _containsEmojiOrSymbols(String text) {
    // Emoji ranges + some symbols
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
      unicode: true,
    );
    if (emojiRegex.hasMatch(text)) return true;

    // رموز نمنعها بشكل واضح
    if (RegExp(r'[<>{}\[\]^$*_=\\|~`]').hasMatch(text)) return true;

    return false;
  }
}
