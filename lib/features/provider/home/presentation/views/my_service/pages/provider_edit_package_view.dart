import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderEditPackageView extends ConsumerStatefulWidget {
  final ProviderServiceModel service;
  final int packageIndex;

  const ProviderEditPackageView({
    super.key,
    required this.service,
    required this.packageIndex,
  });

  @override
  ConsumerState<ProviderEditPackageView> createState() => _ProviderEditPackageViewState();
}

class _ProviderEditPackageViewState extends ConsumerState<ProviderEditPackageView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _desc;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final pkg = widget.service.packages[widget.packageIndex];
    _name = TextEditingController(text: pkg.name);
    _price = TextEditingController(text: pkg.price.toStringAsFixed(0));
    _desc = TextEditingController(text: pkg.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);

    try {
      final newPrice = double.parse(_price.text.trim());

      // ✅ ننسخ كل الباقات ونعدل وحدة فقط، ونحافظ على features القديمة
      final updatedPackages = widget.service.packages.map((p) => p.toJson()).toList();

      final old = widget.service.packages[widget.packageIndex];
      final updated = old.copyWith(
        name: _name.text.trim(),
        price: newPrice,
        description: _desc.text.trim(),
      );

      updatedPackages[widget.packageIndex] = updated.toJson();

      await ApiClient.dio.put(
        ApiConstants.serviceDetails(widget.service.id),
        data: {'packages': updatedPackages},
        options: Options(contentType: Headers.jsonContentType),
      );

      ref.invalidate(providerMyServicesProvider);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تعديل الباقة: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('تعديل الباقة', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(false),
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
                  _label('اسم الباقة'),
                  _input(_name, 'مثال: باقة بريميوم'),

                  SizeConfig.v(16),
                  _label('السعر (د.أ)'),
                  _input(_price, 'مثال: 120', keyboardType: TextInputType.number),

                  SizeConfig.v(16),
                  _label('الوصف'),
                  _input(_desc, 'عدّل وصف الباقة...', maxLines: 3),

                  SizeConfig.v(26),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.lightGreen,
                            side: const BorderSide(color: AppColors.lightGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: SizeConfig.padding(vertical: 12),
                          ),
                          child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: SizeConfig.padding(vertical: 12),
                          ),
                          child: _saving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('حفظ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.ts(14), color: AppColors.textPrimary)),
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
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
    );
  }
}
