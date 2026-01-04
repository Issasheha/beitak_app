// lib/features/auth/presentation/views/register/register_view.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_scrollable_sheet.dart';
import 'package:beitak_app/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:beitak_app/features/auth/presentation/viewmodels/locations_providers.dart';
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

class _RegisterViewState extends ConsumerState<RegisterView>
    with RestorationMixin {
  final _formKey = GlobalKey<FormState>();

  // ✅ حفظ البيانات حتى لو راح التطبيق للخلفية ورجع
  late final RestorableTextEditingController _firstNameController =
      RestorableTextEditingController();
  late final RestorableTextEditingController _lastNameController =
      RestorableTextEditingController();
  late final RestorableTextEditingController _phoneController =
      RestorableTextEditingController();
  late final RestorableTextEditingController _emailController =
      RestorableTextEditingController();
  late final RestorableTextEditingController _passwordController =
      RestorableTextEditingController();

  final RestorableIntN _selectedCityId = RestorableIntN(null);
  final RestorableBool _isProvider = RestorableBool(false);
  final RestorableBool _acceptedTerms = RestorableBool(false);

  bool _isSubmitting = false;

  // ✅ أخطاء باك (مكرر) تعرض تحت الحقول عبر validator
  String? _emailBackendError;
  String? _phoneBackendError;

  // ✅ لمنع إضافة listeners أكثر من مرة
  bool _listenersAttached = false;

  @override
  String? get restorationId => 'register_view';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_firstNameController, 'first_name');
    registerForRestoration(_lastNameController, 'last_name');
    registerForRestoration(_phoneController, 'phone');
    registerForRestoration(_emailController, 'email');
    registerForRestoration(_passwordController, 'password');

    registerForRestoration(_selectedCityId, 'city_id');
    registerForRestoration(_isProvider, 'is_provider');
    registerForRestoration(_acceptedTerms, 'accepted_terms');

    // ✅ اربط listeners بعد التسجيل فقط
    if (!_listenersAttached) {
      _listenersAttached = true;

      _emailController.value.addListener(() {
        if (_emailBackendError != null) {
          setState(() => _emailBackendError = null);
        }
      });

      _phoneController.value.addListener(() {
        if (_phoneBackendError != null) {
          setState(() => _phoneBackendError = null);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // ❌ ممنوع نحط addListener هون لأنه Restorable controllers لسه مش Registered
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _selectedCityId.dispose();
    _isProvider.dispose();
    _acceptedTerms.dispose();
    super.dispose();
  }

  void _openTermsSheet() {
    showAppScrollableSheet(
      context: context,
      title: 'الشروط والأحكام',
      child: const Text(
        'ضع هنا نص الشروط والأحكام الطويل...\n\n'
        '✅ الآن هذا المحتوى قابل للتمرير على أي جهاز، ولن ينقص بسبب حجم الشاشة.\n\n'
        'يفضل تقسيم الشروط إلى نقاط وعناوين لتكون أوضح للمستخدم.',
        style: TextStyle(fontSize: 14, height: 1.6),
      ),
    );
  }

  void _openPrivacySheet() {
    showAppScrollableSheet(
      context: context,
      title: 'سياسة الخصوصية',
      child: const Text(
        'ضع هنا نص سياسة الخصوصية الطويل...\n\n'
        '✅ الآن هذا المحتوى قابل للتمرير على أي جهاز.',
        style: TextStyle(fontSize: 14, height: 1.6),
      ),
    );
  }

  // محاولة استخراج رسائل المكرر من استثناءات الباك
  void _applyBackendFieldErrors(String msg) {
    final m = msg.toLowerCase();

    final isEmailDup = m.contains('email') &&
        (m.contains('exist') ||
            m.contains('already') ||
            m.contains('used') ||
            m.contains('موجود') ||
            m.contains('مستخدم'));

    final isPhoneDup = (m.contains('phone') || m.contains('mobile')) &&
        (m.contains('exist') ||
            m.contains('already') ||
            m.contains('used') ||
            m.contains('موجود') ||
            m.contains('مستخدم'));

    if (isEmailDup) _emailBackendError = 'هذا البريد الإلكتروني مستخدم مسبقاً.';
    if (isPhoneDup) _phoneBackendError = 'هذا رقم الجوال مستخدم مسبقاً.';
  }

  Future<void> _onSubmit() async {
    setState(() {
      _emailBackendError = null;
      _phoneBackendError = null;
    });

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_selectedCityId.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المدينة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signupCustomer(
            firstName: _firstNameController.value.text.trim(),
            lastName: _lastNameController.value.text.trim(),
            phone: _phoneController.value.text.trim().isEmpty
                ? null
                : _phoneController.value.text.trim(),
            email: _emailController.value.text.trim().isEmpty
                ? null
                : _emailController.value.text.trim(),
            password: _passwordController.value.text,
            cityId: _selectedCityId.value!,
            areaId: 1,
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

      final msg = e.toString().replaceFirst('Exception: ', '').trim();

      setState(() {
        _applyBackendFieldErrors(msg);
      });

      if ((_emailBackendError != null) || (_phoneBackendError != null)) {
        _formKey.currentState?.validate();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isEmpty ? 'حدث خطأ، حاول مرة أخرى.' : msg),
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

    ref.watch(citiesProvider);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxHeight < 720;
              final basePadding = isSmall ? 16.0 : 20.0;
              final padding = SizeConfig.w(basePadding);
              final space = SizeConfig.h(isSmall ? 10 : 18);

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  padding,
                  padding,
                  padding,
                  padding + bottomInset + 12,
                ),
                child: Column(
                  children: [
                    RegisterHeader(
                      onLoginTap: () => context.go(AppRoutes.login),
                    ),
                    SizedBox(height: space),
                    RoleSelectionCard(
                      isProvider: _isProvider.value,
                      onRoleChanged: (v) =>
                          setState(() => _isProvider.value = v),
                    ),
                    SizedBox(height: space),
                    if (!_isProvider.value) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            RegisterForm(
                              isProvider: _isProvider.value,
                              firstNameController: _firstNameController.value,
                              lastNameController: _lastNameController.value,
                              phoneController: _phoneController.value,
                              emailController: _emailController.value,
                              passwordController: _passwordController.value,
                              selectedCityId: _selectedCityId.value,
                              onCityChanged: (v) =>
                                  setState(() => _selectedCityId.value = v),
                              emailBackendErrorText: _emailBackendError,
                              phoneBackendErrorText: _phoneBackendError,
                              onSubmit: _onSubmit,
                            ),
                            SizedBox(height: space),
                            _TermsAcceptanceField(
                              value: _acceptedTerms.value,
                              onChanged: (v) => setState(
                                  () => _acceptedTerms.value = v ?? false),
                              onOpenTerms: _openTermsSheet,
                              onOpenPrivacy: _openPrivacySheet,
                            ),
                          ],
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
    );
  }
}

class _TermsAcceptanceField extends FormField<bool> {
  _TermsAcceptanceField({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onOpenTerms,
    required VoidCallback onOpenPrivacy,
  }) : super(
          initialValue: value,
          validator: (v) {
            if (v != true) return 'يرجى الموافقة على الشروط والأحكام للمتابعة.';
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: state.value ?? false,
                      onChanged: (val) {
                        state.didChange(val);
                        onChanged(val);
                      },
                      activeColor: AppColors.lightGreen,
                    ),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'أوافق على ',
                            style: TextStyle(fontSize: 13),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: onOpenTerms,
                            child: const Text(
                              'الشروط والأحكام',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.lightGreen,
                              ),
                            ),
                          ),
                          const Text(
                            ' و',
                            style: TextStyle(fontSize: 13),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: onOpenPrivacy,
                            child: const Text(
                              'سياسة الخصوصية',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.lightGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
}
