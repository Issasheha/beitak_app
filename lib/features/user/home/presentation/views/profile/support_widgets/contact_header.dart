// lib/features/support/presentation/views/support_widgets/contact_header.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ContactHeader extends StatelessWidget {
  const ContactHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SizeConfig.padding(all: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightGreen, AppColors.lightGreen.withValues(alpha: 0.85),],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.lightGreen.withValues(alpha: 0.95), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.headset_mic_rounded, size: 70, color: Colors.white),
          SizeConfig.v(20),
          Text(
            'تواصل معنا',
            style: TextStyle(fontSize: SizeConfig.ts(24), fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizeConfig.v(12),
          Text(
            'لديك سؤال أو تحتاج مساعدة؟ أرسل لنا رسالة وسنرد عليك في أقرب وقت.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: SizeConfig.ts(15), color: Colors.white.withValues(alpha: 0.95), height: 1.5),
          ),
        ],
      ),
    );
  }
}