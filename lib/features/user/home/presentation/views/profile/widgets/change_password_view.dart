// lib/features/auth/presentation/views/change_password_view.dart

import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // لاحقًا: ربط مع Firebase أو API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح!'),
          backgroundColor: AppColors.lightGreen,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'تغيير كلمة المرور',
            style: TextStyle(fontSize: SizeConfig.ts(20), fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: SizeConfig.padding(all: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Glass Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: SizeConfig.padding(all: 24),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.4),),
                        ),
                        child: Column(
                          children: [
                            // كلمة المرور الحالية
                            _buildPasswordField(
                              controller: _currentPasswordController,
                              label: 'كلمة المرور الحالية',
                              obscure: _obscureCurrent,
                              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                            ),
                            SizeConfig.v(20),

                            // كلمة المرور الجديدة
                            _buildPasswordField(
                              controller: _newPasswordController,
                              label: 'كلمة المرور الجديدة',
                              obscure: _obscureNew,
                              onToggle: () => setState(() => _obscureNew = !_obscureNew),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'مطلوب';
                                if (v.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
                                return null;
                              },
                            ),
                            SizeConfig.v(20),

                            // تأكيد كلمة المرور
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: 'تأكيد كلمة المرور الجديدة',
                              obscure: _obscureConfirm,
                              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              validator: (v) {
                                if (v != _newPasswordController.text) return 'كلمتا المرور غير متطابقتين';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizeConfig.v(40),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        padding: SizeConfig.padding(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      child: Text(
                        'حفظ التغييرات',
                        style: TextStyle(fontSize: SizeConfig.ts(18), fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        SizeConfig.v(8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '•••••',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: SizeConfig.padding(horizontal: 20, vertical: 18),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary),
              onPressed: onToggle,
            ),
          ),
          validator: validator ?? (v) => v!.isEmpty ? 'مطلوب' : null,
        ),
      ],
    );
  }
}