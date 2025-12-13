import 'package:beitak_app/features/user/home/data/datasources/profile_remote_datasource.dart';
import 'package:beitak_app/features/user/home/data/repositories/profile_repository_impl.dart';
import 'package:beitak_app/features/user/home/domain/usecases/change_password_usecase.dart';
import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/network/api_client.dart';
import '../viewmodels/change_password_viewmodel.dart';

import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/routes/app_routes.dart';


class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
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
    final remote = ProfileRemoteDataSource(ApiClient.dio);
    final repo = ProfileRepositoryImpl(remote);
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

  void _smartBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('تغيير كلمة المرور'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _smartBack(context),
              ),
            ),
            body: Padding(
              padding: SizeConfig.padding(all: 16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    Text(
                      'الشروط:',
                      style: TextStyle(
                        fontSize: SizeConfig.ts(14),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(6)),
                    Text(
                      '• 6 أحرف على الأقل\n'
                      '• حرف كبير واحد على الأقل (A-Z)\n'
                      '• رقم واحد على الأقل\n'
                      '• رمز خاص واحد على الأقل (مثل @ أو # أو \$)\n'
                      '• بدون مسافات',
                      style: TextStyle(
                        fontSize: SizeConfig.ts(12),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(16)),

                    _PwdField(
                      label: 'كلمة المرور الحالية',
                      controller: currentC,
                      obscure: hideCurrent,
                      onToggle: () => setState(() => hideCurrent = !hideCurrent),
                      validator: (v) =>
                          (v ?? '').isEmpty ? 'كلمة المرور الحالية مطلوبة' : null,
                    ),
                    SizedBox(height: SizeConfig.h(12)),

                    _PwdField(
                      label: 'كلمة المرور الجديدة',
                      controller: newC,
                      obscure: hideNew,
                      onToggle: () => setState(() => hideNew = !hideNew),
                      validator: _validateNewPassword,
                    ),
                    SizedBox(height: SizeConfig.h(12)),

                    _PwdField(
                      label: 'تأكيد كلمة المرور الجديدة',
                      controller: confirmC,
                      obscure: hideConfirm,
                      onToggle: () => setState(() => hideConfirm = !hideConfirm),
                      validator: _validateConfirm,
                    ),

                    SizedBox(height: SizeConfig.h(18)),
                    SizedBox(
                      height: SizeConfig.h(48),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radius(14)),
                          ),
                        ),
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();
                                final ok =
                                    _formKey.currentState?.validate() ?? false;
                                if (!ok) return;

                              final success = await vm.submit(
  currentPassword: currentC.text,
  newPassword: newC.text,
  confirmPassword: confirmC.text,
);

                                if (!context.mounted) return;

                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('تم تغيير كلمة المرور بنجاح')),
                                  );
                                  _smartBack(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(vm.errorMessage ??
                                          'حدث خطأ، حاول مرة أخرى'),
                                    ),
                                  );
                                }
                              },
                        child: vm.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('حفظ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
