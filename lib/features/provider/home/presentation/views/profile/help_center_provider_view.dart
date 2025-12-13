import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/help_center_message_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class HelpCenterProviderView extends StatefulWidget {
  const HelpCenterProviderView({super.key});

  static const String logoPath = 'assets/images/Baitak white.svg';

  @override
  State<HelpCenterProviderView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterProviderView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _message;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _message = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: SizeConfig.padding(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: BorderSide(
          color: AppColors.borderLight.withValues(alpha: 0.7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      labelStyle: AppTextStyles.label12.copyWith(
        fontSize: SizeConfig.ts(12.5),
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: AppTextStyles.label12.copyWith(
        fontSize: SizeConfig.ts(12.5),
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
      ),
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'المساعدة والدعم',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _TopHeader(),
                Padding(
                  padding: SizeConfig.padding(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle(
                        title: 'ابقَ على تواصل',
                        subtitle:
                            'تفضل بالتواصل معنا مباشرة لأي مشكلة قد تواجهك — نحن هنا لمساعدتك.',
                      ),
                      SizeConfig.v(12),
                      const _ContactCard(
                        icon: Icons.call,
                        title: 'هاتف',
                        value: '+962 1 234 5678',
                        note: 'متاح على مدار الساعة',
                      ),
                      SizeConfig.v(10),
                      const _ContactCard(
                        icon: Icons.mail_outline,
                        title: 'بريد إلكتروني',
                        value: 'support@baitak.io',
                        note: 'سنجيب خلال 24 ساعة',
                      ),
                      SizeConfig.v(10),
                      const _ContactCard(
                        icon: Icons.location_on_outlined,
                        title: 'عنوان المكتب',
                        value: 'شارع 123',
                        note: 'عمان، الأردن',
                      ),
                      SizeConfig.v(10),
                      const _ContactCard(
                        icon: Icons.access_time,
                        title: 'أوقات العمل',
                        value: 'الأحد - الخميس 9 ص - 8 م',
                        note: 'خارج أيام العطلة الرسمية والسبت',
                      ),
                      SizeConfig.v(16),
                      const _SectionTitle(
                        title: 'أرسل لنا رسالة',
                        subtitle: 'املأ النموذج وسنقوم بالرد عليك خلال 24 ساعة.',
                      ),
                      SizeConfig.v(12),
                      const HelpCenterMessageSection(),
                      SizeConfig.v(14),
                      _FooterSocialRow(onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('قريبًا')),
                        );
                      }),
                      SizeConfig.v(18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال رسالتك ✅ سنقوم بالرد قريبًا')),
    );

    _name.clear();
    _email.clear();
    _phone.clear();
    _message.clear();
  }
}

class _TopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: SizeConfig.w(16),
        right: SizeConfig.w(16),
        top: SizeConfig.h(14),
        bottom: SizeConfig.h(18),
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.85),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(SizeConfig.radius(18)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'تواصل معنا',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizeConfig.v(6),
          Text(
            'هل لديك أسئلة أو تحتاج إلى مساعدة؟ أخبرنا، سنكون سعداء بمساعدتك.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.5),
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizeConfig.v(10),
          SvgPicture.asset(
            HelpCenterProviderView.logoPath,
            width: SizeConfig.h(35),
            height: SizeConfig.h(35),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body16.copyWith(
            fontSize: SizeConfig.ts(15.5),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(6),
        Text(
          subtitle,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(12.5),
            color: AppColors.textSecondary,
            height: 1.35,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String note;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: SizeConfig.w(34),
            height: SizeConfig.w(34),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: SizeConfig.ts(18)),
          ),
          SizeConfig.v(10),
          Text(
            title,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13.5),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.5),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeConfig.v(6),
          Text(
            note,
            style: AppTextStyles.label12.copyWith(
              fontSize: SizeConfig.ts(11.5),
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSocialRow extends StatelessWidget {
  final VoidCallback onTap;

  const _FooterSocialRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'ابقَ على تواصل عبر وسائل التواصل الاجتماعي',
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(12.5),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizeConfig.v(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIcon(icon: Icons.public, onTap: onTap),
            SizeConfig.hSpace(12),
            _SocialIcon(icon: Icons.facebook, onTap: onTap),
            SizeConfig.hSpace(12),
            _SocialIcon(icon: Icons.camera_alt_outlined, onTap: onTap),
          ],
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: SizeConfig.w(40),
        height: SizeConfig.w(40),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.7),
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: SizeConfig.ts(20),
        ),
      ),
    );
  }
}
