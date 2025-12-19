import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class HelpCenterMessageSection extends StatefulWidget {
  const HelpCenterMessageSection({super.key});

  @override
  State<HelpCenterMessageSection> createState() => _HelpCenterMessageSectionState();
}

class _HelpCenterMessageSectionState extends State<HelpCenterMessageSection> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _message;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _message = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: SizeConfig.padding(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      labelStyle: AppTextStyles.label12.copyWith(
        fontSize: SizeConfig.ts(12.5),
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: AppTextStyles.label12.copyWith(
        fontSize: SizeConfig.ts(12.5),
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            decoration: _dec(
              label: 'الاسم',
              hint: 'اكتب اسمك الكامل',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الاسم' : null,
          ),
          SizeConfig.v(10),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _dec(
              label: 'البريد الإلكتروني',
              hint: 'example@email.com',
              prefixIcon: const Icon(Icons.mail_outline),
            ),
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
              if (!ok) return 'بريد إلكتروني غير صحيح';
              return null;
            },
          ),
          SizeConfig.v(10),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: _dec(
              label: 'رقم الهاتف',
              hint: '07XXXXXXXX',
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال رقم الهاتف' : null,
          ),
          SizeConfig.v(10),
          TextFormField(
            controller: _message,
            maxLines: 4,
            decoration: _dec(
              label: 'الرسالة',
              hint: 'اكتب رسالتك هنا...',
              prefixIcon: const Icon(Icons.chat_bubble_outline),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء كتابة الرسالة' : null,
          ),
          SizeConfig.v(14),
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
              onPressed: _submit,
              child: Text(
                'إرسال',
                style: AppTextStyles.body14.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال رسالتك ✅ سنقوم بالرد قريبًا')),
    );

    _name.clear();
    _email.clear();
    _phone.clear();
    _message.clear();
  }
}
