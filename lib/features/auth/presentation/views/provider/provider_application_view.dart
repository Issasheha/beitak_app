// lib/features/auth/presentation/views/provider/provider_application_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/providers/provider_application_controller.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_availability_step.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_business_info_step.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_personal_info_step.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_stepper_header.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_verification_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProviderApplicationView extends ConsumerStatefulWidget {
  const ProviderApplicationView({super.key});

  @override
  ConsumerState<ProviderApplicationView> createState() =>
      _ProviderApplicationViewState();
}

class _ProviderApplicationViewState
    extends ConsumerState<ProviderApplicationView> {
  int _currentStep = 0;

  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _availabilityFormKey = GlobalKey<FormState>();
  final _verificationFormKey = GlobalKey<FormState>();

  // === بيانات الشخصية ===
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _termsAccepted = false;
  String? _selectedCity;

  // === بيانات العمل ===
  final TextEditingController _businessNameCtrl = TextEditingController();
  final TextEditingController _experienceCtrl = TextEditingController();

  // pricing
  final TextEditingController _hourlyRateCtrl = TextEditingController();
  final TextEditingController _fixedPriceCtrl = TextEditingController();

  // optional bio
  final TextEditingController _bioCtrl = TextEditingController();

  String? _selectedCategory;
  Set<String> _languages = {'العربية'};
  Set<String> _serviceAreas = {};

  // === التوفر ===
  Set<String> _availableDays = {
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  };
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

  // optional
  String _cancellationPolicy = '';

  // === الملفات ===
  String? _idDocPath;
  String? _licenseDocPath;
  String? _policeDocPath;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();

    _businessNameCtrl.dispose();
    _experienceCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _fixedPriceCtrl.dispose();
    _bioCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final appState = ref.watch(providerApplicationControllerProvider);
    final isSubmitting = appState.isSubmitting;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.textPrimary,
          title: Text(
            'طلب الانضمام كمزوّد خدمة',
            style: AppTextStyles.body16.copyWith(
              color: AppColors.textPrimary,
              fontSize: SizeConfig.ts(15),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            ProviderStepperHeader(currentStep: _currentStep),
            SizeConfig.v(4),
            Expanded(
              child: SingleChildScrollView(
                padding: SizeConfig.padding(left: 16, right: 16, top: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius:
                        BorderRadius.circular(SizeConfig.radius(20)),
                    boxShadow: [AppColors.primaryShadow],
                  ),
                  child: Padding(
                    padding: SizeConfig.padding(
                      left: 20,
                      right: 20,
                      top: 18,
                      bottom: 20,
                    ),
                    child: _buildStepBody(),
                  ),
                ),
              ),
            ),
            _buildBottomButtons(isSubmitting: isSubmitting),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_currentStep) {
      case 0:
        return ProviderPersonalInfoStep(
          formKey: _personalFormKey,
          firstNameController: _firstNameCtrl,
          lastNameController: _lastNameCtrl,
          phoneController: _phoneCtrl,
          emailController: _emailCtrl,
          passwordController: _passwordCtrl,
          termsAccepted: _termsAccepted,
          onTermsChanged: (v) => setState(() => _termsAccepted = v),
          onCityChanged: (v) => _selectedCity = v,
        );

      case 1:
        return ProviderBusinessInfoStep(
          formKey: _businessFormKey,
          businessNameController: _businessNameCtrl,
          experienceYearsController: _experienceCtrl,
          hourlyRateController: _hourlyRateCtrl,
          fixedPriceController: _fixedPriceCtrl,
          descriptionController: _bioCtrl,
          onLanguagesChanged: (langs) => _languages = langs,
          onServiceAreasChanged: (areas) => _serviceAreas = areas,
          onCategoryChanged: (v) => _selectedCategory = v,
        );

      case 2:
        return ProviderAvailabilityStep(
          formKey: _availabilityFormKey,
          onDaysChanged: (days) => _availableDays = days,
          onStartChanged: (t) => _startTime = t,
          onEndChanged: (t) => _endTime = t,
          onCancellationPolicyChanged: (txt) => _cancellationPolicy = txt,
        );

      case 3:
      default:
        return ProviderVerificationStep(
          formKey: _verificationFormKey,
          onIdSelected: (path) => _idDocPath = path,
          onLicenseSelected: (path) => _licenseDocPath = path,
          onCertificateSelected: (path) => _policeDocPath = path,
        );
    }
  }

  Widget _buildBottomButtons({required bool isSubmitting}) {
    final isLastStep = _currentStep == 3;

    final disableNextBecauseTerms = _currentStep == 0 && !_termsAccepted;

    return Container(
      color: AppColors.background,
      padding: SizeConfig.padding(left: 16, right: 16, top: 8, bottom: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed:
                    isSubmitting ? null : () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.h(12)),
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                  ),
                ),
                child: Text(
                  'رجوع',
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(14),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) SizeConfig.hSpace(10),
          Expanded(
            child: ElevatedButton(
              onPressed: (isSubmitting || disableNextBecauseTerms)
                  ? null
                  : _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: SizeConfig.h(12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                  side: const BorderSide(
                    color: AppColors.buttonBackground,
                    width: 2,
                  ),
                ),
              ),
              child: isSubmitting
                  ? SizedBox(
                      height: SizeConfig.h(18),
                      width: SizeConfig.h(18),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : Text(
                      isLastStep ? 'إرسال الطلب' : 'التالي',
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(14),
                        color: (isSubmitting || disableNextBecauseTerms)
                            ? AppColors.textSecondary
                            : AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onNextPressed() async {
    final currentKey = [
      _personalFormKey,
      _businessFormKey,
      _availabilityFormKey,
      _verificationFormKey,
    ][_currentStep];

    if (!(currentKey.currentState?.validate() ?? false)) return;

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final businessName = _businessNameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();
    final experienceYears = int.tryParse(_experienceCtrl.text.trim()) ?? 0;

    final hourlyRate =
        double.tryParse(_hourlyRateCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;
    final fixedPrice =
        double.tryParse(_fixedPriceCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

    String formatTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final workingStart = formatTime(_startTime);
    final workingEnd = formatTime(_endTime);

    final ok = await ref
        .read(providerApplicationControllerProvider.notifier)
        .submitFullApplication(
          firstName: firstName,
          lastName: lastName,
          phone: phone.isNotEmpty ? phone : null,
          email: email.isNotEmpty ? email : null,
          password: password,

          // ✅ مهم: نخليهم String (بدون null) عشان ما نكسر signature الحالي
          businessName: businessName,
          bio: bio,

          experienceYears: experienceYears,
          hourlyRate: hourlyRate,

          languages: _languages.toList(),
          serviceAreas: _serviceAreas.toList(),
          availableDaysAr: _availableDays.toList(),
          workingStart: workingStart,
          workingEnd: workingEnd,
          idDocPath: _idDocPath,
          licenseDocPath: _licenseDocPath,
          policeDocPath: _policeDocPath,
        );

    if (!mounted) return;

    final err = ref.read(providerApplicationControllerProvider).errorMessage;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال طلبك كمزوّد خدمة وسيتم مراجعته من قبل الإدارة.',
            style: AppTextStyles.body14,
          ),
          backgroundColor: AppColors.lightGreen,
        ),
      );
      context.go(AppRoutes.providerHome);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err ?? 'تعذر إرسال الطلب، حاول مرة أخرى.',
            style: AppTextStyles.body14,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
