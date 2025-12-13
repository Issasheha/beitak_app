import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/constants/colors.dart';

import '../viewmodels/profile_providers.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  const ProfileEditSheet({super.key});

  @override
  ConsumerState<ProfileEditSheet> createState() =>
      _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController firstNameC;
  late final TextEditingController lastNameC;
  late final TextEditingController emailC;
  late final TextEditingController phoneC;
  late final TextEditingController addressC;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileControllerProvider).profile;

    final full = (p?.name ?? '').trim();
    final parts = full.isEmpty ? <String>[] : full.split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    firstNameC = TextEditingController(text: first);
    lastNameC = TextEditingController(text: last);

    emailC = TextEditingController(text: p?.email ?? '');
    phoneC = TextEditingController(text: p?.phone ?? '');

    // حالياً الـ entity ما فيها address → نخليه اختياري فاضي
    addressC = TextEditingController(text: '');
  }

  @override
  void dispose() {
    firstNameC.dispose();
    lastNameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    addressC.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'رجاءً أدخل الاسم الأول';
    if (s.length < 2) return 'الاسم الأول يجب أن يكون حرفين على الأقل';
    return null;
  }

  String? _validateLastName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'رجاءً أدخل اسم العائلة';
    if (s.length < 2) return 'اسم العائلة يجب أن يكون حرفين على الأقل';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'رجاءً أدخل البريد الإلكتروني';
    final ok =
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return 'البريد الإلكتروني غير صحيح';
    return null;
  }

  /// ✅ يدعم:
  /// - 079/078/077 + 7 أرقام
  /// - +9627 + 8 أرقام
  String? _validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'رجاءً أدخل رقم الهاتف';

    final localOk =
        RegExp(r'^(079|078|077)\d{7}$').hasMatch(s);
    final intlOk =
        RegExp(r'^\+9627\d{8}$').hasMatch(s);

    if (!localOk && !intlOk) return 'رقم الهاتف غير صحيح';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller =
        ref.read(profileControllerProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SafeArea(
            top: false,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(SizeConfig.radius(18)),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: SizeConfig
                      .padding(horizontal: 16, vertical: 14)
                      .copyWith(
                    bottom: 14 +
                        MediaQuery.of(context)
                            .viewInsets
                            .bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 46,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.25),
                            borderRadius:
                                BorderRadius.circular(99),
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(14)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'تعديل الملف الشخصي',
                            style: TextStyle(
                              fontSize: SizeConfig.ts(16),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(12)),

                        _Field(
                          label: 'الاسم الأول',
                          controller: firstNameC,
                          validator: _validateFirstName,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: SizeConfig.h(10)),

                        _Field(
                          label: 'اسم العائلة',
                          controller: lastNameC,
                          validator: _validateLastName,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: SizeConfig.h(10)),

                        // ✅ Email LTR
                        _Field(
                          label: 'البريد الإلكتروني',
                          hint: 'example@mail.com',
                          controller: emailC,
                          keyboardType:
                              TextInputType.emailAddress,
                          validator: _validateEmail,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: SizeConfig.h(10)),

                        // ✅ Phone LTR
                        _Field(
                          label: 'رقم الهاتف',
                          hint:
                              '0791234567 أو +962786056084',
                          controller: phoneC,
                          keyboardType:
                              TextInputType.phone,
                          validator: _validatePhone,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: SizeConfig.h(10)),

                        _Field(
                          label: 'العنوان (اختياري)',
                          controller: addressC,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),

                        SizedBox(height: SizeConfig.h(16)),
                        SizedBox(
                          width: double.infinity,
                          height: SizeConfig.h(48),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.lightGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  SizeConfig.radius(14),
                                ),
                              ),
                            ),
                            onPressed: state.isLoading
                                ? null
                                : () async {
                                    FocusScope.of(context)
                                        .unfocus();

                                    final valid =
                                        _formKey
                                                .currentState
                                                ?.validate() ??
                                            false;
                                    if (!valid) return;

                                    final rawPhone =
                                        phoneC.text.trim();
                                    final phoneToSend =
                                        rawPhone
                                                .startsWith(
                                                    '0')
                                            ? '+962${rawPhone.substring(1)}'
                                            : rawPhone;

                                    final ok =
                                        await controller
                                            .saveProfile(
                                      firstName: firstNameC
                                          .text
                                          .trim(),
                                      lastName: lastNameC.text
                                          .trim(),
                                      email:
                                          emailC.text.trim(),
                                      phone: phoneToSend,
                                      address: addressC.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : addressC.text
                                              .trim(),
                                    );

                                    if (!context.mounted) {
                                      return;
                                    }

                                    if (ok) {
                                      Navigator.pop(
                                          context);
                                      ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'تم تحديث البيانات'),
                                        ),
                                      );
                                    } else {
                                      final latest = ref.read(
                                          profileControllerProvider);
                                      final msg = latest
                                              .errorMessage ??
                                          'حدث خطأ، حاول مرة أخرى';

                                      ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(msg),
                                        ),
                                      );
                                    }
                                  },
                            child: state.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'حفظ التغييرات',
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.ts(14),
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(6)),
                        Text(
                          'قد تحتاج بعض التغييرات بضع لحظات للظهور في كل الشاشات.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(12),
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  final TextDirection textDirection;
  final TextAlign textAlign;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
    required this.textDirection,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
