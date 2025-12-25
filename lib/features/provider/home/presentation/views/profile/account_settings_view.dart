import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';

class ProviderAccountSettingsView extends ConsumerStatefulWidget {
  const ProviderAccountSettingsView({super.key});

  @override
  ConsumerState<ProviderAccountSettingsView> createState() =>
      _ProviderAccountSettingsViewState();
}

class _ProviderAccountSettingsViewState
    extends ConsumerState<ProviderAccountSettingsView> {
  bool _newRequests = true;
  bool _bookingUpdates = true;
  bool _payments = true;
  bool _messages = true;
  bool _promotions = true;

  bool _isDeleting = false;

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
                  isLoading: _isDeleting,
                  onTap: _isDeleting ? null : () => _onDeleteAccountTap(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onDeleteAccountTap() async {
    final result = await showDialog<_DeletePayload?>(
      context: context,
      barrierDismissible:   false,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (result == null) return;

    setState(() => _isDeleting = true);

    try {
      // ✅ DELETE /users/profile
      final res = await ApiClient.dio.delete(
        ApiConstants.userProfile, // نفس endpoint اللي أعطاك الباك
        data: {
          "password": result.password,
          "confirmation": result.confirmation,
        },
      );

      final success = res.data?['success'] == true;

      if (!success) {
        final msg = (res.data?['message'] ?? 'فشل حذف الحساب').toString();
        throw Exception(msg);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الحساب بنجاح')),
      );

      // ✅ سجّل خروج (يمسح الجلسة)
      await ref.read(authControllerProvider.notifier).logout();

      if (!mounted) return;
      // عادة الـ redirect تبع GoRouter رح يتعامل، بس هذا ضمان إضافي
      context.go(AppRoutes.login);
    } on DioException catch (e) {
      final msg = _friendlyDeleteError(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  String _friendlyDeleteError(DioException e) {
    final code = e.response?.statusCode;
    final msg = (e.response?.data?['message'] ?? '').toString();

    if (code == 400) {
      // الباك ممكن يرجع رسائل مختلفة، نخليها واضحة
      if (msg.isNotEmpty) return msg;
      return 'بيانات الحذف غير صحيحة. تأكد من كلمة المرور وجملة التأكيد.';
    }
    if (code == 401) return 'غير مصرح. تأكد أنك مسجل دخول.';
    if (code == 403) return 'ليس لديك صلاحية.';
    if (code == 404) return 'المسار غير موجود على السيرفر.';
    if (msg.isNotEmpty) return msg;

    return 'حدث خطأ بالشبكة، حاول مرة أخرى.';
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
          activeThumbColor: Colors.white,
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
  final VoidCallback? onTap;
  final bool isLoading;

  const _DeleteAccountButton({
    required this.onTap,
    required this.isLoading,
  });

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
        icon: isLoading
            ? SizedBox(
                width: SizeConfig.ts(18),
                height: SizeConfig.ts(18),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: SizeConfig.ts(20),
              ),
        label: Text(
          isLoading ? 'جاري حذف الحساب...' : 'حذف الحساب',
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

// ==================== Delete Dialog ====================

class _DeletePayload {
  final String password;
  final String confirmation;

  const _DeletePayload({
    required this.password,
    required this.confirmation,
  });
}


class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  // ✅ المستخدم يكتبها بالعربي
  static const uiPhraseAr = 'حذف حسابي';

  // ✅ اللي الباك بده ياه (ثابت)
  static const apiPhraseEn = 'DELETE MY ACCOUNT';

  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  bool get _canSubmit {
    return _passCtrl.text.trim().isNotEmpty &&
        _confirmCtrl.text.trim() == uiPhraseAr;
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // ✅ حل overflow: حدّ أعلى للارتفاع + scroll
          final maxH = MediaQuery.of(context).size.height * 0.80;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: maxH,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // ===== Card Body =====
                Padding(
                  padding: EdgeInsets.only(top: SizeConfig.h(44)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
                    child: Material(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        padding: SizeConfig.padding(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizeConfig.v(22),

                            Text(
                              'هل أنت متأكد أنك تريد حذف الحساب؟',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body16.copyWith(
                                fontSize: SizeConfig.ts(15.5),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizeConfig.v(8),

                            Text(
                              'هذا الإجراء نهائي ولا يمكن التراجع عنه.\nسيتم حذف جميع بياناتك.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(12.8),
                                color: AppColors.textSecondary,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizeConfig.v(14),

                            // Password
                            TextField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    SizeConfig.radius(12),
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                            ),

                            SizeConfig.v(12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                uiPhraseAr, // ✅ صارت بالعربي
                                style: AppTextStyles.body14.copyWith(
                                  fontSize: SizeConfig.ts(12.8),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                            SizeConfig.v(6),

                            TextField(
                              controller: _confirmCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'اكتب جملة التأكيد',
                                hintText: uiPhraseAr, // ✅ بالعربي
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    SizeConfig.radius(12),
                                  ),
                                ),
                              ),
                            ),

                            SizeConfig.v(16),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.redAccent
                                            .withValues(alpha: 0.55),
                                      ),
                                      padding: SizeConfig.padding(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          SizeConfig.radius(12),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'إلغاء',
                                      style: AppTextStyles.body14.copyWith(
                                        fontSize: SizeConfig.ts(13.5),
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                SizeConfig.hSpace(10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: !_canSubmit
                                        ? null
                                        : () {
                                            Navigator.pop(
                                              context,
                                              _DeletePayload(
                                                password: _passCtrl.text.trim(),
                                                // ✅ نبعت للباك النص الإنجليزي الثابت
                                                confirmation: apiPhraseEn,
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: SizeConfig.padding(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          SizeConfig.radius(12),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'حذف الحساب',
                                      style: AppTextStyles.body14.copyWith(
                                        fontSize: SizeConfig.ts(13.5),
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizeConfig.v(4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ===== Top Circle Icon (like screenshot) =====
                Container(
                  width: SizeConfig.w(88),
                  height: SizeConfig.w(88),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    size: SizeConfig.ts(44),
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
