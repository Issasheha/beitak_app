import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ unified error mapper
import 'package:beitak_app/core/error/error_text.dart';

class ProviderEditServiceView extends ConsumerStatefulWidget {
  final ProviderServiceModel service;
  const ProviderEditServiceView({super.key, required this.service});

  @override
  ConsumerState<ProviderEditServiceView> createState() =>
      _ProviderEditServiceViewState();
}

class _ProviderEditServiceViewState
    extends ConsumerState<ProviderEditServiceView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _serviceName;
  late final TextEditingController _price;
  late final TextEditingController _desc;

  late String _priceType; // hourly | fixed

  // ✅ Dirty tracking
  late final String _initialServiceName;
  late final String _initialPrice;
  late final String _initialDesc;
  late final String _initialPriceType;

  bool _saving = false;

  static const int _nameMin = 2;
  static const int _nameMax = 60;

  static const double _minPrice = 0.01;
  static const double _maxPrice = 10000;

  static const int _descMin = 10;
  static const int _descMax = 250;

  @override
  void initState() {
    super.initState();

    // ✅ أهم تعديل: خذ الاسم من name_ar إذا موجود
    final name = (widget.service.nameAr ?? '').trim().isNotEmpty
        ? widget.service.nameAr!.trim()
        : widget.service.displayNameAr;

    _initialServiceName = name;
    _initialPrice = widget.service.basePrice.toStringAsFixed(0);

    // ✅ خذ الوصف العربي إذا موجود
    final desc = widget.service.displayDescAr;
    _initialDesc = desc;

    _initialPriceType = widget.service.priceType;

    _serviceName = TextEditingController(text: _initialServiceName);
    _price = TextEditingController(text: _initialPrice);
    _desc = TextEditingController(text: _initialDesc);
    _priceType = _initialPriceType;
  }

  @override
  void dispose() {
    _serviceName.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  bool get _isDirty {
    return _serviceName.text.trim() != _initialServiceName.trim() ||
        _price.text.trim() != _initialPrice.trim() ||
        _desc.text.trim() != _initialDesc.trim() ||
        _priceType != _initialPriceType;
  }

  Future<void> _showDialog({
    required String title,
    required String message,
    bool success = false,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: success ? AppColors.lightGreen : Colors.red,
              ),
              child: const Text(
                'تمام',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
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
  String? _validateName(String? v) {
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

  Future<void> _save() async {
    if (_saving) return;
    if (!_isDirty) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);

    try {
      final basePrice = double.tryParse(_price.text.trim()) ?? 0;

      final nameAr = _serviceName.text.trim();
      final descAr = _desc.text.trim();

      // ✅ إرسال name_ar + احتياط name/name_en حتى ما يظل UI يقرأ القديم بأي مكان
      final payload = <String, dynamic>{
        'name_ar': nameAr,
        'name_en': nameAr, // احتياط
        'name': nameAr, // احتياط (لو الباك ما يعكس إلا name)

        'description_ar': descAr,
        'description_en': descAr, // احتياط
        'description': descAr,

        'base_price': basePrice,
        'price_type': _priceType,
      };

      await ApiClient.dio.put(
        ApiConstants.serviceDetails(widget.service.id),
        data: payload,
        options: Options(contentType: Headers.jsonContentType),
      );

      ref.invalidate(providerMyServicesProvider);

      if (!mounted) return;

      await _showDialog(
        title: 'تم بنجاح',
        message: 'تم حفظ تعديل الخدمة بنجاح',
        success: true,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (err) {
      if (!mounted) return;
      final msg = errorText(err);

      await _showDialog(
        title: 'تعذر الحفظ',
        message: msg,
        success: false,
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final canLeave = await _confirmDiscardIfDirty();
        if (!context.mounted) return;

        if (canLeave) {
          Navigator.of(context).pop(false);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text('تعديل الخدمة',
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
                      _label('اسم الخدمة *'),
                      _input(_serviceName, 'مثال: صيانة جوالات',
                          validator: _validateName),
                      SizeConfig.v(10),
                      _label('نوع السعر'),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('بالساعة'),
                            selected: _priceType == 'hourly',
                            selectedColor: AppColors.lightGreen,
                            labelStyle: TextStyle(
                              color: _priceType == 'hourly'
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (_) =>
                                setState(() => _priceType = 'hourly'),
                          ),
                          ChoiceChip(
                            label: const Text('ثابت'),
                            selected: _priceType == 'fixed',
                            selectedColor: AppColors.lightGreen,
                            labelStyle: TextStyle(
                              color: _priceType == 'fixed'
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (_) =>
                                setState(() => _priceType = 'fixed'),
                          ),
                        ],
                      ),
                      SizeConfig.v(16),
                      _label('السعر (د.أ) *'),
                      _input(_price, 'مثال: 50',
                          keyboardType: TextInputType.number,
                          validator: _validatePrice),
                      SizeConfig.v(16),
                      _label('الوصف *'),
                      _input(_desc, 'عدّل وصف الخدمة...',
                          maxLines: 4, validator: _validateDesc),
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
      onChanged: (_) => setState(() {}), // ✅ لتحديث زر حفظ (dirty)
    );
  }
}
