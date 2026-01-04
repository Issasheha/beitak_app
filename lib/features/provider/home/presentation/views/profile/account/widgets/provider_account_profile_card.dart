// lib/features/provider/home/presentation/views/profile/account/widgets/provider_account_profile_card.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/viewmodels/account_edit_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/account_field_label.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/account_text_input.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/account_verified_row.dart';
import 'package:flutter/material.dart';

class ProviderAccountProfileCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AccountEditState state;

  final TextEditingController fullNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;

  final Listenable listenable;

  final VoidCallback onChangePhoneTap;
  final Future<void> Function() onSave;

  const ProviderAccountProfileCard({
    super.key,
    required this.formKey,
    required this.state,
    required this.fullNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.listenable,
    required this.onChangePhoneTap,
    required this.onSave,
  });

  String _norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

  bool _isProfileDirty() {
    final name = _norm(fullNameCtrl.text);
    final email = _norm(emailCtrl.text);
    return name != _norm(state.fullName) || email != _norm(state.email);
  }

  // ✅ نفس فكرة الباك: حروف + مسافات + - + '
  // يدعم عربي/إنجليزي (بدون أرقام وبدون رموز ثانية)
  static final RegExp _namePattern = RegExp(
    r"^[A-Za-z\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+(?:[ '\-][A-Za-z\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+)*$",
  );

  String? _validateFullName(String? v) {
    final s = _norm(v ?? '');
    if (s.isEmpty) return 'الاسم مطلوب';
    if (s.length < 3) return 'الاسم قصير جداً';

    // ✅ لازم يكون في اسم أول + اسم عائلة (على الأقل كلمتين)
    final parts = s.split(' ').where((x) => x.trim().isNotEmpty).toList();
    if (parts.length < 2) return 'اكتب الاسم الأول واسم العائلة';

    if (!_namePattern.hasMatch(s)) {
      return "الاسم يجب أن يحتوي على أحرف فقط، ويمكن استخدام المسافات و - و '";
    }
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'البريد الإلكتروني مطلوب';
    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(s);
    if (!ok) return 'صيغة البريد غير صحيحة';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (_, __) {
        final isProfileDirty = _isProfileDirty();

        return Form(
          key: formKey,
          child: Container(
            padding: SizeConfig.padding(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
              border: Border.all(
                color: AppColors.lightGreen.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AccountFieldLabel(text: 'الاسم الكامل', requiredStar: true),
                SizeConfig.v(6),
                AccountTextInput(
                  controller: fullNameCtrl,
                  hint: 'أحمد محمود',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  validator: _validateFullName,
                ),
                SizeConfig.v(12),

                const AccountFieldLabel(
                  text: 'البريد الإلكتروني',
                  requiredStar: true,
                ),
                SizeConfig.v(6),
                AccountTextInput(
                  controller: emailCtrl,
                  hint: 'ahmad@example.com',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizeConfig.v(4),
                AccountVerifiedRow(
                  isVerified: state.isEmailVerified,
                  labelWhenVerified: 'البريد موثّق',
                  labelWhenNotVerified: 'البريد غير موثّق',
                ),
                SizeConfig.v(12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AccountFieldLabel(
                      text: 'رقم الهاتف',
                      requiredStar: false,
                    ),
                    TextButton.icon(
                      onPressed: onChangePhoneTap,
                      icon: const Icon(Icons.edit,
                          size: 18, color: AppColors.lightGreen),
                      label: Text(
                        'تغيير الرقم',
                        style: AppTextStyles.body14.copyWith(
                          color: AppColors.lightGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizeConfig.v(6),
                AccountTextInput(
                  controller: phoneCtrl,
                  hint: '+962 79 123 4567',
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  enabled: false,
                ),
                SizeConfig.v(6),
                Text(
                  'تغيير الرقم يتم عبر رمز تحقق (OTP)',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption11.copyWith(
                    fontSize: SizeConfig.ts(11.5),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizeConfig.v(6),
                AccountVerifiedRow(
                  isVerified: state.isPhoneVerified,
                  labelWhenVerified: 'الرقم موثّق',
                  labelWhenNotVerified: 'الرقم غير موثّق',
                ),

                SizeConfig.v(16),

                SizedBox(
                  height: SizeConfig.h(46),
                  child: ElevatedButton(
                    onPressed: (state.isSavingProfile || !isProfileDirty)
                        ? null
                        : () async => onSave(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.lightGreen.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SizeConfig.radius(12),
                        ),
                      ),
                    ),
                    child: state.isSavingProfile
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'حفظ بيانات الحساب',
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(14),
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
