// lib/features/auth/presentation/views/register/register_view.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:beitak_app/features/auth/presentation/providers/locations_providers.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/send_code_button.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_form.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_header.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/provider_intro_card.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/role_selection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  bool _isProvider = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int? _selectedCityId;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // هذا رح يشغّل validators تبع الحقول + dropdown
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المدينة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إدخال رقم الجوال أو البريد الإلكتروني على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signupCustomer(
            firstName: firstName,
            lastName: lastName,
            phone: phone.isEmpty ? null : phone,
            email: email.isEmpty ? null : email,
            password: password,
            cityId: _selectedCityId!,
            areaId: 1, // حالياً كما هو (بعدها منربطها مع Area dropdown)
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح ✅'),
          backgroundColor: AppColors.lightGreen,
        ),
      );

      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // مجرد مشاهدة الـ provider هون مش إلزامي، بس بفيد يعمل prefetch للمدن
    ref.watch(citiesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background, // ✅ مهم: يمنع أي أبيض من ورا
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: AppColors.background,
          width: double.infinity, // ✅
          height: double.infinity, // ✅ يغطي الشاشة كلها
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxHeight < 720;
                final basePadding = isSmall ? 16.0 : 20.0;
                final padding = SizeConfig.w(basePadding);
                final space = SizeConfig.h(isSmall ? 10 : 18);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    padding,
                    padding,
                    padding + keyboardHeight * 0.4,
                  ),
                  child: Column(
                    children: [
                      RegisterHeader(
                        onLoginTap: () => context.go(AppRoutes.login),
                      ),
                      SizedBox(height: space),
                      RoleSelectionCard(
                        isProvider: _isProvider,
                        onRoleChanged: (v) => setState(() => _isProvider = v),
                      ),
                      SizedBox(height: space),
                      if (!_isProvider) ...[
                        Form(
                          key: _formKey,
                          child: RegisterForm(
                            isProvider: _isProvider,
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            phoneController: _phoneController,
                            emailController: _emailController,
                            passwordController: _passwordController,

                            // ✅ المدينة
                            selectedCityId: _selectedCityId,
                            onCityChanged: (v) =>
                                setState(() => _selectedCityId = v),

                            onSubmit: _onSubmit,
                          ),
                        ),
                        SizedBox(height: space),
                        SendCodeButton(
                          onPressed: _isSubmitting ? null : _onSubmit,
                          text: 'إنشاء حساب',
                          isLoading: _isSubmitting,
                        ),
                      ] else ...[
                        ProviderIntroCard(
                          onStartApplication: () =>
                              context.push(AppRoutes.providerApplication),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
