import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/login_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginViewBody extends ConsumerStatefulWidget {
  const LoginViewBody({super.key});

  @override
  ConsumerState<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends ConsumerState<LoginViewBody> {
  final TextEditingController _identifierCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              onMainActionPressed: _handleLogin,
              onContinueAsGuest: _handleGuest,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Validation بسيط قبل الإرسال (مثل ما كنت عامل سابقًا)
      var identifier = _identifierCtrl.text.trim();
      final password = _passCtrl.text;

      final isEmail = identifier.contains('@');
      if (!isEmail) {
        final normalized = identifier.replaceAll(RegExp(r'\D'), '');
        if (normalized.length != 10 ||
            !normalized.startsWith('07') ||
            !['5', '7', '8', '9'].contains(normalized[2])) {
          throw Exception('رقم الهاتف غير صالح');
        }
        identifier = normalized;
      } else {
        final emailRegex =
            RegExp(r'^[^.][\w\-.]+@([\w-]+\.)+[\w-]{2,4}[^.]$');
        if (!emailRegex.hasMatch(identifier) ||
            identifier.contains('..') ||
            identifier.contains('@@') ||
            identifier.contains(' ') ||
            !identifier.contains('.') ||
            identifier.startsWith('.') ||
            identifier.endsWith('.')) {
          throw Exception('البريد الإلكتروني غير صالح');
        }
      }

      final trimmedPassword = password.trim();
      if (trimmedPassword.length < 6 || trimmedPassword.isEmpty || password.contains(' ')) {
        throw Exception('كلمة المرور غير صالحة');
      }

      await ref.read(authControllerProvider.notifier).loginWithIdentifier(
            identifier: identifier,
            password: password,
          );

      // ✅ لا تعمل Navigation هنا
      // الراوتر سيعمل redirect تلقائيًا حسب AuthState (+ from لو موجود)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuest() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).continueAsGuest();
      // ✅ بدون Navigation
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
