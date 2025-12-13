// lib/features/provider/home/presentation/views/add_package_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

class AddPackageView extends ConsumerStatefulWidget {
  const AddPackageView({super.key});

  @override
  ConsumerState<AddPackageView> createState() => _AddPackageViewState();
}

class _AddPackageViewState extends ConsumerState<AddPackageView> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();

  String? _selectedCategoryKey;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  String _readServiceNameKey(ProviderServiceModel s) {
    final d = s as dynamic;
    try {
      final v = d.name;
      if (v is String && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return '';
  }

  String _readServiceCategoryOther(ProviderServiceModel s) {
    final d = s as dynamic;
    try {
      final v = d.categoryOther;
      if (v is String && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    try {
      final v = d.category_other;
      if (v is String && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return '';
  }

  String? _serviceKeyOf(ProviderServiceModel s) {
    final keyFromName =
        FixedServiceCategories.keyFromAnyString(_readServiceNameKey(s));
    if (keyFromName != null) return keyFromName;

    final keyFromOther = FixedServiceCategories.keyFromAnyString(
      _readServiceCategoryOther(s),
    );
    if (keyFromOther != null) return keyFromOther;

    return null;
  }

  ProviderServiceModel? _serviceForKey(
    List<ProviderServiceModel> services,
    String key,
  ) {
    for (final s in services) {
      final k = _serviceKeyOf(s);
      if (k == key) return s;
    }
    return null;
  }

  Future<void> _save(List<ProviderServiceModel> services) async {
    if (_submitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_selectedCategoryKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اختر الفئة أولاً',
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final service = _serviceForKey(services, _selectedCategoryKey!);
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا توجد خدمة لهذه الفئة. أنشئ خدمة أولاً.',
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.parse(_price.text.trim());

    // ✅ packages الحالية + الجديدة (بدون features)
    final newPackages = [
      for (final p in service.packages)
        {
          'name': p.name,
          'price': p.price,
          if ((p.description ?? '').trim().isNotEmpty)
            'description': p.description,
        },
      {
        'name': _name.text.trim(),
        'price': price,
        'description': _desc.text.trim(),
      }
    ];

    setState(() => _submitting = true);

    try {
      await ApiClient.dio.put(
        ApiConstants.serviceDetails(service.id),
        data: {'packages': newPackages},
        options: Options(contentType: Headers.jsonContentType),
      );

      ref.invalidate(providerMyServicesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إضافة الباقة بنجاح',
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
            'فشل إضافة الباقة: $e',
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

    final servicesAsync = ref.watch(providerMyServicesProvider);
    _selectedCategoryKey ??= FixedServiceCategories.all.first.key;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'إضافة باقة داخل خدمة',
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
          child: servicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'حدث خطأ:\n$e',
                textAlign: TextAlign.center,
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            data: (services) {
              final matchedService =
                  _serviceForKey(services, _selectedCategoryKey!);
              final hasService = matchedService != null;

              if (services.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.design_services_outlined,
                      size: 56,
                      color: AppColors.textSecondary,
                    ),
                    SizeConfig.v(12),
                    Text(
                      'لا يمكنك إضافة باقة قبل إنشاء خدمة واحدة على الأقل.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizeConfig.v(16),
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.providerAddService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: SizeConfig.padding(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'إنشاء خدمة أولاً',
                        style: AppTextStyles.body14.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: _submitting,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('اختر الفئة *'),
                        SizeConfig.v(6),
                        _categoryDropdown(),

                        SizeConfig.v(10),
                        Container(
                          width: double.infinity,
                          padding: SizeConfig.padding(all: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: hasService
                                  ? AppColors.lightGreen.withValues(alpha: 0.35)
                                  : Colors.red.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasService
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: hasService ? AppColors.lightGreen : Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  hasService
                                      ? 'تم العثور على خدمة لهذه الفئة ✅'
                                      : 'لا توجد خدمة لهذه الفئة. أنشئ خدمة أولاً.',
                                  style: AppTextStyles.body14.copyWith(
                                    color: hasService ? AppColors.textPrimary : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (!hasService)
                                TextButton(
                                  onPressed: () => context.push(AppRoutes.providerAddService),
                                  child: Text(
                                    'إنشاء خدمة',
                                    style: AppTextStyles.body14.copyWith(
                                      color: AppColors.lightGreen,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizeConfig.v(18),
                        _label('اسم الباقة *'),
                        _input(_name, 'مثال: باقة بريميوم'),

                        SizeConfig.v(18),
                        _label('السعر (د.أ) *'),
                        _input(_price, 'مثال: 120', keyboardType: TextInputType.number),

                        SizeConfig.v(18),
                        _label('وصف الباقة *'),
                        _input(_desc, 'صف ما تتضمنه الباقة...', maxLines: 3),

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
                                onPressed: hasService ? () => _save(services) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightGreen,
                                  disabledBackgroundColor:
                                      AppColors.lightGreen.withValues(alpha: 0.25),
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
                                        'حفظ الباقة',
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryKey,
          isExpanded: true,
          items: FixedServiceCategories.all
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.key,
                  child: Text(
                    c.labelAr,
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCategoryKey = v),
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: TextFormField(
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
      ),
    );
  }
}
