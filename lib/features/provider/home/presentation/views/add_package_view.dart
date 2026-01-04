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

// ✅ NEW: use your unified error mapper
import 'package:beitak_app/core/error/error_text.dart';

class AddPackageView extends ConsumerStatefulWidget {
  const AddPackageView({super.key});

  @override
  ConsumerState<AddPackageView> createState() => _AddPackageViewState();
}

class _AddPackageViewState extends ConsumerState<AddPackageView> {
  final _formKey = GlobalKey<FormState>();

  final _price = TextEditingController();
  final _desc = TextEditingController();
  final List<TextEditingController> _featuresCtrls = [];

  // ✅ NEW: Service selection (Service Name)
  int? _selectedServiceId;

  bool _submitting = false;

  static const double _minPrice = 0.01;
  static const double _maxPrice = 10000;

  static const int _descMin = 10;
  static const int _descMax = 250;

  static const int _featureMin = 3;
  static const int _featureMax = 60;

  // types
  static const String _tStandard = 'standard';
  static const String _tPremium = 'premium';
  static const String _tEmergency = 'emergency';

  String _selectedType = _tEmergency;
  late final String _initialType;

  // ✅ NEW: to show error under features section
  FormFieldState<List<String>>? _featuresFieldState;

  @override
  void initState() {
    super.initState();
    _initialType = _selectedType;

    _featuresCtrls.add(TextEditingController());

    // (اختياري) تجهيز id map لو حبيت تستخدمه لاحقاً
    Future.microtask(() => ref.read(categoriesIdMapProvider.future));
  }

  @override
  void dispose() {
    _price.dispose();
    _desc.dispose();
    for (final c in _featuresCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  String _normalize(String s) => s.trim().toLowerCase().replaceAll(' ', '');

  String _detectTypeFromName(String name) {
    final n = _normalize(name);
    if (n.isEmpty) return '';

    final standardAliases = <String>[
      'standard',
      'ستاندرد',
      'ستاندر',
      'عادي',
      'أساسي',
      'اساسي',
    ];
    final premiumAliases = <String>[
      'premium',
      'بريميوم',
      'مميز',
      'مميّز',
    ];
    final emergencyAliases = <String>[
      'emergency',
      'طوارئ',
      'عاجل',
      'طارئة',
      'طارئ',
    ];

    if (standardAliases.any((a) => _normalize(a) == n)) return _tStandard;
    if (premiumAliases.any((a) => _normalize(a) == n)) return _tPremium;
    if (emergencyAliases.any((a) => _normalize(a) == n)) return _tEmergency;

    return '';
  }

  String _typeTitleAr(String t) {
    switch (t) {
      case _tStandard:
        return 'عادي';
      case _tPremium:
        return 'مميز';
      case _tEmergency:
        return 'مستعجل';
      default:
        return t;
    }
  }

  String _typeSubtitleAr(String t) {
    switch (t) {
      case _tStandard:
        return 'باقة أساسية بخدمات ضرورية';
      case _tPremium:
        return 'باقة مميزة بخدمات إضافية';
      case _tEmergency:
        return 'باقة خدمة طارئة/عاجلة';
      default:
        return '';
    }
  }

  bool _typeExistsInService(ProviderServiceModel service, String type) {
    for (final p in service.packages) {
      final t = _detectTypeFromName(p.name);
      if (t == type) return true;
    }
    return false;
  }

  List<String> get _featuresNow => _featuresCtrls
      .map((c) => c.text.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  bool get _isDirty {
    return _price.text.trim().isNotEmpty ||
        _desc.text.trim().isNotEmpty ||
        _featuresNow.isNotEmpty ||
        _selectedServiceId != null ||
        _selectedType != _initialType;
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen),
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

  // ===== Validators =====

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
    if (s.length < _descMin) {
      return 'وصف الباقة لازم يكون على الأقل $_descMin أحرف';
    }
    if (s.length > _descMax) return 'وصف الباقة لازم يكون أقل من $_descMax حرف';
    return null;
  }

  String? _validateFeaturesInline() {
    final list = _featuresNow;
    if (list.isEmpty) return 'أضف ميزة واحدة على الأقل';

    for (final f in list) {
      if (f.length < _featureMin) {
        return 'كل ميزة لازم تكون على الأقل $_featureMin أحرف';
      }
      if (f.length > _featureMax) {
        return 'كل ميزة لازم تكون أقل من $_featureMax حرف';
      }
    }
    return null;
  }

  // ✅ Arabic service name (priority: categoryOther -> fixed map -> fallback)
  String _serviceDisplayName(ProviderServiceModel s) {
    final ar = (s.categoryOther ?? '').trim();
    if (ar.isNotEmpty) return ar;

    final key = FixedServiceCategories.keyFromAnyString(s.name) ??
        FixedServiceCategories.keyFromAnyString(s.categoryOther ?? '');
    if (key != null) {
      final labelAr = FixedServiceCategories.labelArFromKey(key);
      if (labelAr.trim().isNotEmpty) return labelAr.trim();
    }

    final n = s.name.trim();
    if (n.isNotEmpty) return n;

    return 'خدمة #${s.id}';
  }

  void _addFeature() {
    setState(() => _featuresCtrls.add(TextEditingController()));
    _featuresFieldState?.validate(); // ✅ لو في error، ينشال/يتحدث مباشرة
  }

  void _removeFeature(int index) {
    if (_featuresCtrls.length <= 1) {
      _featuresCtrls.first.clear();
      setState(() {});
      _featuresFieldState?.validate();
      return;
    }
    final c = _featuresCtrls.removeAt(index);
    c.dispose();
    setState(() {});
    _featuresFieldState?.validate();
  }

  Future<void> _save(List<ProviderServiceModel> services) async {
    if (_submitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    final featuresOk = _featuresFieldState?.validate() ?? true;
    if (!valid || !featuresOk) return;

    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اختر الخدمة أولاً',
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final service = services.firstWhere(
      (s) => s.id == _selectedServiceId,
      orElse: () => services.first,
    );

    // منع تكرار النوع داخل نفس الخدمة
    if (_typeExistsInService(service, _selectedType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا النوع موجود مسبقاً داخل الخدمة.'),
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

    final newPackages = [
      for (final p in service.packages) p.toJson(),
      {
        'name': _typeTitleAr(_selectedType),
        'price': price,
        'description': _desc.text.trim(),
        'features': _featuresNow,
      }
    ];

    setState(() => _submitting = true);

    try {
      final payload = <String, dynamic>{
        'packages': newPackages,
      };

      await ApiClient.dio.put(
        ApiConstants.serviceDetails(service.id),
        data: payload,
        options: Options(contentType: Headers.jsonContentType),
      );

      ref.invalidate(providerMyServicesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة الباقة بنجاح'),
          backgroundColor: AppColors.lightGreen,
        ),
      );

      _doExit();
    } catch (err) {
      if (!mounted) return;

      final msg = errorText(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
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
      onPopInvokedWithResult: (didPop, result) async {
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
                child: Text(
                  'تعذر تحميل الخدمات حالياً.',
                  style: AppTextStyles.body14
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              data: (services) {
                if (services.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.design_services_outlined,
                          size: 56, color: AppColors.textSecondary),
                      SizeConfig.v(12),
                      Text(
                        'لا يمكنك إضافة باقة قبل إنشاء خدمة واحدة على الأقل.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body14
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      SizeConfig.v(16),
                      ElevatedButton(
                        onPressed: () =>
                            context.push(AppRoutes.providerAddService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding:
                              SizeConfig.padding(horizontal: 18, vertical: 12),
                        ),
                        child: Text(
                          'إنشاء خدمة أولاً',
                          style: AppTextStyles.body14
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }

                // ✅ init default selection once
                _selectedServiceId ??= services.first.id;

                final selectedService = services.firstWhere(
                  (s) => s.id == _selectedServiceId,
                  orElse: () => services.first,
                );

                return SingleChildScrollView(
                  child: AbsorbPointer(
                    absorbing: _submitting,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Service Name (Arabic)
                          _label('اسم الخدمة *'),
                          SizeConfig.v(6),
                          _serviceDropdown(services),

                          SizeConfig.v(12),
                          Container(
                            width: double.infinity,
                            padding: SizeConfig.padding(all: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.lightGreen
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: AppColors.lightGreen),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'سيتم إضافة الباقة داخل: ${_serviceDisplayName(selectedService)}',
                                    style: AppTextStyles.body14.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizeConfig.v(18),
                          _label('نوع الباقة *'),
                          SizeConfig.v(8),
                          _typeSelector(selectedService),

                          SizeConfig.v(18),
                          _label('السعر (د.أ) *'),
                          _input(
                            _price,
                            'مثال: 150',
                            keyboardType: TextInputType.number,
                            validator: _validatePrice,
                          ),

                          SizeConfig.v(18),
                          _label('وصف الباقة *'),
                          _input(
                            _desc,
                            'صف ما تتضمنه الباقة...',
                            maxLines: 3,
                            validator: _validateDesc,
                          ),

                          // ✅ Features with inline error under section
                          FormField<List<String>>(
                            initialValue: _featuresNow,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (_) => _validateFeaturesInline(),
                            builder: (state) {
                              _featuresFieldState = state;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizeConfig.v(10),
                                  _featuresSection(
                                    onChanged: () {
                                      state.didChange(_featuresNow);
                                      state.validate();
                                    },
                                  ),
                                  if (state.hasError) ...[
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Text(
                                        state.errorText ?? '',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: SizeConfig.ts(12.5),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),

                          SizeConfig.v(26),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _save(services),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lightGreen,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: SizeConfig.padding(vertical: 14),
                                  ),
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
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
                              SizeConfig.hSpace(12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _exit,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    side: const BorderSide(
                                        color: AppColors.buttonBackground),
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

  Widget _serviceDropdown(List<ProviderServiceModel> services) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedServiceId,
          isExpanded: true,
          items: services
              .map(
                (s) => DropdownMenuItem<int>(
                  value: s.id,
                  child: Text(
                    _serviceDisplayName(s), // ✅ Arabic
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedServiceId = v),
        ),
      ),
    );
  }

  Widget _typeSelector(ProviderServiceModel? service) {
    bool exists(String type) {
      if (service == null) return false;
      return _typeExistsInService(service, type);
    }

    Widget card(String type) {
      final selected = _selectedType == type;
      final already = exists(type);

      return Expanded(
        child: GestureDetector(
          onTap: already ? null : () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.lightGreen
                    : Colors.black.withValues(alpha: 0.08),
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _typeTitleAr(type),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: already
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _typeSubtitleAr(type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(12),
                    color: already
                        ? AppColors.textSecondary.withValues(alpha: 0.7)
                        : AppColors.textSecondary,
                  ),
                ),
                if (already) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'موجودة مسبقاً',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        card(_tStandard),
        const SizedBox(width: 10),
        card(_tPremium),
        const SizedBox(width: 10),
        card(_tEmergency),
      ],
    );
  }

  Widget _featuresSection({required VoidCallback onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _label('الخدمات/الميزات المشمولة *')),
            TextButton.icon(
              onPressed: _addFeature,
              icon: const Icon(Icons.add, color: AppColors.lightGreen),
              label: const Text(
                'إضافة ميزة',
                style: TextStyle(
                    color: AppColors.lightGreen, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'أدخل الخدمات أو الميزات الموجودة داخل هذه الباقة (ميزة واحدة على الأقل).',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: SizeConfig.ts(12.5),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          itemCount: _featuresCtrls.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            return Row(
              children: [
                Expanded(
                  child: _input(
                    _featuresCtrls[i],
                    'مثال: تنظيف عميق، غسيل شبابيك',
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return null;
                      if (s.length < _featureMin) return 'قصيرة جداً';
                      if (s.length > _featureMax) return 'طويلة جداً';
                      return null;
                    },
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _removeFeature(i),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            );
          },
        ),
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
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
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
        validator: validator,
      ),
    );
  }
}
