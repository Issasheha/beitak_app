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

  String? _identifierServerError;
  String? _passwordServerError;
  String? _formError;

  @override
  void initState() {
    super.initState();

    _identifierCtrl.addListener(() {
      if (_identifierServerError != null || _formError != null) {
        setState(() {
          _identifierServerError = null;
          _formError = null;
        });
      }
    });

    _passCtrl.addListener(() {
      if (_passwordServerError != null || _formError != null) {
        setState(() {
          _passwordServerError = null;
          _formError = null;
        });
      }
    });
  }

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

              identifierErrorText: _identifierServerError,
              passwordErrorText: _passwordServerError,
              formErrorText: _formError,

              onClearIdentifierError: () {
                if (_identifierServerError != null || _formError != null) {
                  setState(() {
                    _identifierServerError = null;
                    _formError = null;
                  });
                }
              },
              onClearPasswordError: () {
                if (_passwordServerError != null || _formError != null) {
                  setState(() {
                    _passwordServerError = null;
                    _formError = null;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeArabicDigits(String input) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) {
      input = input.replaceAll(ar[i], en[i]);
    }
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < fa.length; i++) {
      input = input.replaceAll(fa[i], en[i]);
    }
    return input;
  }

  String _digitsOnly(String input) {
    final normalized = _normalizeArabicDigits(input);
    return normalized.replaceAll(RegExp(r'\D'), '');
  }

  void _applyServerError(String msg) {
    final m = msg.toLowerCase();

    // provider_suspended
    if (m.contains('provider_suspended') || m.contains('حساب مزود الخدمة موقوف')) {
      _identifierServerError = 'حساب مزود الخدمة موقوف';
      _passwordServerError = null;
      _formError = null;
      return;
    }

    // ✅ invalid credentials تحت الحقلين معًا
    if (m.contains('بيانات الدخول غير صحيحة') ||
        m.contains('invalid credentials') ||
        m.contains('unauthorized')) {
      final text =
          'بيانات الدخول غير صحيحة. تأكد من البريد/رقم الهاتف وكلمة المرور.';
      _identifierServerError = text;
      _passwordServerError = text;
      _formError = null;
      return;
    }

    // network
    if (m.contains('تعذر الاتصال بالإنترنت') ||
        m.contains('network') ||
        m.contains('connection')) {
      _formError = 'تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.';
      _identifierServerError = null;
      _passwordServerError = null;
      return;
    }

    _formError = msg;
    _identifierServerError = null;
    _passwordServerError = null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _identifierServerError = null;
      _passwordServerError = null;
      _formError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var identifierRaw = _identifierCtrl.text.trim();
      final password = _passCtrl.text;

      final normalized = _normalizeArabicDigits(identifierRaw);
      final isEmail = normalized.contains('@');

      // ✅ لو هاتف: شيل أي رموز/شرطات/مسافات وخليه digits only
      final identifier = isEmail ? normalized.trim() : _digitsOnly(normalized);

      await ref.read(authControllerProvider.notifier).loginWithIdentifier(
            identifier: identifier,
            password: password,
          );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      setState(() => _applyServerError(msg));

      // ✅ عشان تظهر أخطاء السيرفر تحت الحقول فورًا
      _formKey.currentState?.validate();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuest() async {
    setState(() {
      _identifierServerError = null;
      _passwordServerError = null;
      _formError = null;
      _isLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).continueAsGuest();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      setState(() => _applyServerError(msg));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
