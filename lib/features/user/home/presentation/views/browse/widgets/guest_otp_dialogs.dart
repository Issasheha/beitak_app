import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class GuestInfo {
  final String name;
  final String phone;

  const GuestInfo({required this.name, required this.phone});
}

Future<GuestInfo?> showGuestInfoDialog(BuildContext context) async {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  String? error;

  return showDialog<GuestInfo>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      SizeConfig.init(ctx);
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                'معلومات الحجز (ضيف)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: SizeConfig.ts(16)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: 'الاسم الكامل'),
                  ),
                  SizedBox(height: SizeConfig.h(10)),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: 'رقم الهاتف (مثال: +9627...)'),
                  ),
                  if (error != null) ...[
                    SizedBox(height: SizeConfig.h(10)),
                    Text(
                      error!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: SizeConfig.ts(12.5)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBackground),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();

                    if (name.isEmpty || phone.isEmpty) {
                      setState(() => error = 'الاسم ورقم الهاتف مطلوبان.');
                      return;
                    }

                    Navigator.pop(ctx, GuestInfo(name: name, phone: phone));
                  },
                  child: const Text('متابعة'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<String?> showOtpDialog(BuildContext context) async {
  final otpCtrl = TextEditingController();
  String? error;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      SizeConfig.init(ctx);
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                'أدخل رمز التحقق',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: SizeConfig.ts(16)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'OTP (6 أرقام)'),
                  ),
                  if (error != null) ...[
                    SizedBox(height: SizeConfig.h(10)),
                    Text(
                      error!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: SizeConfig.ts(12.5)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBackground),
                  onPressed: () {
                    final otp = otpCtrl.text.trim();
                    if (otp.length < 4) {
                      setState(() => error = 'أدخل رمز صحيح.');
                      return;
                    }
                    Navigator.pop(ctx, otp);
                  },
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
