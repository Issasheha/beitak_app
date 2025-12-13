// lib/features/user/home/presentation/views/request_service/widgets/otp_verify_dialog.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class OtpVerifyDialog extends StatefulWidget {
  final String phone;
  final Future<void> Function() onResend;
  final Future<void> Function(String otp) onVerify;

  const OtpVerifyDialog({
    super.key,
    required this.phone,
    required this.onResend,
    required this.onVerify,
  });

  @override
  State<OtpVerifyDialog> createState() => _OtpVerifyDialogState();
}

class _OtpVerifyDialogState extends State<OtpVerifyDialog> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'أدخل رمز التحقق');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onVerify(code);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onResend();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الرمز مرة أخرى')),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'تأكيد رقم الهاتف',
          style: TextStyle(
            fontSize: SizeConfig.ts(18),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'أرسلنا رمزًا إلى:\n${widget.phone}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            SizedBox(height: SizeConfig.h(12)),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              enabled: !_loading,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'رمز التحقق (6 أرقام)',
                errorText: _error,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
            TextButton(
              onPressed: _loading ? null : _resend,
              child: Text(
                'إعادة إرسال الرمز',
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                padding: SizeConfig.padding(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                _loading ? 'جارٍ التحقق...' : 'تأكيد',
                style: TextStyle(
                  fontSize: SizeConfig.ts(15),
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
