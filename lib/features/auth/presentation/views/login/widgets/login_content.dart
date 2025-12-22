import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/continue_as_guest_button.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/email_password_section.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/login_header.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/send_code_button.dart';
import 'package:flutter/material.dart';

class LoginContent extends StatefulWidget {
  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onMainActionPressed;
  final VoidCallback onContinueAsGuest;

  /// ✅ خطأ عام يظهر داخل الفورم بدل SnackBar
  final String? formErrorText;

  /// ✅ أخطاء تحت الحقول
  final String? identifierErrorText;
  final String? passwordErrorText;

  /// ✅ لمسح الأخطاء عند الكتابة
  final VoidCallback? onClearIdentifierError;
  final VoidCallback? onClearPasswordError;

  const LoginContent({
    super.key,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.onMainActionPressed,
    required this.onContinueAsGuest,
    this.formErrorText,
    this.identifierErrorText,
    this.passwordErrorText,
    this.onClearIdentifierError,
    this.onClearPasswordError,
  });

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final FocusNode _identifierFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  static const double _padding = 20.0;
  static const double _gap = 16.0;
  static const double _sectionGap = 24.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_identifierFocus);
    });
  }

  @override
  void dispose() {
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmall = mediaQuery.size.width < 360;
    final scale = isSmall ? 0.95 : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverSafeArea(
            sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: _padding).copyWith(
                top: _sectionGap,
                bottom: mediaQuery.viewInsets.bottom + _gap,
              ),
              sliver: SliverList.list(children: [
                LoginHeader(fontScale: scale),
                const SizedBox(height: _gap),

                _DescriptionText(scale: scale),
                const SizedBox(height: _sectionGap),

                EmailPasswordSection(
                  key: const ValueKey('email'),
                  emailController: widget.emailController,
                  passwordController: widget.passwordController,
                  formKey: widget.formKey,
                  isLoading: widget.isLoading,
                  identifierFocus: _identifierFocus,
                  passwordFocus: _passwordFocus,
                  onPasswordSubmitted: widget.onMainActionPressed,

                  identifierErrorText: widget.identifierErrorText,
                  passwordErrorText: widget.passwordErrorText,
                  onIdentifierChanged: widget.onClearIdentifierError,
                  onPasswordChanged: widget.onClearPasswordError,
                ),

                // ✅ خطأ عام (مثل الشبكة)
                if (widget.formErrorText != null &&
                    widget.formErrorText!.trim().isNotEmpty) ...[
                  SizedBox(height: SizeConfig.h(12)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.formErrorText!,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption11.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: _sectionGap),

                SendCodeButton(
                  onPressed:
                      widget.isLoading ? null : widget.onMainActionPressed,
                  text: 'تسجيل الدخول',
                  isLoading: widget.isLoading,
                ),
                const SizedBox(height: _gap),

                ContinueAsGuestButton(
                  onPressed: widget.isLoading ? null : widget.onContinueAsGuest,
                ),
                const SizedBox(height: _sectionGap),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final double scale;
  const _DescriptionText({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Text(
      'سجل دخولك باستخدام البريد الإلكتروني أو رقم الهاتف وكلمة المرور',
      textAlign: TextAlign.center,
      style: AppTextStyles.body14.copyWith(
        color: AppColors.textSecondary,
        fontSize: 15 * scale,
        height: 1.5,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
