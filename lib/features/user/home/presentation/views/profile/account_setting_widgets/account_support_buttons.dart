import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

import 'confirm_action_dialog.dart';

class AccountSupportButtons extends StatelessWidget {
  final Future<void> Function() onLogout;

  const AccountSupportButtons({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Logout
        SizedBox(
          width: double.infinity,
          height: SizeConfig.h(48),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
              ),
            ),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                barrierDismissible: true,
                builder: (_) => const ConfirmActionDialog(
                  mode: ConfirmMode.logout,
                ),
              );

              if (ok == true) {
                await onLogout();
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
