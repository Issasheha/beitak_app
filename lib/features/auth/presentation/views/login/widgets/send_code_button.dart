import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class SendCodeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const SendCodeButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = SizeConfig.h(55.22);
    final radius = SizeConfig.w(30);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius), // تحديد الدائرية
            side: const BorderSide(
              color: AppColors.buttonBackground, // تحديد لون الحد
              width: 2, // تحديد سماكة الحد
            ),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? SizedBox(
                height: SizeConfig.h(24.36),
                width: SizeConfig.h(24.36),
                child: const CircularProgressIndicator(
                  color: AppColors.lightGreen,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: AppColors.lightGreen,
                  fontSize: SizeConfig.ts(15),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
