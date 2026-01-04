import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/auth_text_field.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/providers/provider_onboarding_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProviderPersonalInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  // ✅ Terms
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;

  // ✅ City
  final List<CityOption> cities;
  final int? selectedCityId;
  final ValueChanged<int?> onCityChanged;

  // ✅ بعد التسجيل المبكر: نقفل تعديل البيانات الشخصية حتى ما نخرب التسجيل
  final bool lockPersonalInfo;

  const ProviderPersonalInfoStep({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.cities,
    required this.selectedCityId,
    required this.onCityChanged,
    this.lockPersonalInfo = false,
  });

  @override
  State<ProviderPersonalInfoStep> createState() => _ProviderPersonalInfoStepState();
}

class _ProviderPersonalInfoStepState extends State<ProviderPersonalInfoStep> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    widget.phoneController.addListener(_revalidateSoft);
    widget.emailController.addListener(_revalidateSoft);
    widget.passwordController.addListener(_revalidateSoft);
  }

  void _revalidateSoft() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(_revalidateSoft);
    widget.emailController.removeListener(_revalidateSoft);
    widget.passwordController.removeListener(_revalidateSoft);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.lockPersonalInfo;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الشخصية',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(17),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            locked
                ? 'تم إنشاء الحساب بنجاح. أكمل باقي الخطوات لإرسال الطلب.'
                : 'لنبدأ بمعلوماتك الأساسية.',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizeConfig.v(14),

          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  label: 'الاسم الأول *',
                  hint: 'أحمد',
                  icon: Icons.person_outline,
                  controller: widget.firstNameController,
                  validator: _nameValidator,
                  onDarkBackground: false,
                  enabled: !locked,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s{2,}')),
                  ],
                ),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: AuthTextField(
                  label: 'اسم العائلة *',
                  hint: 'محمد',
                  icon: Icons.person_outline,
                  controller: widget.lastNameController,
                  validator: _nameValidator,
                  onDarkBackground: false,
                  enabled: !locked,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s{2,}')),
                  ],
                ),
              ),
            ],
          ),
          SizeConfig.v(14),

          AuthTextField(
            label: 'رقم الجوال',
            hint: '0771234567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            controller: widget.phoneController,
            validator: (v) => _phoneValidator(v, email: widget.emailController.text),
            onDarkBackground: false,
            enabled: !locked,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
          ),
          SizeConfig.v(14),

          AuthTextField(
            label: 'البريد الإلكتروني',
            hint: 'ahmad@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: widget.emailController,
            validator: (v) => _emailValidator(v, phone: widget.phoneController.text),
            onDarkBackground: false,
            enabled: !locked,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
          ),
          SizeConfig.v(14),

          AuthTextField(
            label: 'كلمة المرور *',
            hint: 'مثال: Abc@123',
            icon: Icons.lock_outline,
            obscureText: _obscurePass,
            controller: widget.passwordController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
            validator: _passwordValidator,
            onDarkBackground: false,
            enabled: !locked,
          ),
          SizeConfig.v(14),

          AuthTextField(
            label: 'تأكيد كلمة المرور *',
            hint: 'أعد كتابة كلمة المرور',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            controller: widget.confirmPasswordController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (value) {
              final v = (value ?? '').trim();
              if (v.isEmpty) return 'تأكيد كلمة المرور مطلوب';
              if (v != widget.passwordController.text) return 'كلمتا المرور غير متطابقتين';
              return null;
            },
            onDarkBackground: false,
            enabled: !locked,
          ),
          SizeConfig.v(14),

          _buildCityDropdown(
            cities: widget.cities,
            value: widget.selectedCityId,
            onChanged: locked ? null : widget.onCityChanged,
          ),
          SizeConfig.v(16),

          _buildTermsSection(),
        ],
      ),
    );
  }

  Widget _buildCityDropdown({
    required List<CityOption> cities,
    required int? value,
    required ValueChanged<int?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المحافظة *',
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(6),
        DropdownButtonFormField<int>(
          initialValue: value,
          items: cities
              .map(
                (c) => DropdownMenuItem<int>(
                  value: c.id,
                  child: Text(
                    c.displayName,
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(13.5),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'المحافظة مطلوبة' : null,
          decoration: InputDecoration(
            hintText: 'اختر المحافظة',
            hintStyle: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: onChanged == null
                ? AppColors.background.withValues(alpha: 0.6)
                : AppColors.background,
            contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.h(10),
              horizontal: SizeConfig.w(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return FormField<bool>(
      initialValue: widget.termsAccepted,
      validator: (_) {
        if (!widget.termsAccepted) return 'يجب الموافقة على الشروط والأحكام';
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: widget.termsAccepted,
                  onChanged: (v) {
                    final newVal = v ?? false;
                    widget.onTermsChanged(newVal);
                    field.didChange(newVal);
                  },
                  activeColor: AppColors.primaryGreen,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final newVal = !widget.termsAccepted;
                      widget.onTermsChanged(newVal);
                      field.didChange(newVal);
                    },
                    child: Text(
                      'أوافق على الشروط والأحكام وسياسة الخصوصية *',
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(13),
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: EdgeInsets.only(right: SizeConfig.w(8)),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: SizeConfig.ts(12),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ===== Validators =====

  static String? _nameValidator(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'هذا الحقل مطلوب';
    if (v.length < 2) return 'يجب أن يكون حرفين على الأقل';

    // عربي/إنجليزي + مسافة بين الكلمات (بدون أرقام/رموز)
    final ok = RegExp(r'^[a-zA-Z\u0600-\u06FF]+(?:\s[a-zA-Z\u0600-\u06FF]+)*$')
        .hasMatch(v);
    if (!ok) return 'يسمح بالحروف فقط';
    return null;
  }

  static String? _phoneValidator(String? value, {required String email}) {
    final phone = (value ?? '').trim();
    final e = email.trim();

    if (phone.isEmpty && e.isEmpty) {
      return 'يجب إدخال رقم الجوال أو البريد على الأقل';
    }
    if (phone.isEmpty) return null;

    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'رقم الجوال يجب أن يحتوي أرقام فقط';
    }
    final regex = RegExp(r'^07(7|8|9)\d{7}$');
    if (!regex.hasMatch(phone)) {
      return 'يجب أن يبدأ بـ 077 أو 078 أو 079 ويتكوّن من 10 أرقام';
    }
    return null;
  }

  static String? _emailValidator(String? value, {required String phone}) {
    final email = (value ?? '').trim();
    final p = phone.trim();

    if (email.isEmpty && p.isEmpty) {
      return 'يجب إدخال رقم الجوال أو البريد على الأقل';
    }
    if (email.isEmpty) return null;

    if (email.contains(' ')) return 'البريد الإلكتروني غير صالح';
    if (email.startsWith('.') || email.endsWith('.')) return 'البريد الإلكتروني غير صالح';
    if (email.contains('..')) return 'البريد الإلكتروني غير صالح';

    final emailRegex = RegExp(
      r"^[A-Za-z0-9!#$%&'*+\-/=?^_`{|}~.]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
    );
    if (!emailRegex.hasMatch(email)) return 'البريد الإلكتروني غير صالح';

    return null;
  }

  static String? _passwordValidator(String? value) {
    final v = (value ?? '');
    if (v.isEmpty) return 'كلمة المرور مطلوبة';

    if (v.contains(' ')) return 'كلمة المرور يجب أن لا تحتوي على مسافات';
    if (v.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'كلمة المرور يجب أن تحتوي على حرف كبير (A-Z)';
    if (!RegExp(r'\d').hasMatch(v)) return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص (مثل ! @ #)';
    }
    return null;
  }
}
