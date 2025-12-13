import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderAccountSettingsView extends StatefulWidget {
  const ProviderAccountSettingsView({super.key});

  @override
  State<ProviderAccountSettingsView> createState() =>
      _ProviderAccountSettingsViewState();
}

class _ProviderAccountSettingsViewState
    extends State<ProviderAccountSettingsView> {
  bool _newRequests = true;
  bool _bookingUpdates = true;
  bool _payments = true;
  bool _messages = true;
  bool _promotions = true;

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
            'إعدادات الحساب',
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
            padding: SizeConfig.padding(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopHeader(),
                SizeConfig.v(14),
                _NotificationsCard(
                  newRequests: _newRequests,
                  bookingUpdates: _bookingUpdates,
                  payments: _payments,
                  messages: _messages,
                  promotions: _promotions,
                  onNewRequestsChanged: (v) => setState(() => _newRequests = v),
                  onBookingUpdatesChanged: (v) =>
                      setState(() => _bookingUpdates = v),
                  onPaymentsChanged: (v) => setState(() => _payments = v),
                  onMessagesChanged: (v) => setState(() => _messages = v),
                  onPromotionsChanged: (v) => setState(() => _promotions = v),
                ),
                SizeConfig.v(12),
                _SettingsNavCard(
                  title: 'إدارة الوثائق',
                  subtitle: 'إدارة الوثائق المرتبطة بحسابك',
                  icon: Icons.description_outlined,
                  onTap: () {
                    context.push(AppRoutes.providerdocumentsView);
                  },
                ),
                SizeConfig.v(10),
                _SettingsNavCard(
                  title: 'تعديل معلومات الحساب',
                  subtitle: 'إدارة التفاصيل المرتبطة بحسابك',
                  icon: Icons.person_outline,
                  onTap: () {
                    context.push(AppRoutes.provideraccountEdit);
                  },
                ),
                SizeConfig.v(24),
                _DeleteAccountButton(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تنبيه: سيتم تنفيذ منطق حذف الحساب لاحقًا'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Header ====================

class _TopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SizeConfig.padding(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
      ),
      child: Column(
        children: [
          Text(
            'إعدادات الحساب الشاملة',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(15),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizeConfig.v(4),
          Text(
            'إدارة جميع إعدادات حسابك في مكان واحد',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.5),
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Notifications Card ====================

class _NotificationsCard extends StatelessWidget {
  final bool newRequests;
  final bool bookingUpdates;
  final bool payments;
  final bool messages;
  final bool promotions;

  final ValueChanged<bool> onNewRequestsChanged;
  final ValueChanged<bool> onBookingUpdatesChanged;
  final ValueChanged<bool> onPaymentsChanged;
  final ValueChanged<bool> onMessagesChanged;
  final ValueChanged<bool> onPromotionsChanged;

  const _NotificationsCard({
    required this.newRequests,
    required this.bookingUpdates,
    required this.payments,
    required this.messages,
    required this.promotions,
    required this.onNewRequestsChanged,
    required this.onBookingUpdatesChanged,
    required this.onPaymentsChanged,
    required this.onMessagesChanged,
    required this.onPromotionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإشعارات',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(14.5),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(10),
          _NotificationRow(
            title: 'طلبات خدمات جديدة',
            subtitle: 'عندما يطلب عميل خدمتك',
            value: newRequests,
            onChanged: onNewRequestsChanged,
          ),
          _divider(),
          _NotificationRow(
            title: 'تحديثات الحجوزات',
            subtitle: 'إلغاءات وتغييرات المواعيد',
            value: bookingUpdates,
            onChanged: onBookingUpdatesChanged,
          ),
          _divider(),
          _NotificationRow(
            title: 'المدفوعات',
            subtitle: 'عند استلام الدفعات',
            value: payments,
            onChanged: onPaymentsChanged,
          ),
          _divider(),
          _NotificationRow(
            title: 'الرسائل',
            subtitle: 'رسائل جديدة من العملاء',
            value: messages,
            onChanged: onMessagesChanged,
          ),
          _divider(),
          _NotificationRow(
            title: 'العروض والترويجات',
            subtitle: 'عروض خاصة وتحديثات',
            value: promotions,
            onChanged: onPromotionsChanged,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(6)),
      child: Divider(
        height: 1,
        color: AppColors.borderLight.withValues(alpha: 0.5),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.5),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(2),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: AppTextStyles.label12.copyWith(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizeConfig.hSpace(8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.lightGreen,
        ),
      ],
    );
  }
}

// ==================== Navigation Cards ====================

class _SettingsNavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsNavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
      onTap: onTap,
      child: Container(
        padding: SizeConfig.padding(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
          border: Border.all(
            color: AppColors.lightGreen.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
              size: SizeConfig.ts(22),
            ),
            SizeConfig.hSpace(8),
            Icon(
              icon,
              color: AppColors.lightGreen,
              size: SizeConfig.ts(20),
            ),
            SizeConfig.hSpace(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(13.5),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.label12.copyWith(
                      fontSize: SizeConfig.ts(12),
                      color: AppColors.textSecondary,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Delete Account Button ====================

class _DeleteAccountButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteAccountButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: SizeConfig.padding(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
            side: const BorderSide(color: Colors.redAccent),
          ),
        ),
        icon: Icon(
          Icons.delete_outline,
          color: Colors.redAccent,
          size: SizeConfig.ts(20),
        ),
        label: Text(
          'حذف الحساب',
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(14.5),
            fontWeight: FontWeight.w800,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
