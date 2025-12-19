import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
import 'package:go_router/go_router.dart';
import 'viewmodels/service_details_providers.dart';

import 'widgets_service_details/service_details_header_card.dart';
import 'widgets_service_details/service_booking_form_sheet.dart';
import 'widgets_service_details/provider_info_card.dart';

class ServiceDetailsView extends ConsumerStatefulWidget {
  const ServiceDetailsView({
    super.key,
    required this.serviceId,
    this.lockedCityId,
    this.openBookingOnLoad = false,
  });

  final int serviceId;
  final int? lockedCityId;

  /// إذا true: أول ما تتحمل التفاصيل يفتح فورم الحجز BottomSheet
  final bool openBookingOnLoad;

  @override
  ConsumerState<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends ConsumerState<ServiceDetailsView> {
  bool _bookingOpenedOnce = false;

  void _openBooking(BuildContext context, ServiceDetailsArgs args) {
    ServiceBookingFormSheet.show(
      context: context,
      args: args,
      isCityLocked: widget.lockedCityId != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final args = ServiceDetailsArgs(
      serviceId: widget.serviceId,
      lockedCityId: widget.lockedCityId,
    );

    final st = ref.watch(serviceDetailsControllerProvider(args));
    final ctrl = ref.read(serviceDetailsControllerProvider(args).notifier);

    // auto-open booking form if requested
    if (widget.openBookingOnLoad &&
        !_bookingOpenedOnce &&
        !st.loading &&
        st.error == null &&
        st.service != null) {
      _bookingOpenedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openBooking(context, args);
      });
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const _GreenDetailsAppBar(title: 'تفاصيل الخدمة'),
        body: st.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.lightGreen),
              )
            : (st.error != null)
                ? _ErrorState(
                    message: st.error!,
                    onRetry: () => ctrl.loadAll(),
                  )
                : _DetailsContent(
                    state: st,
                    args: args,
                    isCityLocked: widget.lockedCityId != null,
                    onBookNow: () => _openBooking(context, args),
                  ),
      ),
    );
  }
}

class _GreenDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GreenDetailsAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: top),
      decoration: const BoxDecoration(color: AppColors.lightGreen),
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            const SizedBox(width: 12),

            // Title centered
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: AppTextStyles.screenTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: SizeConfig.ts(18),
                  ),
                ),
              ),
            ),

            // back button (right) in RTL
            Container(
              
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.state,
    required this.args,
    required this.isCityLocked,
    required this.onBookNow,
  });

  final dynamic state; // keeps compatibility with your existing state file
  final ServiceDetailsArgs args;
  final bool isCityLocked;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    final s = state.service as ServiceDetails;
    final p = s.provider;

    final displayedPrice = _calcDisplayedPrice(state);

    // ما عندك category name بالموديل (فقط categoryId) — مؤقتاً ثابت
    final categoryLabel = 'خدمات المنزل';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          ServiceDetailsHeaderCard(
            serviceName: s.name,
            categoryLabel: categoryLabel,
            durationLabel: _durationLabel(s.durationHours),
            rating: p.ratingAvg,
            priceValueLabel: '${displayedPrice.toStringAsFixed(0)} JD',
            priceHintLabel: 'حسب حجم المنزل',
            bookingLoading: state.bookingLoading == true,
            onBookNow: onBookNow,
          ),
          const SizedBox(height: 12),

          _ServiceSectionCard(
            title: 'وصف الخدمة',
            child: Text(
              s.description.trim().isEmpty ? '—' : s.description.trim(),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: SizeConfig.ts(12.8),
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ProviderInfoCard(
            providerName: p.displayName,
            memberSinceYear: p.memberSinceLabel,
            ratingAvg: p.ratingAvg,
            ratingCount: p.ratingCount,
            bio: p.bio,
            onTapReviews: () {
              final providerId = p.id;
              final providerName = p.displayName;

              context.push(
                '${AppRoutes.providerRatings}'
                '?provider_id=$providerId'
                '&name=${Uri.encodeComponent(providerName)}',
              );
            },
          ),
          const SizedBox(height: 12),

          // (اختياري) عرض الباقات
          if (s.packages.isNotEmpty) ...[
            _SectionTitle(title: 'الباقات'),
            const SizedBox(height: 8),
            ...s.packages.map(
              (pkg) => _InfoTile(
                title: pkg.name,
                subtitle: pkg.description,
                trailing: '${pkg.price.toStringAsFixed(0)} JD',
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (s.addOns.isNotEmpty) ...[
            _SectionTitle(title: 'إضافات'),
            const SizedBox(height: 8),
            ...s.addOns.map(
              (a) => _InfoTile(
                title: a.name,
                subtitle: a.description,
                trailing: '${a.price.toStringAsFixed(0)} JD',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _durationLabel(double hrs) {
    if (hrs <= 0) return '—';
    if (hrs < 1) return 'أقل من ساعة';

    final isInt = (hrs - hrs.floorToDouble()).abs() < 0.0001;
    if (isInt) {
      final h = hrs.toInt();
      return h == 1 ? 'ساعة' : '$h ساعات';
    }

    final a = hrs.floor();
    final b = hrs.ceil();
    return '$a-$b ساعات';
  }

  double _calcDisplayedPrice(dynamic st) {
    final s = st.service as ServiceDetails?;
    if (s == null) return 0;

    double price = s.basePrice;
    final String? selectedName = st.selectedPackageName;

    if (selectedName != null) {
      final pkg =
          s.packages.where((p) => p.name.trim() == selectedName.trim()).toList();
      if (pkg.isNotEmpty) price = pkg.first.price;
    }

    final isHourly = (s.priceType.toLowerCase().trim() == 'hourly');
    if (isHourly) {
      final hrs = s.durationHours <= 0 ? 1.0 : s.durationHours;
      price *= hrs;
    }
    return price;
  }
}

class _ServiceSectionCard extends StatelessWidget {
  const _ServiceSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.ts(14.5),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(10)),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: AppTextStyles.semiBold.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: SizeConfig.ts(15),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.semiBold.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: SizeConfig.ts(14),
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: SizeConfig.ts(13),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: AppTextStyles.semiBold.copyWith(
              color: AppColors.lightGreen,
              fontWeight: FontWeight.w900,
              fontSize: SizeConfig.ts(13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.semiBold.copyWith(
                color: AppColors.textSecondary,
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.semiBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
