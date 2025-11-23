// lib/features/home/presentation/views/request_widgets/share_phone_dialog.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class SharePhoneDialog extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onNotShare;

  const SharePhoneDialog({
    super.key,
    required this.onShare,
    required this.onNotShare,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.phone_android_rounded,
              size: 80, color: AppColors.lightGreen),
          const SizedBox(height: 24),
          Padding(
            padding: SizeConfig.padding(horizontal: 20),
            child: Text(
              'هل ترغب بمشاركة رقم جوالك مع مقدم الخدمة؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: SizeConfig.ts(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: SizeConfig.padding(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onNotShare,
                    child: Text('لا، شكرًا',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: SizeConfig.ts(16))),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      padding: SizeConfig.padding(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('نعم، شارك رقمي',
                        style: TextStyle(
                            color: Colors.white, fontSize: SizeConfig.ts(16))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
