// lib/features/provider/home/presentation/views/add_service_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/providers/categories_id_map_provider.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddServiceView extends ConsumerStatefulWidget {
  const AddServiceView({super.key});

  @override
  ConsumerState<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends ConsumerState<AddServiceView> {
  final _formKey = GlobalKey<FormState>();

  // ✅ Service Name field (فاضي + فقط hint)
  final _serviceName = TextEditingController();

  final _price = TextEditingController();
  final _desc = TextEditingController();

  String? _selectedCategoryKey; // key ثابت
  late final String _initialCategoryKey;

  String _priceType = 'hourly'; // hourly | fixed
  late final String _initialPriceType;

  bool _submitting = false;

  // نفس قواعد صفحة التعديل
  static const double _minPrice = 0.01;
  static const double _maxPrice = 10000;

  static const int _descMin = 10;
  static const int _descMax = 250;

  // service name limits
  static const int _nameMin = 2;
  static const int _nameMax = 50;

  @override
  void initState() {
    super.initState();
    _initialCategoryKey = FixedServiceCategories.all.first.key;
    _selectedCategoryKey = _initialCategoryKey;
    _initialPriceType = _priceType;

    // ✅ مهم: لا نعبّي الاسم أبداً (بس hint)
    _serviceName.clear();
  }

  @override
  void dispose() {
    _serviceName.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  String _labelFromKey(String k) => FixedServiceCategories.labelArFromKey(k);

  bool get _isDirty {
    return _serviceName.text.trim().isNotEmpty ||
        _price.text.trim().isNotEmpty ||
        _desc.text.trim().isNotEmpty ||
        (_selectedCategoryKey != null &&
            _selectedCategoryKey != _initialCategoryKey) ||
        _priceType != _initialPriceType;
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

  String? _validateServiceName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'اسم الخدمة مطلوب';
    if (s.length < _nameMin) {
      return 'اسم الخدمة لازم يكون على الأقل $_nameMin أحرف';
    }
    if (s.length > _nameMax) return 'اسم الخدمة لازم يكون أقل من $_nameMax حرف';
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
    if (s.isEmpty) return 'الوصف مطلوب';
    if (s.length < _descMin) return 'الوصف لازم يكون على الأقل $_descMin أحرف';
    if (s.length > _descMax) return 'الوصف لازم يكون أقل من $_descMax حرف';
    return null;
  }

  // ===== Save =====

  Future<void> _save() async {
    if (_submitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final key = _selectedCategoryKey;
    if (key == null) {
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
      final idMap = await ref.read(categoriesIdMapProvider.future);
      final categoryId = idMap[key];

      if (categoryId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر تحديد رقم الفئة (category_id). حدّث البيانات/جرّب مرة ثانية.',
              style: AppTextStyles.body14.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final basePrice = double.tryParse(_price.text.trim()) ?? 0;

      final serviceName = _serviceName.text.trim();
      final categoryOther = _labelFromKey(key);

      final data = <String, dynamic>{
        'category_id': categoryId,
        'category_other': categoryOther,

        // ✅ من الحقل فقط (بدون تعبئة مسبقة)
        'name': key, // internal key ثابت (متوافق مع النظام)
        'name_ar': serviceName, // ✅ اسم المستخدم العربي
        'name_en': key, // احتياط

        'description': _desc.text.trim(),
        'description_ar': _desc.text.trim(),
        'description_en': _desc.text.trim(),

        'base_price': basePrice,
        'price_type': _priceType,

        'packages': [],
        'add_ons': [],
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

      _doExit();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إنشاء الخدمة. حاول مرة أخرى.',
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
              icon: const BackButtonIcon(),
              color: AppColors.textPrimary,
              onPressed: _exit,
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
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            selectedColor: AppColors.lightGreen,
                            onSelected: (v) {
                              setState(() {
                                _selectedCategoryKey = v ? c.key : null;
                                // ✅ لا تغيّر اسم الخدمة أبداً (بس hint)
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizeConfig.v(18),
                      _label('اسم الخدمة *'),
                      _input(
                        _serviceName,
                        'مثال: تنظيف شقق / صيانة مكيفات...',
                        validator: _validateServiceName,
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
                        validator: _validatePrice,
                      ),
                      SizeConfig.v(18),
                      _label('الوصف *'),
                      _input(
                        _desc,
                        'اشرح تفاصيل الخدمة...',
                        maxLines: 4,
                        validator: _validateDesc,
                      ),
                      SizeConfig.v(26),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: SizeConfig.padding(vertical: 14),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
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
                          SizeConfig.hSpace(12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _exit,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
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
    String? Function(String?)? validator,
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
      validator:
          validator ?? (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
    );
  }
}
