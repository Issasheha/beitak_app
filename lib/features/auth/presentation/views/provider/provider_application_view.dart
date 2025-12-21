import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/providers/provider_application_controller.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/providers/provider_onboarding_data_provider.dart';
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

class _ProviderApplicationViewState extends ConsumerState<ProviderApplicationView> {
  int _currentStep = 0;

  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _availabilityFormKey = GlobalKey<FormState>();
  final _verificationFormKey = GlobalKey<FormState>();

  // === Step 0: personal ===
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _termsAccepted = false;
  int? _selectedCityId;

  // === Step 1: business ===
  final TextEditingController _businessNameCtrl = TextEditingController();
  final TextEditingController _experienceCtrl = TextEditingController();
  final TextEditingController _hourlyRateCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();

  int? _selectedCategoryId;
  Set<String> _languages = {'العربية'};
  Set<String> _serviceAreas = {}; // store slugs

  // === Step 2: availability ===
  Set<String> _availableDays = {
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  };
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

  final TextEditingController _cancellationPolicyCtrl = TextEditingController();

  // === Step 3: files ===
  String? _idDocPath;
  String? _licenseDocPath;
  String? _policeDocPath;

  String? _idFileName;
  String? _licenseFileName;
  String? _policeFileName;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();

    _businessNameCtrl.dispose();
    _experienceCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _bioCtrl.dispose();

    _cancellationPolicyCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final appState = ref.watch(providerApplicationControllerProvider);
    final isSubmitting = appState.isSubmitting;

    final onboardingAsync = ref.watch(providerOnboardingDataProvider);

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
        body: onboardingAsync.when(
          loading: () => _buildLoading(),
          error: (e, _) => _buildError(e.toString()),
          data: (data) {
            // ✅ ضمان city default إذا فاضي
            _selectedCityId ??= data.cities.isNotEmpty ? data.cities.first.id : null;

            return Column(
              children: [
                ProviderStepperHeader(currentStep: _currentStep),
                SizeConfig.v(4),
                Expanded(
                  child: SingleChildScrollView(
                    padding: SizeConfig.padding(left: 16, right: 16, top: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
                        boxShadow: [AppColors.primaryShadow],
                      ),
                      child: Padding(
                        padding: SizeConfig.padding(left: 20, right: 20, top: 18, bottom: 20),
                        child: _buildStepBody(data),
                      ),
                    ),
                  ),
                ),
                _buildBottomButtons(isSubmitting: isSubmitting),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryGreen),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: SizeConfig.padding(all: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تعذر تحميل البيانات',
              style: AppTextStyles.title18.copyWith(color: AppColors.textPrimary),
            ),
            SizeConfig.v(8),
            Text(
              msg,
              style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizeConfig.v(12),
            ElevatedButton(
              onPressed: () => ref.refresh(providerOnboardingDataProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody(ProviderOnboardingData data) {
    switch (_currentStep) {
      case 0:
        return ProviderPersonalInfoStep(
          formKey: _personalFormKey,
          firstNameController: _firstNameCtrl,
          lastNameController: _lastNameCtrl,
          phoneController: _phoneCtrl,
          emailController: _emailCtrl,
          passwordController: _passwordCtrl,
          confirmPasswordController: _confirmPasswordCtrl,
          termsAccepted: _termsAccepted,
          onTermsChanged: (v) => setState(() => _termsAccepted = v),
          cities: data.cities,
          selectedCityId: _selectedCityId,
          onCityChanged: (v) => setState(() => _selectedCityId = v),
          lockPersonalInfo: ref.watch(providerApplicationControllerProvider).isRegistered,
        );

      case 1:
        return ProviderBusinessInfoStep(
          formKey: _businessFormKey,
          businessNameController: _businessNameCtrl,
          experienceYearsController: _experienceCtrl,
          hourlyRateController: _hourlyRateCtrl,
          descriptionController: _bioCtrl,
          categories: data.categories,
          selectedCategoryId: _selectedCategoryId,
          onCategoryChanged: (v) => setState(() => _selectedCategoryId = v),
          selectedLanguages: _languages,
          onLanguagesChanged: (langs) => setState(() => _languages = langs),
          selectedServiceAreas: _serviceAreas,
          onServiceAreasChanged: (areas) => setState(() => _serviceAreas = areas),
          cities: data.cities,
        );

      case 2:
        return ProviderAvailabilityStep(
          formKey: _availabilityFormKey,
          selectedDays: _availableDays,
          startTime: _startTime,
          endTime: _endTime,
          onDaysChanged: (days) => setState(() => _availableDays = days),
          onStartChanged: (t) => setState(() => _startTime = t),
          onEndChanged: (t) => setState(() => _endTime = t),
          cancellationController: _cancellationPolicyCtrl,
          onCancellationPolicyChanged: (_) => setState(() {}),
        );

      case 3:
      default:
        return ProviderVerificationStep(
          formKey: _verificationFormKey,
          idPath: _idDocPath,
          licensePath: _licenseDocPath,
          policePath: _policeDocPath,
          idFileName: _idFileName,
          licenseFileName: _licenseFileName,
          policeFileName: _policeFileName,
          onIdSelected: (path) => setState(() {
            _idDocPath = path;
            _idFileName = path == null ? null : (path.split('/').last);
          }),
          onLicenseSelected: (path) => setState(() {
            _licenseDocPath = path;
            _licenseFileName = path == null ? null : (path.split('/').last);
          }),
          onPoliceSelected: (path) => setState(() {
            _policeDocPath = path;
            _policeFileName = path == null ? null : (path.split('/').last);
          }),
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
                onPressed: isSubmitting ? null : () => setState(() => _currentStep--),
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
              onPressed: (isSubmitting || disableNextBecauseTerms) ? null : _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: SizeConfig.h(12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                  side: const BorderSide(color: AppColors.buttonBackground, width: 2),
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
    final appState = ref.read(providerApplicationControllerProvider);

    final currentKey = [
      _personalFormKey,
      _businessFormKey,
      _availabilityFormKey,
      _verificationFormKey,
    ][_currentStep];

    if (!(currentKey.currentState?.validate() ?? false)) return;

    // ✅ Step 0: Register EARLY to show duplicate errors immediately
    if (_currentStep == 0 && !appState.isRegistered) {
      final firstName = _firstNameCtrl.text.trim();
      final lastName = _lastNameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      final cityId = _selectedCityId;

      if (cityId == null) {
        _showSnack('المحافظة مطلوبة', isError: true);
        return;
      }

      final ok = await ref.read(providerApplicationControllerProvider.notifier).registerProviderEarly(
            firstName: firstName,
            lastName: lastName,
            phone: phone.isNotEmpty ? phone : null,
            email: email.isNotEmpty ? email : null,
            password: password,
            cityId: cityId,
          );

      if (!mounted) return;

      if (!ok) {
        final err = ref.read(providerApplicationControllerProvider).errorMessage;
        _showSnack(err ?? 'تعذر إنشاء الحساب، حاول مرة أخرى.', isError: true);
        return;
      }

      _showSnack('تم إنشاء الحساب بنجاح، أكمل باقي البيانات.', isError: false);

      setState(() => _currentStep++);
      return;
    }

    // ✅ normal next
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }

    // ✅ Last step: complete profile
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      _showSnack('فئة الخدمة مطلوبة', isError: true);
      return;
    }

    final experienceYears = int.tryParse(_experienceCtrl.text.trim()) ?? 0;
    final hourlyRate = double.tryParse(_hourlyRateCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

    String formatTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final workingStart = formatTime(_startTime);
    final workingEnd = formatTime(_endTime);

    final ok = await ref.read(providerApplicationControllerProvider.notifier).completeProviderProfile(
          businessName: _businessNameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          experienceYears: experienceYears,
          hourlyRate: hourlyRate,
          categoryId: categoryId,
          languages: _languages.toList(),
          serviceAreas: _serviceAreas.toList(), // slugs
          availableDaysAr: _availableDays.toList(),
          workingStart: workingStart,
          workingEnd: workingEnd,
          cancellationPolicy: _cancellationPolicyCtrl.text.trim(),
          idDocPath: _idDocPath,
          licenseDocPath: _licenseDocPath,
          policeDocPath: _policeDocPath,
        );

    if (!mounted) return;

    if (ok) {
      _showSnack(
        'تم إرسال طلبك كمزوّد خدمة وسيتم مراجعته من قبل الإدارة.',
        isError: false,
      );
      context.go(AppRoutes.providerHome);
    } else {
      final err = ref.read(providerApplicationControllerProvider).errorMessage;
      _showSnack(err ?? 'تعذر إرسال الطلب، حاول مرة أخرى.', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.body14),
        backgroundColor: isError ? Colors.red : AppColors.lightGreen,
      ),
    );
  }
}
