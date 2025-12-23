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
  String? _passwordServerError; // رح يضل موجود بس ما نستعمله ل invalid creds
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

  // ✅ SnackBar عربي واضح (لـ invalid credentials فقط)
  void _showInvalidCredSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          content: Text(
            'بيانات الدخول غير صحيحة، تأكد منها.',
            textAlign: TextAlign.right,
          ),
        ),
      );
  }

  // ✅ تحويل أرقام عربية/فارسية -> إنجليزية
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

  bool _isInvalidCredentials(String msg) {
    final m = msg.toLowerCase();
    return m.contains('invalid credentials') ||
        m.contains('unauthorized') ||
        m.contains('بيانات الدخول غير صحيحة') ||
        m.contains('incorrect') ||
        m.contains('wrong password');
  }

  bool _isProviderSuspended(String msg) {
    final m = msg.toLowerCase();
    return m.contains('provider_suspended') || m.contains('موقوف');
  }

  bool _isNetworkError(String msg) {
    final m = msg.toLowerCase();
    return m.contains('تعذر الاتصال بالإنترنت') ||
        m.contains('network') ||
        m.contains('connection') ||
        m.contains('socket');
  }

  bool _isValidationError(String msg) {
    final m = msg.toLowerCase();
    return m.contains('validation error') || m.contains('unprocessable') || m.contains('422');
  }

  void _applyNonCredentialErrors(String msg) {
    // ⚠️ لا تستخدمها لـ invalid credentials (لأننا بدنا SnackBar فقط)
    if (_isProviderSuspended(msg)) {
      _identifierServerError = 'حساب مزود الخدمة موقوف. يرجى التواصل مع الدعم.';
      _passwordServerError = null;
      _formError = null;
      return;
    }

    // ✅ “Validation error” ما لازم تظهر… نخليها عربية وتحت حقل البريد/الهاتف
    if (_isValidationError(msg)) {
      _identifierServerError = 'المدخلات غير صحيحة، تأكد من البريد الإلكتروني أو رقم الهاتف.';
      _passwordServerError = null;
      _formError = null; // ✅ مهم: ما تظهر تحت "هل نسيت كلمة السر؟"
      return;
    }

    if (_isNetworkError(msg)) {
      _formError = 'تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.';
      _identifierServerError = null;
      _passwordServerError = null;
      return;
    }

    // fallback عربي عام (بدون إنجليزي)
    _formError = 'حدث خطأ غير متوقع، حاول مرة أخرى.';
    _identifierServerError = null;
    _passwordServerError = null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _identifierServerError = null;
      _passwordServerError = null;
      _formError = null;
    });

    // ✅ validators (أخطاء تحت الحقول) قبل ما نوصل السيرفر
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final raw = _identifierCtrl.text.trim();
      final normalized = _normalizeArabicDigits(raw);
      final isEmail = normalized.contains('@');

      // ✅ لو هاتف: digits only (يدعم ٠٧٨-٦٠٤٦٠١١)
      final identifier = isEmail ? normalized.trim() : _digitsOnly(normalized);

      await ref.read(authControllerProvider.notifier).loginWithIdentifier(
            identifier: identifier,
            password: _passCtrl.text,
          );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '').trim();

      // ✅ أهم شرط: invalid credentials = SnackBar فقط
      if (_isInvalidCredentials(msg)) {
        setState(() {
          _identifierServerError = null;
          _passwordServerError = null;
          _formError = null;
        });
        _showInvalidCredSnackBar();
        return;
      }

      setState(() => _applyNonCredentialErrors(msg));
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

      // guest ما بدنا invalid creds هنا، بس نخليها عربية عامة لو صارت
      setState(() => _applyNonCredentialErrors(msg));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
