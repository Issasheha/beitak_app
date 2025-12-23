import 'package:beitak_app/features/user/home/domain/usecases/change_password_usecase.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/viewmodels/change_password_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/viewmodels/profile_providers.dart';

class AccountChangePasswordCard extends ConsumerStatefulWidget {
  const AccountChangePasswordCard({super.key});

  @override
  ConsumerState<AccountChangePasswordCard> createState() => _AccountChangePasswordCardState();
}

class _AccountChangePasswordCardState extends ConsumerState<AccountChangePasswordCard> {
  final _formKey = GlobalKey<FormState>();

  final currentC = TextEditingController();
  final newC = TextEditingController();
  final confirmC = TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  late final ChangePasswordViewModel vm;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(profileRepositoryProvider);
    vm = ChangePasswordViewModel(
      changePasswordUseCase: ChangePasswordUseCase(repo),
    );

    // ✅ إذا كان في خطأ من السيرفر على كلمة المرور الحالية، أول ما يبلش يكتب امسحه
    currentC.addListener(() {
      if (vm.currentPasswordError != null) {
        vm.clearCurrentPasswordError();
      }
    });
  }

  @override
  void dispose() {
    currentC.dispose();
    newC.dispose();
    confirmC.dispose();
    vm.dispose();
    super.dispose();
  }

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

  String? _validateCurrent(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'كلمة المرور الحالية مطلوبة';
    if (vm.currentPasswordError != null) return vm.currentPasswordError;
    return null;
  }

  String? _validateNewPassword(String? v) {
    final s = (v ?? '');
    if (s.trim().isEmpty) return 'كلمة المرور الجديدة مطلوبة';
    if (s.contains(' ')) return 'كلمة المرور الجديدة لا يجب أن تحتوي على مسافات';

    // ✅ QA: لازم 8 أحرف (مش 6)
    if (s.length < 8) return 'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل';

    if (!RegExp(r'[A-Z]').hasMatch(s)) return 'أضف حرفًا كبيرًا واحدًا على الأقل (A-Z)';
    if (!RegExp(r'\d').hasMatch(s)) return 'أضف رقمًا واحدًا على الأقل';
    if (!RegExp(r'[@#$%^&*()_\-+=\[\]{};:,.!?/\\|<>~`]').hasMatch(s)) {
      return 'أضف رمزًا خاصًا واحدًا على الأقل (مثل @ أو #)';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    final s = (v ?? '');
    if (s.trim().isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (s != newC.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    // امسح أخطاء السيرفر قبل الفحص
    vm.clearCurrentPasswordError();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final success = await vm.submit(
      currentPassword: currentC.text,
      newPassword: newC.text,
      confirmPassword: confirmC.text,
    );

    if (!mounted) return;

    if (success) {
      currentC.clear();
      newC.clear();
      confirmC.clear();
      _showSnack('تم تغيير كلمة المرور بنجاح');
    } else {
      // ✅ إذا المشكلة من كلمة المرور الحالية: أظهرها تحت الحقل بشكل واضح
      if (vm.currentPasswordError != null) {
        _formKey.currentState?.validate();
        _showSnack(vm.currentPasswordError!, success: false);
        return;
      }

      _showSnack(vm.errorMessage ?? 'حدث خطأ، حاول مرة أخرى', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
      builder: (_, __) {
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
                Text(
                  'تغيير كلمة المرور',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: SizeConfig.h(10)),

                _PwdField(
                  label: 'كلمة المرور الحالية',
                  controller: currentC,
                  obscure: hideCurrent,
                  onToggle: () => setState(() => hideCurrent = !hideCurrent),
                  validator: _validateCurrent,
                ),
                SizedBox(height: SizeConfig.h(10)),

                _PwdField(
                  label: 'كلمة المرور الجديدة',
                  controller: newC,
                  obscure: hideNew,
                  onToggle: () => setState(() => hideNew = !hideNew),
                  validator: _validateNewPassword,
                ),
                SizedBox(height: SizeConfig.h(10)),

                _PwdField(
                  label: 'تأكيد كلمة المرور الجديدة',
                  controller: confirmC,
                  obscure: hideConfirm,
                  onToggle: () => setState(() => hideConfirm = !hideConfirm),
                  validator: _validateConfirm,
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
                    onPressed: vm.isLoading ? null : _submit,
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'حفظ كلمة المرور',
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
      },
    );
  }
}

class _PwdField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PwdField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        errorMaxLines: 3,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
