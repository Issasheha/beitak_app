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
  }

  @override
  void dispose() {
    currentC.dispose();
    newC.dispose();
    confirmC.dispose();
    vm.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'كلمة المرور الجديدة مطلوبة';
    if (s.contains(' ')) return 'بدون مسافات';
    if (s.length < 6) return '• 6 أحرف على الأقل';
    if (!RegExp(r'[A-Z]').hasMatch(s)) return '• حرف كبير واحد على الأقل (A-Z)';
    if (!RegExp(r'\d').hasMatch(s)) return '• رقم واحد على الأقل';
    if (!RegExp(r'[@#$%^&*()_\-+=\[\]{};:,.!?/\\|<>~`]').hasMatch(s)) {
      return '• رمز خاص واحد على الأقل (مثل @ أو # أو \$)';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (v != newC.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'حدث خطأ، حاول مرة أخرى')),
      );
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
                  validator: (v) => (v ?? '').isEmpty ? 'كلمة المرور الحالية مطلوبة' : null,
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
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
