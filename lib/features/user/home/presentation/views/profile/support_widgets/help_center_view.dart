// lib/features/support/presentation/views/help_center_view.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/support_widgets/contact_card.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/support_widgets/contact_form_card.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/support_widgets/contact_header.dart';
import 'package:flutter/material.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  void _onSendMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('تم إرسال رسالتك! سنرد عليك قريبًا'),
          backgroundColor: AppColors.lightGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('مركز المساعدة',
              style: TextStyle(
                  fontSize: SizeConfig.ts(20), fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => Navigator.pop(context)),
        ),
        body: SingleChildScrollView(
          padding: SizeConfig.padding(horizontal: 20, bottom: 40),
          child: Column(
            children: [
              const ContactHeader(),
              SizeConfig.v(32),
              Text(
                'تواصل معنا مباشرة',
                style: TextStyle(
                    fontSize: SizeConfig.ts(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              SizeConfig.v(20),
              Wrap(
                spacing: SizeConfig.w(16),
                runSpacing: SizeConfig.h(20),
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  const ContactCard(
                    icon: Icons.phone,
                    title: '+962 79 123 4567',
                    subtitle: 'متوفر 24/7',
                    color: AppColors.lightGreen,
                  ),
                  ContactCard(
                    icon: Icons.email_outlined,
                    title: 'support@baitak.jo',
                    subtitle: 'الرد خلال 24 ساعة',
                    color: Colors.blue.shade600,
                  ),
                  ContactCard(
                    icon: Icons.location_on_outlined,
                    title: 'عمان، الأردن',
                    subtitle: 'شارع الرئيسي 123',
                    color: Colors.orange.shade700,
                  ),
                  ContactCard(
                    icon: Icons.access_time,
                    title: 'الأحد - الخميس\n8 ص - 6 م',
                    subtitle: 'الجمعة والسبت مغلق',
                    color: Colors.purple.shade600,
                  ),
                ],
              ),
              SizeConfig.v(40),
              ContactFormCard(onSend: () => _onSendMessage(context)),
            ],
          ),
        ),
      ),
    );
  }
}
