import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/auth/presentation/viewmodels/register_view_model.dart';
import 'package:beitak_app/features/auth/presentation/views/login/widgets/send_code_button.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_form.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/register_header.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/provider_intro_card.dart';
import 'package:beitak_app/features/auth/presentation/views/register/widgets/role_selection_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _isProvider = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers للهاتف والإيميل عشان نتحقق من شرط "واحد منهم على الأقل"
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late final RegisterViewModel _viewModel;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // 1) Validate كل الحقول
    if (!_formKey.currentState!.validate()) return;

    // 2) تحقق من شرط QA: لازم يكون فيه إمّا إيميل أو رقم جوال على الأقل
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (phone.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('يجب إدخال رقم الجوال أو البريد الإلكتروني على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3) إرسال الطلب (حاليًا dummy عبر ViewModel)
    setState(() => _isSubmitting = true);
    final success = await _viewModel.submitRegistration();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('تم إنشاء الحساب بنجاح، يمكنك تسجيل الدخول الآن.'),
          backgroundColor: AppColors.lightGreen,
        ),
      );
      context.pushReplacement(AppRoutes.login);
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: AppColors.background,
          child: Stack(
            children: [
              SafeArea(
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
                            onLoginTap: () =>
                                context.pushReplacement(AppRoutes.login),
                          ),
                          SizedBox(height: space),
                          RoleSelectionCard(
                            isProvider: _isProvider,
                            onRoleChanged: (v) =>
                                setState(() => _isProvider = v),
                          ),
                          SizedBox(height: space),
                          if (!_isProvider) ...[
                            Form(
                              key: _formKey,
                              child: RegisterForm(
                                isProvider: _isProvider,
                                phoneController: _phoneController,
                                emailController: _emailController,
                                onSubmit: _onSubmit,
                              ),
                            ),
                            SizedBox(height: space),
                            SendCodeButton(
                              onPressed:
                                  _isSubmitting ? null : _onSubmit,
                              text: 'إنشاء حساب',
                              isLoading: _isSubmitting,
                            ),
                          ] else ...[
                            ProviderIntroCard(
                              onStartApplication: () => context
                                  .push(AppRoutes.providerApplication),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
