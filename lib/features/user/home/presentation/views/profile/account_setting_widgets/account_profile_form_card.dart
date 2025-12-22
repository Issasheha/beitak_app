import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/user/home/domain/entities/user_profile_entity.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/viewmodels/profile_providers.dart';

class AccountProfileFormCard extends ConsumerStatefulWidget {
  const AccountProfileFormCard({super.key, required this.profile});
  final UserProfileEntity? profile;

  @override
  ConsumerState<AccountProfileFormCard> createState() => _AccountProfileFormCardState();
}

class _AccountProfileFormCardState extends ConsumerState<AccountProfileFormCard> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController fullNameC;
  late final TextEditingController emailC;
  late final TextEditingController phoneC;

  @override
  void initState() {
    super.initState();

    final p = widget.profile;
    fullNameC = TextEditingController(text: (p?.name ?? '').trim());
    emailC = TextEditingController(text: (p?.email ?? '').trim());

    // ✅ اعرض الرقم محلي (07x...) حتى لو جاي من الباك +962...
    phoneC = TextEditingController(text: _toLocalJordanPhone(p?.phone ?? ''));
  }

  @override
  void didUpdateWidget(covariant AccountProfileFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ لو البروفايل إجا بعد ما الصفحة انبنت
    if (oldWidget.profile == null && widget.profile != null) {
      final p = widget.profile!;
      fullNameC.text = (p.name).trim();
      emailC.text = (p.email).trim();

      // ✅ اعرض الرقم محلي
      phoneC.text = _toLocalJordanPhone(p.phone ?? '');
    }
  }

  @override
  void dispose() {
    fullNameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  // -------------------------
  // Helpers: Phone normalize
  // -------------------------

  String _toEnglishDigits(String input) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    var s = input;
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(ar[i], '$i');
      s = s.replaceAll(fa[i], '$i');
    }
    return s;
  }

  String _cleanPhone(String input) {
    final s = _toEnglishDigits(input).trim();
    // شيل المسافات والشرطات والأقواس
    return s.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// يرجّع رقم أردني محلي: 07xxxxxxxx
  /// يقبل: 07xxxxxxxx / +9627xxxxxxxx / 9627xxxxxxxx / 7xxxxxxxx
  String _toLocalJordanPhone(String input) {
    var s = _cleanPhone(input);

    if (s.startsWith('+962')) {
      s = '0' + s.substring(4); // +9627xxxxxxxx -> 07xxxxxxxx
    } else if (s.startsWith('962')) {
      s = '0' + s.substring(3); // 9627xxxxxxxx -> 07xxxxxxxx
    } else if (s.startsWith('7') && s.length == 9) {
      s = '0$s'; // 7xxxxxxxx -> 07xxxxxxxx
    }

    return s;
  }

  // -------------------------
  // Validators
  // -------------------------

  String? _validateFullName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'الاسم الكامل مطلوب';
    final parts = s.split(RegExp(r'\s+')).where((x) => x.trim().isNotEmpty).toList();
    if (parts.length < 2) return 'رجاءً أدخل الاسم الأول واسم العائلة';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'البريد الإلكتروني مطلوب';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return 'البريد الإلكتروني غير صحيح';
    return null;
  }

  String? _validatePhone(String? v) {
    final local = _toLocalJordanPhone(v ?? '');
    if (local.isEmpty) return 'رقم الهاتف مطلوب';

    // ✅ نفس منطق السيرفر: 077/078/079 + 7 أرقام = 10 أرقام
    final ok = RegExp(r'^(077|078|079)\d{7}$').hasMatch(local);
    if (!ok) return 'رقم الهاتف لازم يبدأ بـ 077 أو 078 أو 079 ويتكون من 10 أرقام';
    return null;
  }

  // -------------------------
  // Submit
  // -------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final rawFull = fullNameC.text.trim();
    final parts = rawFull.split(RegExp(r'\s+')).where((x) => x.trim().isNotEmpty).toList();
    final first = parts.isNotEmpty ? parts.first : '';
    final last = (parts.length > 1) ? parts.sublist(1).join(' ') : '';

    // ✅ ابعث محلي 07x... للسيرفر (عشان ما يرد 400)
    final phoneToSend = _toLocalJordanPhone(phoneC.text);

    final controller = ref.read(profileControllerProvider.notifier);
    final ok = await controller.saveProfile(
      firstName: first,
      lastName: last,
      email: emailC.text.trim(),
      phone: phoneToSend,
      address: null,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث البيانات')),
      );
    } else {
      final msg = ref.read(profileControllerProvider).errorMessage ?? 'حدث خطأ، حاول مرة أخرى';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Field(
              label: 'الاسم الكامل *',
              controller: fullNameC,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              validator: _validateFullName,
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: SizeConfig.h(10)),

            _Field(
              label: 'البريد الإلكتروني *',
              controller: emailC,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              validator: _validateEmail,
              suffix: _hintSuffix('البريد معي'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: SizeConfig.h(10)),

            _Field(
              label: 'رقم الهاتف *',
              controller: phoneC,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              validator: _validatePhone,
              suffix: _hintSuffix('الرقم معي'),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: SizeConfig.h(12)),
            SizedBox(
              width: double.infinity,
              height: SizeConfig.h(46),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                  ),
                ),
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'حفظ التغييرات',
                        style: TextStyle(
                          fontSize: SizeConfig.ts(13),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hintSuffix(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: SizeConfig.w(16), color: AppColors.lightGreen),
          SizedBox(width: SizeConfig.w(6)),
          Text(
            text,
            style: TextStyle(
              fontSize: SizeConfig.ts(11),
              fontWeight: FontWeight.w700,
              color: AppColors.lightGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.textDirection,
    required this.textAlign,
    this.validator,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: TextFormField(
        controller: controller,
        validator: validator,
        textAlign: textAlign,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
