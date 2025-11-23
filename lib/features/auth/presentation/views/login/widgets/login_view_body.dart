// lib/features/auth/presentation/views/login_view_body.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/auth/presentation/viewmodels/login_view_model.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/login_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  final TextEditingController _identifierCtrl = TextEditingController(); // إيميل أو هاتف
  final TextEditingController _passCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginViewModel _viewModel = LoginViewModel();

  bool _isLoading = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          SafeArea(
            child: LoginContent(
              isLoading: _isLoading,
              emailController: _identifierCtrl,
              passwordController: _passCtrl,
              formKey: _formKey,
              onMainActionPressed: _handleMainActionPressed,
              onContinueAsGuest: _handleContinueAsGuest,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMainActionPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await _viewModel.loginWithIdentifier(
      identifier: _identifierCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (mounted) setState(() => _isLoading = false);

    if (success) {
      _goToHomeOrPrevious();
    } else if (_viewModel.lastErrorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.lastErrorMessage!)),
      );
    }
  }

  Future<void> _handleContinueAsGuest() async {
    setState(() => _isLoading = true);
    await _viewModel.continueAsGuest();
    if (mounted) setState(() => _isLoading = false);
    _goToHomeOrPrevious();
  }

  /// بدلاً من الذهاب دائماً إلى الـ Home، نحاول أولاً
  /// أن نرجع المستخدم إلى الصفحة التي جاء منها (from)
  /// إذا كانت موجودة في query params.
  void _goToHomeOrPrevious() {
    if (!mounted) return;

    // نقرأ الـ URI الحالي من GoRouterState بدل GoRouter
    final uri = GoRouterState.of(context).uri;
    final from = uri.queryParameters['from'];

    if (from != null &&
        from.isNotEmpty &&
        from != AppRoutes.login &&
        from != AppRoutes.splash &&
        from != AppRoutes.onboarding) {
      // رجّعه للصفحة التي كان ناوي يفتحها
      context.go(from);
    } else {
      // لا يوجد from → نستخدم السلوك الطبيعي: الذهاب للـ Home
      context.go(AppRoutes.home);
    }
  }
}
