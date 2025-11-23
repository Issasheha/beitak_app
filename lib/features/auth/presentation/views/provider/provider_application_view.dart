import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_availability_step.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_business_info_step.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_personal_info_step.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_stepper_header.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/provider_verification_step.dart';
import 'package:flutter/material.dart';

class ProviderApplicationView extends StatefulWidget {
  const ProviderApplicationView({super.key});

  @override
  State<ProviderApplicationView> createState() =>
      _ProviderApplicationViewState();
}

class _ProviderApplicationViewState extends State<ProviderApplicationView> {
  int _currentStep = 0;

  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _availabilityFormKey = GlobalKey<FormState>();
  final _verificationFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

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
            style: TextStyle(
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
                    borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
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
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_currentStep) {
      case 0:
        return ProviderPersonalInfoStep(formKey: _personalFormKey);
      case 1:
        return ProviderBusinessInfoStep(formKey: _businessFormKey);
      case 2:
        return ProviderAvailabilityStep(formKey: _availabilityFormKey);
      case 3:
      default:
        return ProviderVerificationStep(formKey: _verificationFormKey);
    }
  }

  Widget _buildBottomButtons() {
    final isLastStep = _currentStep == 3;

    return Container(
      color: AppColors.background,
      padding: SizeConfig.padding(left: 16, right: 16, top: 8, bottom: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: SizeConfig.h(12)),
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SizeConfig.radius(16)),
                  ),
                ),
                child: Text(
                  'رجوع',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(14),
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) SizeConfig.hSpace(10),
          Expanded(
            child: ElevatedButton(
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding:
                    EdgeInsets.symmetric(vertical: SizeConfig.h(12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SizeConfig.radius(16),
                  
                  ),
                  side: const BorderSide(
              color: AppColors.buttonBackground, // تحديد لون الحد
              width: 2, // تحديد سماكة الحد
            ),
                ),
              ),
              child: Text(
                isLastStep ? 'إرسال الطلب' : 'التالي',
                style: TextStyle(
                  fontSize: SizeConfig.ts(14),
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'assets/fonts/Cairo-Regular.ttf'
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNextPressed() {
    final currentKey = [
      _personalFormKey,
      _businessFormKey,
      _availabilityFormKey,
      _verificationFormKey,
    ][_currentStep];

    if (currentKey.currentState?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الطلب بنجاح (تجريبي).')),
        );
      }
    }
  }
}
