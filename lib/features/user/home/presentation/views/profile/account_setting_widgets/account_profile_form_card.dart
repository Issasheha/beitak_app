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
    phoneC = TextEditingController(text: (p?.phone ?? '').trim());
  }

  @override
  void didUpdateWidget(covariant AccountProfileFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ لو البروفايل إجا بعد ما الصفحة انبنت
    if (oldWidget.profile == null && widget.profile != null) {
      final p = widget.profile!;
      fullNameC.text = (p.name).trim();
      emailC.text = (p.email).trim();
      phoneC.text = (p.phone ?? '').trim();
    }
  }

  @override
  void dispose() {
    fullNameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    super.dispose();
  }

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
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'رقم الهاتف مطلوب';

    final localOk = RegExp(r'^(079|078|077)\d{7}$').hasMatch(s);
    final intlOk = RegExp(r'^\+9627\d{8}$').hasMatch(s);

    if (!localOk && !intlOk) return 'رقم الهاتف غير صحيح';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final rawFull = fullNameC.text.trim();
    final parts = rawFull.split(RegExp(r'\s+')).where((x) => x.trim().isNotEmpty).toList();
    final first = parts.isNotEmpty ? parts.first : '';
    final last = (parts.length > 1) ? parts.sublist(1).join(' ') : '';

    final rawPhone = phoneC.text.trim();
    final phoneToSend = rawPhone.startsWith('0') ? '+962${rawPhone.substring(1)}' : rawPhone;

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
            ),
            SizedBox(height: SizeConfig.h(10)),

            _Field(
              label: 'البريد الإلكتروني *',
              controller: emailC,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              validator: _validateEmail,
              suffix: _hintSuffix('البريد معي'),
            ),
            SizedBox(height: SizeConfig.h(10)),

            _Field(
              label: 'رقم الهاتف *',
              controller: phoneC,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              validator: _validatePhone,
              suffix: _hintSuffix('الرقم معي'),
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

  const _Field({
    required this.label,
    required this.controller,
    required this.textDirection,
    required this.textAlign,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: TextFormField(
        controller: controller,
        validator: validator,
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
