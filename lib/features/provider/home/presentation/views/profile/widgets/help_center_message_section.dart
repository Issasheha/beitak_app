import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class HelpCenterMessageSection extends StatefulWidget {
  const HelpCenterMessageSection({super.key});

  @override
  State<HelpCenterMessageSection> createState() =>
      _HelpCenterMessageSectionState();
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: SizeConfig.padding(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          border: Border.all(
            color: AppColors.lightGreen.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أرسل لنا رسالة',
                textAlign: TextAlign.center,
                style: AppTextStyles.body16.copyWith(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(6),
              Text(
                'املأ النموذج أدناه وسنعود إليك خلال 24 ساعة.',
                textAlign: TextAlign.center,
                style: AppTextStyles.label12.copyWith(
                  fontSize: SizeConfig.ts(12.5),
                  color: AppColors.textSecondary,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizeConfig.v(16),

              const _FieldLabel(text: 'الاسم', requiredStar: true),
              SizeConfig.v(6),
              _InputField(
                controller: _name,
                hint: 'اسمك الكامل',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'الاسم مطلوب';
                  if (s.length < 3) return 'الاسم قصير جدًا';
                  return null;
                },
              ),
              SizeConfig.v(14),

              const _FieldLabel(text: 'البريد الإلكتروني', requiredStar: true),
              SizeConfig.v(6),
              _InputField(
                controller: _email,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'الإيميل مطلوب';
                  final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(s);
                  if (!ok) return 'الإيميل غير صحيح';
                  return null;
                },
              ),
              SizeConfig.v(14),

              const _FieldLabel(text: 'رقم الهاتف (اختياري)', requiredStar: false),
              SizeConfig.v(6),
              _InputField(
                controller: _phone,
                hint: '+962 XX XXX XXXX',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              SizeConfig.v(14),

              const _FieldLabel(text: 'الرسالة', requiredStar: true),
              SizeConfig.v(6),
              _InputField(
                controller: _message,
                hint: 'أخبرنا كيف يمكننا مساعدتك...',
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 5,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'الرسالة مطلوبة';
                  if (s.length < 10) return 'اكتب تفاصيل أكثر (10 أحرف على الأقل)';
                  return null;
                },
              ),

              SizeConfig.v(16),

              SizedBox(
                height: SizeConfig.h(48),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                    ),
                  ),
                  onPressed: _submit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'إرسال الرسالة',
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(14),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizeConfig.hSpace(8),
                      const Icon(Icons.send), // ✅ الأيقونة بعد النص
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال رسالتك ✅ سنقوم بالرد قريبًا',
          style: AppTextStyles.body14.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );

    _name.clear();
    _email.clear();
    _phone.clear();
    _message.clear();
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool requiredStar;

  const _FieldLabel({required this.text, required this.requiredStar});

  @override
  Widget build(BuildContext context) {
    // ✅ محاذاة يمين + عرض كامل
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (requiredStar) ...[
            SizeConfig.hSpace(4),
            Text(
              '*',
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.textInputAction,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      textAlign: TextAlign.right, // ✅ الكتابة داخل الحقل يمين
      style: AppTextStyles.body14.copyWith(
        fontSize: SizeConfig.ts(13.5),
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(13),
          color: AppColors.textSecondary.withValues(alpha: 0.65),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: SizeConfig.padding(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: const BorderSide(
            color: AppColors.lightGreen,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: validator,
    );
  }
}
