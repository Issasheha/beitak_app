import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/account_edit_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/account_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProviderAccountEditView extends ConsumerStatefulWidget {
  const ProviderAccountEditView({super.key});

  @override
  ConsumerState<ProviderAccountEditView> createState() =>
      _ProviderAccountEditViewState();
}

class _ProviderAccountEditViewState
    extends ConsumerState<ProviderAccountEditView> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  late final TextEditingController _currentPassCtrl;
  late final TextEditingController _newPassCtrl;
  late final TextEditingController _confirmPassCtrl;

  bool _initFromState = false;

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();

    _currentPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final asyncState = ref.watch(accountEditControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'تعديل معلومات الحساب',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(accountEditControllerProvider),
          ),
          data: (state) {
            if (!_initFromState) {
              _fullNameCtrl.text = state.fullName;
              _emailCtrl.text = state.email;
              _phoneCtrl.text = state.phone;
              _initFromState = true;
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileCard(context, state),
                    SizeConfig.v(18),
                    _buildPasswordCard(context, state),
                    SizeConfig.v(24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // -------- كارد البيانات الأساسية --------
  Widget _buildProfileCard(BuildContext context, AccountEditState state) {
    return Form(
      key: _profileFormKey,
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
            const _FieldLabel(text: 'الاسم الكامل', requiredStar: true),
            SizeConfig.v(6),
            _TextInput(
              controller: _fullNameCtrl,
              hint: 'أحمد محمود',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'الاسم مطلوب';
                if (s.length < 3) return 'الاسم قصير جداً';
                return null;
              },
            ),
            SizeConfig.v(12),

            const _FieldLabel(text: 'البريد الإلكتروني', requiredStar: true),
            SizeConfig.v(6),
            _TextInput(
              controller: _emailCtrl,
              hint: 'ahmad@example.com',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'البريد الإلكتروني مطلوب';
                final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(s);
                if (!ok) return 'صيغة البريد غير صحيحة';
                return null;
              },
            ),
            SizeConfig.v(4),
            _VerifiedRow(
              isVerified: state.isEmailVerified,
              labelWhenVerified: 'البريد موثّق',
              labelWhenNotVerified: 'البريد غير موثّق',
            ),
            SizeConfig.v(12),

            const _FieldLabel(text: 'رقم الهاتف', requiredStar: true),
            SizeConfig.v(6),
            _TextInput(
              controller: _phoneCtrl,
              hint: '+962 79 123 4567',
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'رقم الهاتف مطلوب';
                if (s.length < 8) return 'رقم الهاتف غير مكتمل';
                return null;
              },
            ),
            SizeConfig.v(4),
            _VerifiedRow(
              isVerified: state.isPhoneVerified,
              labelWhenVerified: 'الرقم موثّق',
              labelWhenNotVerified: 'الرقم غير موثّق',
            ),
            SizeConfig.v(16),

            SizedBox(
              height: SizeConfig.h(46),
              child: ElevatedButton(
                onPressed: state.isSavingProfile ? null : _onSaveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
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
  }

  // -------- كارد تغيير كلمة المرور --------
  Widget _buildPasswordCard(BuildContext context, AccountEditState state) {
    return Form(
      key: _passwordFormKey,
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
            Text(
              'تغيير كلمة المرور',
              textAlign: TextAlign.right,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(14.5),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizeConfig.v(12),

            const _FieldLabel(text: 'كلمة المرور الحالية', requiredStar: false),
            SizeConfig.v(6),
            _PasswordInput(
              controller: _currentPassCtrl,
              hint: 'أدخل كلمة المرور الحالية',
              obscure: !_showCurrent,
              onToggleVisibility: () =>
                  setState(() => _showCurrent = !_showCurrent),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'كلمة المرور الحالية مطلوبة';
                return null;
              },
            ),
            SizeConfig.v(12),

            const _FieldLabel(text: 'كلمة المرور الجديدة', requiredStar: false),
            SizeConfig.v(6),
            _PasswordInput(
              controller: _newPassCtrl,
              hint: 'أدخل كلمة المرور الجديدة',
              obscure: !_showNew,
              onToggleVisibility: () => setState(() => _showNew = !_showNew),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'كلمة المرور الجديدة مطلوبة';
                if (s.length < 8) {
                  return 'يجب أن تحتوي على 8 أحرف على الأقل';
                }
                return null;
              },
            ),
            SizeConfig.v(4),
            Text(
              'يجب أن تحتوي على 8 أحرف على الأقل',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption11.copyWith(
                fontSize: SizeConfig.ts(11.5),
                color: AppColors.textSecondary,
              ),
            ),
            SizeConfig.v(12),

            const _FieldLabel(text: 'تأكيد كلمة المرور', requiredStar: false),
            SizeConfig.v(6),
            _PasswordInput(
              controller: _confirmPassCtrl,
              hint: 'أعد إدخال كلمة المرور الجديدة',
              obscure: !_showConfirm,
              onToggleVisibility: () =>
                  setState(() => _showConfirm = !_showConfirm),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'تأكيد كلمة المرور مطلوب';
                if (s != _newPassCtrl.text.trim()) {
                  return 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
            ),
            SizeConfig.v(16),

            SizedBox(
              height: SizeConfig.h(46),
              child: ElevatedButton(
                onPressed: state.isChangingPassword ? null : _onChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                  ),
                ),
                child: state.isChangingPassword
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'تحديث كلمة المرور',
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
  }

  // -------- Actions --------

  Future<void> _onSaveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(accountEditControllerProvider.notifier);

    final error = await notifier.saveProfile(
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'تم حفظ بيانات الحساب بنجاح'),
      ),
    );
  }

  Future<void> _onChangePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(accountEditControllerProvider.notifier);

    final error = await notifier.changePassword(
      currentPassword: _currentPassCtrl.text.trim(),
      newPassword: _newPassCtrl.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'تم تغيير كلمة المرور بنجاح'),
      ),
    );
  }
}

// ===================== Widgets مساعدة =====================

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool requiredStar;

  const _FieldLabel({
    required this.text,
    required this.requiredStar,
  });

  @override
  Widget build(BuildContext context) {
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

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const _TextInput({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: AppTextStyles.body14.copyWith(
        fontSize: SizeConfig.ts(13.5),
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(13),
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: SizeConfig.padding(horizontal: 14, vertical: 12),
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
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _PasswordInput({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.right,
      validator: validator,
      style: AppTextStyles.body14.copyWith(
        fontSize: SizeConfig.ts(13.5),
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(13),
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: SizeConfig.padding(horizontal: 14, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggleVisibility,
        ),
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
    );
  }
}

class _VerifiedRow extends StatelessWidget {
  final bool isVerified;
  final String labelWhenVerified;
  final String labelWhenNotVerified;

  const _VerifiedRow({
    required this.isVerified,
    required this.labelWhenVerified,
    required this.labelWhenNotVerified,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppColors.lightGreen : AppColors.textSecondary;
    final icon = isVerified ? Icons.check_circle : Icons.error_outline;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isVerified ? labelWhenVerified : labelWhenNotVerified,
            style: AppTextStyles.caption11.copyWith(
              fontSize: SizeConfig.ts(11.5),
              color: color,
              fontWeight: isVerified ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          SizeConfig.hSpace(4),
          Icon(
            icon,
            size: SizeConfig.ts(16),
            color: color,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: SizeConfig.padding(all: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
              ),
            ),
            SizeConfig.v(12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
