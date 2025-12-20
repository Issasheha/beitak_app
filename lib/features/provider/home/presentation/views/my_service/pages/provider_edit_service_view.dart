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

class ProviderEditServiceView extends ConsumerStatefulWidget {
  final ProviderServiceModel service;
  const ProviderEditServiceView({super.key, required this.service});

  @override
  ConsumerState<ProviderEditServiceView> createState() => _ProviderEditServiceViewState();
}

class _ProviderEditServiceViewState extends ConsumerState<ProviderEditServiceView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _price;
  late final TextEditingController _desc;

  late String _priceType; // hourly | fixed

  // ✅ Dirty tracking
  late final String _initialPrice;
  late final String _initialDesc;
  late final String _initialPriceType;

  bool _saving = false;

  static const double _minPrice = 0.01;
  static const double _maxPrice = 10000;

  static const int _descMin = 10;
  static const int _descMax = 250;

  @override
  void initState() {
    super.initState();

    _initialPrice = widget.service.basePrice.toStringAsFixed(0);
    _initialDesc = (widget.service.description ?? '');
    _initialPriceType = widget.service.priceType;

    _price = TextEditingController(text: _initialPrice);
    _desc = TextEditingController(text: _initialDesc);
    _priceType = _initialPriceType;

    // ✅ سخّن ماب التصنيفات (اختياري)
    Future.microtask(() => ref.read(categoriesIdMapProvider.future));
  }

  @override
  void dispose() {
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  bool get _isDirty {
    return _price.text.trim() != _initialPrice.trim() ||
        _desc.text.trim() != _initialDesc.trim() ||
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
              child: const Text('متابعة التعديل'),
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

  String? _serviceKey() {
    final k1 = FixedServiceCategories.keyFromAnyString(widget.service.name);
    if (k1 != null) return k1;

    final k2 = FixedServiceCategories.keyFromAnyString(widget.service.categoryOther ?? '');
    if (k2 != null) return k2;

    return null;
  }

  Future<void> _save() async {
    if (_saving) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);

    try {
      final basePrice = double.tryParse(_price.text.trim()) ?? 0;

      final payload = <String, dynamic>{
        'base_price': basePrice,
        'price_type': _priceType,
        'description': _desc.text.trim(),
      };

      // ✅ إصلاح CATEGORY_MISMATCH: نثبت category_id عند أي تعديل
      final key = _serviceKey();
      if (key != null) {
        final idMap = await ref.read(categoriesIdMapProvider.future);
        final categoryId = idMap[key];
        if (categoryId != null) {
          payload['category_id'] = categoryId;
          payload['category_other'] = FixedServiceCategories.labelArFromKey(key);
          payload['name'] = key; // ✅ name ثابت
        }
      }

      await ApiClient.dio.put(
        ApiConstants.serviceDetails(widget.service.id),
        data: payload,
        options: Options(contentType: Headers.jsonContentType),
      );

      ref.invalidate(providerMyServicesProvider);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ التعديل. حاول مرة أخرى.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
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
            title: const Text('تعديل الخدمة', style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('نوع السعر'),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('بالساعة'),
                          selected: _priceType == 'hourly',
                          selectedColor: AppColors.lightGreen,
                          labelStyle: TextStyle(
                            color: _priceType == 'hourly' ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (_) => setState(() => _priceType = 'hourly'),
                        ),
                        ChoiceChip(
                          label: const Text('ثابت'),
                          selected: _priceType == 'fixed',
                          selectedColor: AppColors.lightGreen,
                          labelStyle: TextStyle(
                            color: _priceType == 'fixed' ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (_) => setState(() => _priceType = 'fixed'),
                        ),
                      ],
                    ),

                    SizeConfig.v(16),
                    _label('السعر (د.أ)'),
                    _input(
                      _price,
                      'مثال: 25',
                      keyboardType: TextInputType.number,
                      validator: _validatePrice,
                    ),

                    SizeConfig.v(16),
                    _label('الوصف'),
                    _input(
                      _desc,
                      'عدّل وصف الخدمة...',
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: SizeConfig.padding(vertical: 12),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'حفظ',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
                              side: const BorderSide(color: AppColors.lightGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: SizeConfig.padding(vertical: 12),
                            ),
                            child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.w700)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }
}
