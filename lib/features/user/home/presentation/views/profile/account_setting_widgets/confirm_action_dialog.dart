import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

enum ConfirmMode { delete, logout }

class ConfirmActionDialog extends StatelessWidget {
  final ConfirmMode mode;
  const ConfirmActionDialog({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final isDelete = mode == ConfirmMode.delete;

    final title = isDelete ? 'حذف الحساب' : 'تسجيل الخروج';
    final desc = isDelete
        ? 'هل أنت متأكد أنك تريد حذف حسابك؟\nسيتم حذف جميع بياناتك ولا يمكن التراجع عن هذا الإجراء.'
        : 'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟';

    final primaryText = isDelete ? 'حذف الحساب' : 'تسجيل خروج';
    final primaryColor = isDelete ? Colors.red : const Color(0xFF22A35A);
    final icon = isDelete ? Icons.delete : Icons.logout;
    final iconColor = isDelete ? Colors.red : const Color(0xFF22A35A);

    return Dialog(
      insetPadding: SizeConfig.padding(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: SizeConfig.padding(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.o(0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                )
              ],
              border: Border.all(color: primaryColor.withValues(alpha: 0.30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: SizeConfig.h(26)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                SizedBox(height: SizeConfig.h(10)),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(12.2),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B6B6B),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: SizeConfig.h(16)),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.35)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: SizeConfig.ts(13),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF444444),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.w(10)),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          primaryText,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(13),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // دائرة الأيقونة فوق
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: SizeConfig.w(78),
                height: SizeConfig.w(78),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Icon(icon, color: iconColor, size: SizeConfig.w(40)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
