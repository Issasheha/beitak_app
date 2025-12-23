import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:beitak_app/features/user/home/presentation/viewmodels/home_header_providers.dart';

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

  // ✅ لودنج خاص بالحفظ فقط (بدون ما يتأثر بـ refresh)
  bool _isSaving = false;

  // ✅ لحساب “ما في تغييرات”
  String _initialFullName = '';
  String _initialEmail = '';
  String _initialPhoneLocal = '';

  @override
  void initState() {
    super.initState();

    final p = widget.profile;
    final full = (p?.name ?? '').trim();
    final email = (p?.email ?? '').trim();
    final phoneLocal = _toLocalJordanPhone(p?.phone ?? '');

    fullNameC = TextEditingController(text: full);
    emailC = TextEditingController(text: email);
    phoneC = TextEditingController(text: phoneLocal);

    _initialFullName = _normSpaces(full);
    _initialEmail = email.trim();
    _initialPhoneLocal = phoneLocal.trim();

    // ✅ لإخفاء/إظهار suffix بشكل صحيح حسب الإدخال
    emailC.addListener(_rebuild);
    phoneC.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant AccountProfileFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ لو البروفايل وصل بعد ما الصفحة انبنت
    if (oldWidget.profile == null && widget.profile != null) {
      final p = widget.profile!;
      final full = (p.name).trim();
      final email = (p.email).trim();
      final phoneLocal = _toLocalJordanPhone(p.phone ?? '');

      fullNameC.text = full;
      emailC.text = email;
      phoneC.text = phoneLocal;

      _initialFullName = _normSpaces(full);
      _initialEmail = email.trim();
      _initialPhoneLocal = phoneLocal.trim();
    }
  }

  @override
  void dispose() {
    emailC.removeListener(_rebuild);
    phoneC.removeListener(_rebuild);

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
    return s.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// يرجّع رقم أردني محلي: 07xxxxxxxx
  String _toLocalJordanPhone(String input) {
    var s = _cleanPhone(input);

    if (s.startsWith('+962')) {
      s = '0' + s.substring(4);
    } else if (s.startsWith('962')) {
      s = '0' + s.substring(3);
    } else if (s.startsWith('7') && s.length == 9) {
      s = '0$s';
    }

    return s;
  }

  String _normSpaces(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

  // -------------------------
  // Validators
  // -------------------------

  String? _validateFullName(String? v) {
    final s = _normSpaces(v ?? '');
    if (s.isEmpty) return 'الاسم الكامل مطلوب (مثال: أحمد محمد)';

    // أرقام عربي/إنجليزي
    if (RegExp(r'[0-9٠-٩]').hasMatch(s)) {
      return 'الاسم لا يجب أن يحتوي على أرقام';
    }

    // أحرف عربي/إنجليزي + مسافات فقط
    final okLetters = RegExp(r'^[a-zA-Z\u0600-\u06FF ]+$').hasMatch(s);
    if (!okLetters) {
      return 'الاسم يجب أن يحتوي على أحرف ومسافات فقط';
    }

    final parts = s.split(' ').where((x) => x.trim().isNotEmpty).toList();
    if (parts.length < 2) return 'رجاءً أدخل الاسم الأول واسم العائلة';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'البريد الإلكتروني مطلوب';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return 'البريد الإلكتروني غير صحيح (مثال: name@email.com)';
    return null;
  }

  String? _validatePhone(String? v) {
    final local = _toLocalJordanPhone(v ?? '');
    if (local.isEmpty) return 'رقم الهاتف مطلوب';

    final ok = RegExp(r'^(077|078|079)\d{7}$').hasMatch(local);
    if (!ok) return 'رقم الهاتف يجب أن يكون 10 أرقام ويبدأ بـ 077 أو 078 أو 079';
    return null;
  }

  // -------------------------
  // Snack (واضح للمستخدم)
  // -------------------------

  void _showSnack(String msg, {bool success = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: success ? AppColors.lightGreen : Colors.black87,
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.info_outline, color: Colors.white),
            SizedBox(width: SizeConfig.w(10)),
            Expanded(
              child: Text(
                msg,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: SizeConfig.ts(12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasChanges() {
    final currentFull = _normSpaces(fullNameC.text);
    final currentEmail = emailC.text.trim();
    final currentPhone = _toLocalJordanPhone(phoneC.text).trim();

    return currentFull != _initialFullName ||
        currentEmail != _initialEmail ||
        currentPhone != _initialPhoneLocal;
  }

  // -------------------------
  // Submit
  // -------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    // ✅ منع الحفظ إذا ما في أي تغييرات (حل مشكلة رسالتين إنجليزي)
    if (!_hasChanges()) {
      _showSnack('لا توجد تغييرات للحفظ', success: false);
      return;
    }

    final rawFull = _normSpaces(fullNameC.text);
    final parts = rawFull.split(' ').where((x) => x.trim().isNotEmpty).toList();
    final first = parts.isNotEmpty ? parts.first : '';
    final last = (parts.length > 1) ? parts.sublist(1).join(' ') : '';

    final phoneToSend = _toLocalJordanPhone(phoneC.text);

    setState(() => _isSaving = true);

    final controller = ref.read(profileControllerProvider.notifier);
    final ok = await controller.saveProfile(
      firstName: first,
      lastName: last,
      email: emailC.text.trim(),
      phone: phoneToSend,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (ok) {
      // ✅ حدّث كاش الـAuth
      await AuthLocalDataSourceImpl().updateCachedUser(
        firstName: first,
        lastName: last,
        email: emailC.text.trim(),
        phone: phoneToSend,
      );

      // ✅ حدّث الهيدر فوراً
      ref.read(homeHeaderControllerProvider.notifier).setDisplayName('$first $last');

      // ✅ تحديث baseline للتغييرات
      _initialFullName = _normSpaces(fullNameC.text);
      _initialEmail = emailC.text.trim();
      _initialPhoneLocal = phoneToSend.trim();

      _showSnack('تم تحديث البيانات بنجاح');
    } else {
      // ✅ رسالة واضحة (وبنفس الوقت نمسح الخطأ من أعلى الصفحة لتجنب التكرار)
      final raw = ref.read(profileControllerProvider).errorMessage ?? 'حدث خطأ، حاول مرة أخرى';

      // إن كانت الجلسة انتهت خليه يظهر (مهم)
      if (!raw.contains('انتهت الجلسة')) {
        controller.clearError();
      }

      _showSnack(raw, success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ suffix يظهر فقط إذا المستخدم أدخل قيمة وهي صحيحة
    final emailSuffix = (emailC.text.trim().isNotEmpty && _validateEmail(emailC.text) == null)
        ? _hintSuffix('البريد معي')
        : null;

    final phoneSuffix = (phoneC.text.trim().isNotEmpty && _validatePhone(phoneC.text) == null)
        ? _hintSuffix('الرقم معي')
        : null;

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
              suffix: emailSuffix,
              keyboardType: TextInputType.emailAddress,
              errorMaxLines: 2,
            ),
            SizedBox(height: SizeConfig.h(10)),

            _Field(
              label: 'رقم الهاتف *',
              controller: phoneC,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              validator: _validatePhone,
              suffix: phoneSuffix,
              keyboardType: TextInputType.phone,
              // ✅ حل مشكلة: رسالة الخطأ ما بتظهر كاملة على الشاشات الصغيرة
              errorMaxLines: 3,
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
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
          Icon(
            Icons.check_circle_outline,
            size: SizeConfig.w(16),
            color: AppColors.lightGreen,
          ),
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
  final int? errorMaxLines;

  const _Field({
    required this.label,
    required this.controller,
    required this.textDirection,
    required this.textAlign,
    this.validator,
    this.suffix,
    this.keyboardType,
    this.errorMaxLines,
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
          errorMaxLines: errorMaxLines ?? 2,
        ),
      ),
    );
  }
}
