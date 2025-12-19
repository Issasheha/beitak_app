import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/providers/categories_id_map_provider.dart';
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
  late final String _initialCategoryKey;

  bool _submitting = false;

  static const int _nameMin = 2;
  static const int _nameMax = 60;

  static const double _minPrice = 0.01;
  static const double _maxPrice = 10000;

  static const int _descMin = 10;
  static const int _descMax = 250;

  @override
  void initState() {
    super.initState();
    _initialCategoryKey = FixedServiceCategories.all.first.key;
    _selectedCategoryKey = _initialCategoryKey;

    Future.microtask(() => ref.read(categoriesIdMapProvider.future));
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  bool get _isDirty {
    return _name.text.trim().isNotEmpty ||
        _price.text.trim().isNotEmpty ||
        _desc.text.trim().isNotEmpty ||
        (_selectedCategoryKey != null && _selectedCategoryKey != _initialCategoryKey);
  }

  Future<bool> _confirmDiscardIfDirty() async {
    if (!_isDirty) return true;

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تجاهل التغييرات؟'),
          content: const Text('في تغييرات غير محفوظة، بدك تلغيها؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('متابعة'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightGreen),
              child: const Text('تجاهل', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    return res == true;
  }

  void _doExit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.providerHome);
    }
  }

  Future<void> _exit() async {
    if (!_isDirty) {
      _doExit();
      return;
    }

    final canLeave = await _confirmDiscardIfDirty();
    if (!mounted) return;
    if (canLeave) _doExit();
  }

  String? _validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'اسم الباقة مطلوب';
    if (s.length < _nameMin) return 'اسم الباقة لازم يكون على الأقل $_nameMin أحرف';
    if (s.length > _nameMax) return 'اسم الباقة لازم يكون أقل من $_nameMax حرف';
    return null;
  }

  String? _validatePrice(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'السعر مطلوب';

    final n = double.tryParse(s);
    if (n == null) return 'السعر لازم يكون رقم';

    if (n < _minPrice) return 'السعر لازم يكون أكبر من 0';
    if (n > _maxPrice) return 'السعر كبير جدًا (أقصى حد $_maxPrice)';

    return null;
  }

  String? _validateDesc(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'وصف الباقة مطلوب';
    if (s.length < _descMin) return 'وصف الباقة لازم يكون على الأقل $_descMin أحرف';
    if (s.length > _descMax) return 'وصف الباقة لازم يكون أقل من $_descMax حرف';
    return null;
  }

  String? _serviceKeyOf(ProviderServiceModel s) {
    final k1 = FixedServiceCategories.keyFromAnyString(s.name);
    if (k1 != null) return k1;

    final k2 = FixedServiceCategories.keyFromAnyString(s.categoryOther ?? '');
    if (k2 != null) return k2;

    return null;
  }

  ProviderServiceModel? _serviceForKey(List<ProviderServiceModel> services, String key) {
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

    final key = _selectedCategoryKey!;
    final service = _serviceForKey(services, key);
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

    final price = double.tryParse(_price.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'السعر لازم يكون رقم',
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ حافظنا على packages القديمة بالكامل (features وغيرها) باستخدام toJson()
    final newPackages = [
      for (final p in service.packages) p.toJson(),
      {
        'name': _name.text.trim(),
        'price': price,
        'description': _desc.text.trim(),
      }
    ];

    setState(() => _submitting = true);

    try {
      // ✅ إصلاح CATEGORY_MISMATCH: ثبت category_id أثناء إضافة الباقة
      final idMap = await ref.read(categoriesIdMapProvider.future);
      final categoryId = idMap[key];

      final payload = <String, dynamic>{
        'packages': newPackages,
      };

      if (categoryId != null) {
        payload['category_id'] = categoryId;
        payload['category_other'] = FixedServiceCategories.labelArFromKey(key);
        payload['name'] = key;
      }

      await ApiClient.dio.put(
        ApiConstants.serviceDetails(service.id),
        data: payload,
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

      _doExit();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إضافة الباقة. حاول مرة أخرى.',
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _exit();
      },
      child: Directionality(
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
              icon: const BackButtonIcon(),
              color: AppColors.textPrimary,
              onPressed: _exit,
            ),
          ),
          body: Padding(
            padding: SizeConfig.padding(all: 20),
            child: servicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 52, color: AppColors.textSecondary),
                    SizeConfig.v(10),
                    Text(
                      'تعذر تحميل الخدمات حالياً.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                    ),
                    SizeConfig.v(12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(providerMyServicesProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: SizeConfig.padding(horizontal: 18, vertical: 12),
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: AppTextStyles.body14.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              data: (services) {
                if (_selectedCategoryKey == null) {
                  _selectedCategoryKey = FixedServiceCategories.all.first.key;
                }

                final matchedService = _serviceForKey(services, _selectedCategoryKey!);
                final hasService = matchedService != null;

                if (services.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.design_services_outlined, size: 56, color: AppColors.textSecondary),
                      SizeConfig.v(12),
                      Text(
                        'لا يمكنك إضافة باقة قبل إنشاء خدمة واحدة على الأقل.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                      ),
                      SizeConfig.v(16),
                      ElevatedButton(
                        onPressed: () => context.push(AppRoutes.providerAddService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: SizeConfig.padding(horizontal: 18, vertical: 12),
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
                                  hasService ? Icons.check_circle : Icons.info_outline,
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
                          _input(_name, 'مثال: باقة بريميوم', validator: _validateName),

                          SizeConfig.v(18),
                          _label('السعر (د.أ) *'),
                          _input(_price, 'مثال: 120', keyboardType: TextInputType.number, validator: _validatePrice),

                          SizeConfig.v(18),
                          _label('وصف الباقة *'),
                          _input(_desc, 'صف ما تتضمنه الباقة...', maxLines: 3, validator: _validateDesc),

                          SizeConfig.v(26),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _exit,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: const BorderSide(color: AppColors.buttonBackground),
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
                                    disabledBackgroundColor: AppColors.lightGreen.withValues(alpha: 0.25),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: SizeConfig.padding(vertical: 14),
                                  ),
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
    String? Function(String?)? validator,
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
        validator: validator,
      ),
    );
  }
}
