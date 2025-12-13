import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class GuestBookingSheet extends StatefulWidget {
  const GuestBookingSheet({
    super.key,
    required this.onSendOtp,
    required this.onConfirm,
  });

  final Future<void> Function(String phone) onSendOtp;
  final Future<void> Function({
    required String name,
    required String phone,
    required String otp,
  }) onConfirm;

  @override
  State<GuestBookingSheet> createState() => _GuestBookingSheetState();
}

class _GuestBookingSheetState extends State<GuestBookingSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _otpSent = false;
  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.textPrimary),
    );
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return _toast('أدخل رقم الهاتف.');

    setState(() => _busy = true);
    try {
      await widget.onSendOtp(phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _busy = false;
      });
      _toast('تم إرسال رمز التحقق.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('فشل إرسال OTP: ${e.toString()}');
    }
  }

  Future<void> _confirm() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final otp = _otpCtrl.text.trim();

    if (name.isEmpty) return _toast('أدخل الاسم.');
    if (phone.isEmpty) return _toast('أدخل رقم الهاتف.');
    if (otp.isEmpty) return _toast('أدخل رمز التحقق.');

    setState(() => _busy = true);
    try {
      await widget.onConfirm(name: name, phone: phone, otp: otp);
      if (!mounted) return;
      Navigator.pop(context); // close sheet
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('فشل تأكيد الحجز: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(blurRadius: 18, color: Color(0x1A000000))],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تأكيد الحجز كضيف',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: SizeConfig.ts(16),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'أدخل رقم هاتفك لإرسال رمز تحقق (OTP) ثم أكمل الحجز.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                _field(label: 'الاسم', controller: _nameCtrl, hint: 'مثال: أحمد محمد'),
                _field(label: 'رقم الهاتف', controller: _phoneCtrl, hint: '+9627xxxxxxxx', ltr: true),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _otpSent
                      ? _field(
                          key: const ValueKey('otp_field'),
                          label: 'رمز التحقق (OTP)',
                          controller: _otpCtrl,
                          hint: '6 أرقام',
                          ltr: true,
                        )
                      : const SizedBox.shrink(key: ValueKey('otp_empty')),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _busy ? null : (_otpSent ? _confirm : _sendOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(_otpSent ? 'تأكيد الحجز' : 'إرسال OTP'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    Key? key,
    required String label,
    required TextEditingController controller,
    required String hint,
    bool ltr = false,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: SizeConfig.ts(13),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
            keyboardType: ltr ? TextInputType.phone : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.6),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
