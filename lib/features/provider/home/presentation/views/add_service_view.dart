// lib/features/provider/home/presentation/views/add_service_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

class AddServiceView extends ConsumerStatefulWidget {
  const AddServiceView({super.key});

  @override
  ConsumerState<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends ConsumerState<AddServiceView> {
  final _formKey = GlobalKey<FormState>();

  final _price = TextEditingController();
  final _desc = TextEditingController();

  String? _selectedCategoryKey; // ✅ key ثابت
  String _priceType = 'hourly'; // hourly | fixed
  bool _submitting = false;

  @override
  void dispose() {
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  String _labelFromKey(String k) => FixedServiceCategories.labelArFromKey(k);

  Future<void> _save() async {
    if (_submitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_selectedCategoryKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اختر فئة الخدمة',
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final basePrice = double.parse(_price.text.trim());

      final serviceNameKey = _selectedCategoryKey!; // ✅ name = key
      final categoryOther = _labelFromKey(_selectedCategoryKey!); // ✅ UI label

      final data = {
        'name': serviceNameKey,
        'description': _desc.text.trim(),
        'base_price': basePrice,
        'price_type': _priceType,
        'category_other': categoryOther,
      };

      await ApiClient.dio.post(
        ApiConstants.services,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );

      ref.invalidate(providerMyServicesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إنشاء الخدمة بنجاح',
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.lightGreen,
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.providerHome);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل إنشاء الخدمة: $e',
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    _selectedCategoryKey ??= FixedServiceCategories.all.first.key;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'إنشاء خدمة جديدة',
            style: AppTextStyles.title18.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.providerHome);
              }
            },
          ),
        ),
        body: Padding(
          padding: SizeConfig.padding(all: 20),
          child: SingleChildScrollView(
            child: AbsorbPointer(
              absorbing: _submitting,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('فئة الخدمة *'),
                    SizeConfig.v(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FixedServiceCategories.all.map((c) {
                        final selected = _selectedCategoryKey == c.key;
                        return ChoiceChip(
                          label: Text(
                            c.labelAr,
                            style: AppTextStyles.body14.copyWith(
                              color:
                                  selected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: selected,
                          selectedColor: AppColors.lightGreen,
                          onSelected: (v) => setState(
                            () => _selectedCategoryKey = v ? c.key : null,
                          ),
                        );
                      }).toList(),
                    ),

                    SizeConfig.v(18),

                    _label('نوع السعر *'),
                    SizeConfig.v(6),
                    _priceTypeSelector(),

                    SizeConfig.v(18),

                    _label('السعر (د.أ) *'),
                    _input(
                      _price,
                      'مثال: 25',
                      keyboardType: TextInputType.number,
                    ),

                    SizeConfig.v(18),

                    _label('الوصف *'),
                    _input(_desc, 'اشرح تفاصيل الخدمة...', maxLines: 4),

                    SizeConfig.v(26),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.providerHome);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: AppColors.buttonBackground,
                              ),
                              padding: SizeConfig.padding(vertical: 14),
                            ),
                            child: Text(
                              'إلغاء',
                              style: AppTextStyles.body14.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizeConfig.hSpace(12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: SizeConfig.padding(vertical: 14),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'حفظ الخدمة',
                                    style: AppTextStyles.body14.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceTypeSelector() {
    Widget chip(String label, String value) {
      final selected = _priceType == value;
      return ChoiceChip(
        label: Text(
          label,
          style: AppTextStyles.body14.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        selectedColor: AppColors.lightGreen,
        onSelected: (_) => setState(() => _priceType = value),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip('بالساعة', 'hourly'),
        chip('ثابت', 'fixed'),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(14),
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );

  Widget _input(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.body14.copyWith(
        fontSize: SizeConfig.ts(13.5),
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(13),
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
    );
  }
}
