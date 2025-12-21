// lib/features/auth/presentation/views/register/widgets/register_form.dart
import 'package:flutter/material.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/email_field.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/name_fields_row.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/password_fields.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/phone_field.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/city_dropdown_field.dart';

class RegisterForm extends StatelessWidget {
  final bool isProvider;

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final int? selectedCityId;
  final ValueChanged<int?> onCityChanged;

  final VoidCallback onSubmit;

  /// ✅ أخطاء من الباك لتظهر تحت الحقول
  final String? emailBackendErrorText;
  final String? phoneBackendErrorText;

  const RegisterForm({
    super.key,
    required this.isProvider,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.selectedCityId,
    required this.onCityChanged,
    required this.onSubmit,
    this.emailBackendErrorText,
    this.phoneBackendErrorText,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;
    final space = keyboardOpen ? 8.0 : 16.0;

    return isProvider ? _buildProviderForm(space) : _buildCitizenForm(space);
  }

  Widget _buildCitizenForm(double space) {
    return Column(
      children: [
        NameFieldsRow(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
        ),
        SizedBox(height: space),

        /// ✅ PhoneField: يقدر يتحقق من emailController + يعرض خطأ المكرر
        PhoneField(
          controller: phoneController,
          emailController: emailController,
          backendErrorText: phoneBackendErrorText,
        ),
        SizedBox(height: space),

        /// ✅ EmailField: يقدر يتحقق من phoneController + يعرض خطأ المكرر
        EmailField(
          controller: emailController,
          phoneController: phoneController,
          backendErrorText: emailBackendErrorText,
        ),
        SizedBox(height: space),

        CityDropdownField(
          value: selectedCityId,
          onChanged: onCityChanged,
        ),
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
    return const SizedBox.shrink();
  }
}
