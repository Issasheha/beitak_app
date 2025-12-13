// lib/features/auth/presentation/views/register/widgets/register_form.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/email_field.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/name_fields_row.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/password_fields.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/phone_field.dart';

class RegisterForm extends StatelessWidget {
  final bool isProvider;

  // Controllers مهمين للتسجيل في الـ backend
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  // يستدعى لما الفورم تكون Valid ونبغى نرسل الطلب
  final VoidCallback onSubmit;

  const RegisterForm({
    super.key,
    required this.isProvider,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;
    final space = keyboardOpen ? 8.0 : 16.0;

    return isProvider ? _buildProviderForm(space) : _buildCitizenForm(space);
  }

  /// نموذج تسجيل "المستخدم العادي"
  Widget _buildCitizenForm(double space) {
    return Column(
      children: [
        NameFieldsRow(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
        ),
        SizedBox(height: space),

        PhoneField(controller: phoneController),
        SizedBox(height: space),

        EmailField(controller: emailController),
        SizedBox(height: space),

        PasswordFields(
          passwordController: passwordController,
          onSubmit: onSubmit,
        ),
        SizedBox(height: space),
      ],
    );
  }

  Widget _buildProviderForm(double space) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          'نموذج مزوّد الخدمة سيتم تنفيذه لاحقاً',
          style: AppTextStyles.body14.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
