// lib/features/auth/presentation/views/widgets/register_widgets/register_form.dart

import 'package:flutter/material.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/email_field.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/name_fields_row.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/password_fields.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/phone_field.dart';

class RegisterForm extends StatelessWidget {
  final bool isProvider;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final VoidCallback onSubmit;

  const RegisterForm({
    super.key,
    required this.isProvider,
    required this.phoneController,
    required this.emailController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;
    final space = keyboardOpen ? 8.0 : 16.0;

    return isProvider
        ? _buildProviderForm(space)
        : _buildCitizenForm(space);
  }

  Widget _buildCitizenForm(double space) {
    return Column(
      children: [
        const NameFieldsRow(),
        SizedBox(height: space),
        PhoneField(controller: phoneController),
        SizedBox(height: space),
        EmailField(controller: emailController),
        SizedBox(height: space),
        PasswordFields(onSubmit: onSubmit),
        SizedBox(height: space),
      ],
    );
  }

  Widget _buildProviderForm(double space) {
    return const Column(
      children: [
        SizedBox(height: 40),
        Text(
          'فورم مزوّد الخدمة سيتم تنفيذها لاحقاً',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
