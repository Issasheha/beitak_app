import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';

class AccountDangerZone extends StatelessWidget {
  const AccountDangerZone({
    super.key,
    required this.onDeleteAccount,
  });

  final Future<bool> Function() onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => const _ConfirmDangerDialog(
              title: 'حذف الحساب',
              message:
                  'هل أنت متأكد أنك تريد حذف حسابك؟\n'
                  'سيتم حذف جميع بياناتك ولا يمكن التراجع عن هذا الإجراء.',
              confirmText: 'حذف الحساب',
              cancelText: 'إلغاء',
            ),
          );

          if (confirmed != true) return;

          final ok = await onDeleteAccount();
          if (!context.mounted) return;

          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حذف الحساب بنجاح')),
            );
            context.go(AppRoutes.login);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('حدث خطأ، حاول مرة أخرى')),
            );
          }
        },
        child: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: SizeConfig.w(10)),
            Expanded(
              child: Text(
                'حذف الحساب',
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDangerDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  const _ConfirmDangerDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.35), width: 2),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red, size: 40),
            ),
            SizedBox(height: SizeConfig.h(10)),
            Text(
              title,
              style: TextStyle(
                fontSize: SizeConfig.ts(16),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: SizeConfig.h(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeConfig.ts(12.5),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: SizeConfig.h(14)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                SizedBox(width: SizeConfig.w(10)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
