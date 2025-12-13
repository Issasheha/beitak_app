import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
import 'viewmodels/service_details_providers.dart';

import 'widgets_service_details/location_models.dart';
import 'widgets_service_details/service_details_header_card.dart';
import 'widgets_service_details/booking_details_card.dart';
import 'widgets_service_details/guest_booking_sheet.dart';
import 'widgets_service_details/package_selector_tile.dart';
import 'widgets_service_details/package_selector_sheet.dart';

class ServiceDetailsView extends ConsumerStatefulWidget {
  const ServiceDetailsView({
    super.key,
    required this.serviceId,
    this.lockedCityId,
  });

  final int serviceId;
  final int? lockedCityId;

  @override
  ConsumerState<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends ConsumerState<ServiceDetailsView> {
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تفاصيل الخدمة',
            style: AppTextStyles.screenTitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: SizeConfig.ts(18),
            ),
          ),
        ),
        body: st.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.lightGreen),
              )
            : (st.error != null)
                ? _ErrorState(
                    message: st.error!,
                    onRetry: () => ctrl.loadAll(),
                  )
                : _Content(
                    state: st,
                    isCityLocked: widget.lockedCityId != null,
                    onPickDate: () => _pickDate(context, ctrl, st.selectedDate),
                    notesCtrl: _notesCtrl,
                    onOpenPackagePicker: () =>
                        _openPackagePicker(context, ctrl, st.service),
                    onAreaChanged: (a) => ctrl.setSelectedArea(a),
                  ),
        bottomNavigationBar: st.service == null
            ? null
            : SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: st.bookingLoading
                          ? null
                          : () => _bookNow(context, ctrl, st),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        st.bookingLoading ? 'جارٍ الحجز...' : 'احجز الآن',
                        style: AppTextStyles.semiBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    dynamic ctrl,
    DateTime? current,
  ) async {
    final first = _todayDateOnly();
    final last = first.add(const Duration(days: 60));
    final initial = current ?? first.add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.lightGreen,
              primary: AppColors.lightGreen,
            ),
          ),
          child: Directionality(textDirection: TextDirection.rtl, child: child!),
        );
      },
    );

    if (picked == null) return;
    ctrl.setSelectedDate(DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _openPackagePicker(
    BuildContext context,
    dynamic ctrl,
    ServiceDetails? s,
  ) async {
    if (s == null) return;
    if (s.packages.isEmpty) return;

    final picked = await PackageSelectorSheet.show(
      context,
      packages: s.packages,
      selectedName: ctrl.state.selectedPackageName,
    );

    ctrl.setSelectedPackageName(picked);
  }

  Future<void> _bookNow(BuildContext context, dynamic ctrl, dynamic st) async {
    final s = st.service as ServiceDetails?;
    if (s == null) return;

    if (st.selectedDate == null) {
      _toast(context, 'اختر تاريخ الحجز.');
      return;
    }

    final CityOption? city = st.selectedCity;
    final AreaOption? area = st.selectedArea;

    final citySlug =
        (city?.slug ?? '').trim().isEmpty ? 'amman' : city!.slug.toLowerCase();
    final areaSlug =
        (area?.slug ?? '').trim().isEmpty ? 'abdoun' : area!.slug.toLowerCase();

    final bookingDate = _fmtDate(st.selectedDate!);
    final bookingTime = s.provider.workingHours.start;
    final durationHours = s.durationHours <= 0 ? 1.0 : s.durationHours;

    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    try {
      await ctrl.createBookingAsUser(
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        durationHours: durationHours,
        serviceCity: citySlug,
        serviceArea: areaSlug,
        notes: notes,
      );

      _toast(context, 'تم إنشاء الحجز بنجاح ✅');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (ctrl.isOtpRequiredError(e)) {
        await _openGuestOtpFlow(
          context: context,
          ctrl: ctrl,
          service: s,
          bookingDate: bookingDate,
          bookingTime: bookingTime,
          durationHours: durationHours,
          serviceCity: citySlug,
          serviceArea: areaSlug,
          notes: notes,
        );
        return;
      }
      _toast(context, 'فشل الحجز: ${e.toString()}');
    }
  }

  Future<void> _openGuestOtpFlow({
    required BuildContext context,
    required dynamic ctrl,
    required ServiceDetails service,
    required String bookingDate,
    required String bookingTime,
    required double durationHours,
    required String serviceCity,
    required String serviceArea,
    required String? notes,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GuestBookingSheet(
        onSendOtp: (phone) => ctrl.sendBookingOtp(customerPhone: phone),
        onConfirm: ({
          required String name,
          required String phone,
          required String otp,
        }) async {
          await ctrl.createBookingAsGuest(
            bookingDate: bookingDate,
            bookingTime: bookingTime,
            durationHours: durationHours,
            serviceCity: serviceCity,
            serviceArea: serviceArea,
            customerName: name,
            customerPhone: phone,
            otp: otp,
            notes: notes,
          );

          _toast(context, 'تم إنشاء الحجز كضيف ✅');
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.isCityLocked,
    required this.onPickDate,
    required this.notesCtrl,
    required this.onOpenPackagePicker,
    required this.onAreaChanged,
  });

  final dynamic state;
  final bool isCityLocked;

  final VoidCallback onPickDate;
  final TextEditingController notesCtrl;
  final VoidCallback onOpenPackagePicker;
  final ValueChanged<AreaOption?> onAreaChanged;

  @override
  Widget build(BuildContext context) {
    final s = state.service as ServiceDetails;
    final p = s.provider;

    final cityDisplay = state.locLoading
        ? '...'
        : ((state.selectedCity?.nameAr ?? '').trim().isNotEmpty
            ? state.selectedCity!.nameAr
            : '—');

    final selectedDateLabel =
        state.selectedDate == null ? 'غير محدد' : _fmtDate(state.selectedDate!);

    final displayedPrice = _calcDisplayedPrice(state);
    final selectedPackageLabel = state.selectedPackageName == null
        ? 'بدون باقة'
        : state.selectedPackageName!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          ServiceDetailsHeaderCard(
            serviceName: s.name,
            description: s.description,
            providerName: p.displayName,
            rating: p.ratingAvg,
            priceLabel: '${displayedPrice.toStringAsFixed(0)} د.أ',
            locationLabelAr:
                (p.serviceAreas.isNotEmpty) ? p.serviceAreas.first : '—',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: BookingDetailsCard(
                loading: state.locLoading,
                selectedDateLabel: selectedDateLabel,
                onPickDate: onPickDate,
                notesCtrl: notesCtrl,
                cityNameAr: cityDisplay,
                isCityLocked: isCityLocked,
                areas: state.areas as List<AreaOption>,
                selectedArea: state.selectedArea as AreaOption?,
                onAreaChanged: onAreaChanged,
                areaEnabled:
                    (state.areas as List).isNotEmpty && !state.locLoading,
              ),
            ),
          ),
          const SizedBox(height: 12),
          PackageSelectorTile(
            hasPackages: s.packages.isNotEmpty,
            selectedLabel: selectedPackageLabel,
            onTap: s.packages.isEmpty ? null : onOpenPackagePicker,
          ),
        ],
      ),
    );
  }

  double _calcDisplayedPrice(dynamic st) {
    final s = st.service as ServiceDetails?;
    if (s == null) return 0;

    double price = s.basePrice;
    final String? selectedName = st.selectedPackageName;
    if (selectedName != null) {
      final pkg = s.packages
          .where((p) => p.name.trim() == selectedName.trim())
          .toList();
      if (pkg.isNotEmpty) price = pkg.first.price;
    }

    final isHourly = (s.priceType.toLowerCase().trim() == 'hourly');
    if (isHourly) {
      final hrs = s.durationHours <= 0 ? 1.0 : s.durationHours;
      price *= hrs;
    }
    return price;
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
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
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textSecondary),
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
                    borderRadius: BorderRadius.circular(16)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.semiBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
