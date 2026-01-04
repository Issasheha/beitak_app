import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/providers/categories_id_map_provider.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ unified error mapper
import 'package:beitak_app/core/error/error_text.dart';

class ProviderEditPackageView extends ConsumerStatefulWidget {
  final ProviderServiceModel service;
  final int packageIndex;

  const ProviderEditPackageView({
    super.key,
    required this.service,
    required this.packageIndex,
  });

  @override
  ConsumerState<ProviderEditPackageView> createState() =>
      _ProviderEditPackageViewState();
}

class _ProviderEditPackageViewState
    extends ConsumerState<ProviderEditPackageView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _customName;
  late final TextEditingController _price;
  late final TextEditingController _desc;

  final List<TextEditingController> _featuresCtrls = [];

  // ✅ Dirty tracking
  late final String _initialSelectedType;
  late final String _initialCustomName;
  late final String _initialPrice;
  late final String _initialDesc;
  late final List<String> _initialFeatures;

  bool _saving = false;

  static const int _nameMin = 2;
  static const int _nameMax = 60;

  static const double _minPrice = 0.01;
  static const double _maxPrice = 10000;

  static const int _descMin = 10;
  static const int _descMax = 250;

  static const int _featureMin = 3;
  static const int _featureMax = 60;

  static const String _tStandard = 'standard';
  static const String _tPremium = 'premium';
  static const String _tEmergency = 'emergency';
  static const String _tCustom = 'custom';

  String _selectedType = _tStandard;

  @override
  void initState() {
    super.initState();
    final pkg = widget.service.packages[widget.packageIndex];

    _selectedType = _detectTypeFromName(pkg.name);
    _initialSelectedType = _selectedType;

    _initialCustomName = pkg.name;
    _initialPrice = pkg.price.toStringAsFixed(0);
    _initialDesc = (pkg.description ?? '');

    _customName = TextEditingController(text: _initialCustomName);
    _price = TextEditingController(text: _initialPrice);
    _desc = TextEditingController(text: _initialDesc);

    final features = (pkg.features)
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _initialFeatures = List<String>.from(features);

    final initial = features.isEmpty ? [''] : features;
    for (final f in initial) {
      _featuresCtrls.add(TextEditingController(text: f));
    }

    if (_selectedType != _tCustom) {
      _customName.text = _typeNameAr(_selectedType);
    }

    Future.microtask(() => ref.read(categoriesIdMapProvider.future));
  }

  @override
  void dispose() {
    _customName.dispose();
    _price.dispose();
    _desc.dispose();
    for (final c in _featuresCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // ===== Helpers =====
  String _normalize(String s) => s.trim().toLowerCase().replaceAll(' ', '');

  String _detectTypeFromName(String name) {
    final n = _normalize(name);
    if (n.isEmpty) return _tCustom;

    final standardAliases = <String>[
      'standard',
      'ستاندرد',
      'ستاندر',
      'عادي',
      'أساسي',
      'اساسي'
    ];
    final premiumAliases = <String>['premium', 'بريميوم', 'مميز', 'مميّز'];
    final emergencyAliases = <String>[
      'emergency',
      'طوارئ',
      'عاجل',
      'طارئة',
      'طارئ'
    ];

    if (standardAliases.any((a) => _normalize(a) == n)) return _tStandard;
    if (premiumAliases.any((a) => _normalize(a) == n)) return _tPremium;
    if (emergencyAliases.any((a) => _normalize(a) == n)) return _tEmergency;

    return _tCustom;
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
        return 'مخصص';
    }
  }

  String _typeNameAr(String t) => _typeTitleAr(t);

  String _typeSubtitleAr(String t) {
    switch (t) {
      case _tStandard:
        return 'باقة أساسية بخدمات ضرورية';
      case _tPremium:
        return 'باقة مميزة بخدمات إضافية';
      case _tEmergency:
        return 'باقة خدمة طارئة/عاجلة';
      default:
        return 'اسم مخصص';
    }
  }

  bool _typeAlreadyExists(String type) {
    for (int i = 0; i < widget.service.packages.length; i++) {
      if (i == widget.packageIndex) continue;
      final other = widget.service.packages[i];
      final otherType = _detectTypeFromName(other.name);
      if (otherType == type) return true;
    }
    return false;
  }

  List<String> get _featuresNow => _featuresCtrls
      .map((c) => c.text.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  bool get _isDirty {
    final typeChanged = _selectedType != _initialSelectedType;
    final priceChanged = _price.text.trim() != _initialPrice.trim();
    final descChanged = _desc.text.trim() != _initialDesc.trim();

    final nameChanged = _selectedType == _tCustom
        ? _customName.text.trim() != _initialCustomName.trim()
        : (_typeNameAr(_selectedType) != _initialCustomName.trim());

    final nowF = _featuresNow;
    final initF = _initialFeatures;

    final featuresChanged = nowF.length != initF.length ||
        List.generate(nowF.length, (i) => i)
            .any((i) => i >= initF.length || nowF[i] != initF[i]);

    return typeChanged ||
        priceChanged ||
        descChanged ||
        nameChanged ||
        featuresChanged;
  }

  Future<void> _showSuccessDialog(String msg) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تم بنجاح'),
          content: Text(msg),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen),
              child: const Text('تمام',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
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
              child: const Text('متابعة التعديل'),
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

  // ===== Validators =====
  String? _validateCustomName(String? v) {
    if (_selectedType != _tCustom) return null;

    final s = (v ?? '').trim();
    if (s.isEmpty) return 'اسم الباقة مطلوب';
    if (s.length < _nameMin) {
      return 'اسم الباقة لازم يكون على الأقل $_nameMin أحرف';
    }
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
    if (s.length < _descMin) {
      return 'وصف الباقة لازم يكون على الأقل $_descMin أحرف';
    }
    if (s.length > _descMax) return 'وصف الباقة لازم يكون أقل من $_descMax حرف';
    return null;
  }

  String? _validateFeatures() {
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

  String? _serviceKey() {
    final k1 = FixedServiceCategories.keyFromAnyString(widget.service.name);
    if (k1 != null) return k1;

    final k2 = FixedServiceCategories.keyFromAnyString(
        widget.service.categoryOther ?? '');
    if (k2 != null) return k2;

    return null;
  }

  void _addFeature() =>
      setState(() => _featuresCtrls.add(TextEditingController()));

  void _removeFeature(int index) {
    if (_featuresCtrls.length <= 1) {
      _featuresCtrls.first.clear();
      setState(() {});
      return;
    }
    final c = _featuresCtrls.removeAt(index);
    c.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_isDirty) return; // ✅ ممنوع حفظ بدون تغييرات

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final featuresError = _validateFeatures();
    if (featuresError != null) {
      // ✅ نخليها تحت الحقل؟ (لسا عندك validator على كل input)
      // هنا بنخلي رسالة عامة Dialog أفضل من SnackBar
      await _showSuccessDialog(featuresError);
      return;
    }

    if (_selectedType != _tCustom && _typeAlreadyExists(_selectedType)) {
      await _showSuccessDialog('هذا النوع موجود مسبقاً داخل الخدمة.');
      return;
    }

    setState(() => _saving = true);

    try {
      final newPrice = double.tryParse(_price.text.trim()) ?? 0;

      final updatedPackages =
          widget.service.packages.map((p) => p.toJson()).toList();
      final old = widget.service.packages[widget.packageIndex];

      final newName = _selectedType == _tCustom
          ? _customName.text.trim()
          : _typeNameAr(_selectedType);

      final updated = old.copyWith(
        name: newName,
        price: newPrice,
        description: _desc.text.trim(),
      );

      final updatedJson = updated.toJson();
      updatedJson['features'] = _featuresNow;

      updatedPackages[widget.packageIndex] = updatedJson;

      final payload = <String, dynamic>{
        'packages': updatedPackages,
      };

      final key = _serviceKey();
      if (key != null) {
        final idMap = await ref.read(categoriesIdMapProvider.future);
        final categoryId = idMap[key];
        if (categoryId != null) {
          payload['category_id'] = categoryId;
          payload['category_other'] =
              FixedServiceCategories.labelArFromKey(key);
          payload['name'] = key;
        }
      }

      await ApiClient.dio.put(
        ApiConstants.serviceDetails(widget.service.id),
        data: payload,
        options: Options(contentType: Headers.jsonContentType),
      );

      // ✅ تحديث القائمة قبل الرجوع
      ref.invalidate(providerMyServicesProvider);

      // ✅ Dialog نجاح واضح
      await _showSuccessDialog('تم حفظ تعديل الباقة بنجاح');

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (err) {
      if (!mounted) return;
      final msg = errorText(err);

      await _showSuccessDialog(msg);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canLeave = await _confirmDiscardIfDirty();
        if (!context.mounted) return;
        if (canLeave) Navigator.of(context).pop(false);
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text('تعديل الباقة',
                style: TextStyle(fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const BackButtonIcon(),
              color: AppColors.textPrimary,
              onPressed: () async {
                final canLeave = await _confirmDiscardIfDirty();
                if (!context.mounted) return;
                if (canLeave) Navigator.of(context).pop(false);
              },
            ),
          ),
          body: Padding(
            padding: SizeConfig.padding(all: 20),
            child: AbsorbPointer(
              absorbing: _saving,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('نوع الباقة *'),
                      SizeConfig.v(8),
                      _typeSelector(),
                      if (_selectedType == _tCustom) ...[
                        SizeConfig.v(16),
                        _label('اسم الباقة *'),
                        _input(_customName, 'مثال: باقة خاصة',
                            validator: _validateCustomName),
                      ],
                      SizeConfig.v(16),
                      _label('السعر (د.أ) *'),
                      _input(
                        _price,
                        'مثال: 150',
                        keyboardType: TextInputType.number,
                        validator: _validatePrice,
                      ),
                      SizeConfig.v(16),
                      _label('الوصف *'),
                      _input(_desc, 'اشرح تفاصيل الباقة...',
                          maxLines: 3, validator: _validateDesc),
                      SizeConfig.v(16),
                      _featuresSection(),
                      SizeConfig.v(26),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (!_isDirty || _saving) ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGreen,
                                disabledBackgroundColor: AppColors.lightGreen
                                    .withValues(alpha: 0.25),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                padding: SizeConfig.padding(vertical: 12),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'حفظ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final canLeave = await _confirmDiscardIfDirty();
                                if (!context.mounted) return;
                                if (canLeave) Navigator.of(context).pop(false);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.lightGreen,
                                side: const BorderSide(
                                    color: AppColors.lightGreen),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                padding: SizeConfig.padding(vertical: 12),
                              ),
                              child: const Text('إلغاء',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
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
      ),
    );
  }

  Widget _typeSelector() {
    Widget card(String type) {
      final selected = _selectedType == type;
      final exists = type != _tCustom && _typeAlreadyExists(type);

      return Expanded(
        child: GestureDetector(
          onTap: exists
              ? null
              : () => setState(() {
                    _selectedType = type;
                    if (type != _tCustom) _customName.text = _typeNameAr(type);
                  }),
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: exists
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
                    color: exists
                        ? AppColors.textSecondary.withValues(alpha: 0.7)
                        : AppColors.textSecondary,
                  ),
                ),
                if (exists) ...[
                  const SizedBox(height: 8),
                  const Text('موجودة مسبقاً',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w800)),
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

  Widget _featuresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _label('الخدمات/الميزات المشمولة *')),
            TextButton.icon(
              onPressed: _addFeature,
              icon: const Icon(Icons.add, color: AppColors.lightGreen),
              label: const Text('إضافة ميزة',
                  style: TextStyle(
                      color: AppColors.lightGreen,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'أدخل الخدمات أو الميزات الموجودة داخل هذه الباقة (ميزة واحدة على الأقل).',
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: SizeConfig.ts(12.5),
              height: 1.3),
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          t,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.ts(14),
            color: AppColors.textPrimary,
          ),
        ),
      );

  Widget _input(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }
}
