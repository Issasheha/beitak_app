import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
import '../viewmodels/service_details_providers.dart';

import 'location_models.dart';
import 'booking_details_card.dart';
import 'guest_booking_sheet.dart';
import 'package_selector_tile.dart';
import 'package_selector_sheet.dart';

import 'service_booking_form_helpers.dart';
import 'service_booking_form_ui.dart';
import 'service_booking_date_picker_sheet.dart';
import 'service_booking_time_picker_sheet.dart';

class ServiceBookingFormSheet extends ConsumerStatefulWidget {
  const ServiceBookingFormSheet({
    super.key,
    required this.args,
    required this.isCityLocked,
  });

  final ServiceDetailsArgs args;
  final bool isCityLocked;

  static Future<void> show({
    required BuildContext context,
    required ServiceDetailsArgs args,
    required bool isCityLocked,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceBookingFormSheet(
        args: args,
        isCityLocked: isCityLocked,
      ),
    );
  }

  @override
  ConsumerState<ServiceBookingFormSheet> createState() =>
      _ServiceBookingFormSheetState();
}

class _ServiceBookingFormSheetState extends ConsumerState<ServiceBookingFormSheet> {
  final TextEditingController _notesCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String? _selectedTime; // HH:mm (قيمة API)

  String? _inlineMsg;
  InlineMsgType _inlineMsgType = InlineMsgType.info;

  @override
  void dispose() {
    _notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showInline(
    String msg, {
    InlineMsgType type = InlineMsgType.error,
  }) {
    if (!mounted) return;

    setState(() {
      _inlineMsg = msg.trim();
      _inlineMsgType = type;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearInline() {
    if (!mounted) return;
    setState(() => _inlineMsg = null);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final st = ref.watch(serviceDetailsControllerProvider(widget.args));
    final ctrl = ref.read(serviceDetailsControllerProvider(widget.args).notifier);

    final s = st.service;
    if (st.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.lightGreen),
      );
    }
    if (st.error != null || s == null) {
      return SheetError(
        message: st.error ?? 'حدث خطأ غير متوقع',
        onRetry: () => ctrl.loadAll(),
      );
    }

    if (st.bookingError != null &&
        st.bookingError!.trim().isNotEmpty &&
        _inlineMsg != st.bookingError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInline(st.bookingError!, type: InlineMsgType.error);
      });
    }

    final cityDisplay = st.locLoading
        ? '...'
        : ((st.selectedCity?.nameAr ?? '').trim().isNotEmpty
            ? st.selectedCity!.nameAr
            : '—');

    final selectedDateLabel = st.selectedDate == null ? '' : fmtDate(st.selectedDate!);
    final selectedTimeLabel = (_selectedTime ?? '').trim();

    final selectedPackageLabel =
        st.selectedPackageName == null ? 'بدون باقة' : st.selectedPackageName!;

    final durationHours = s.durationHours <= 0 ? 1.0 : s.durationHours;

    bool availabilityLoading = false;
    try {
      final dyn = st as dynamic;
      availabilityLoading = dyn.availabilityLoading == true;
    } catch (_) {}

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          margin: EdgeInsets.only(top: SizeConfig.h(70)),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: SizeConfig.h(10)),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(height: SizeConfig.h(12)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'معلومات الحجز',
                        style: AppTextStyles.screenTitle.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: SizeConfig.ts(16),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 14,
                  ),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: (_inlineMsg == null || _inlineMsg!.trim().isEmpty)
                            ? const SizedBox.shrink()
                            : InlineBanner(
                                key: const ValueKey('inline_banner'),
                                message: _inlineMsg!,
                                type: _inlineMsgType,
                                onClose: _clearInline,
                              ),
                      ),
                      if (availabilityLoading) ...[
                        const SizedBox(height: 10),
                        const InlineBanner(
                          message: 'جارٍ تحميل الأيام المتاحة…',
                          type: InlineMsgType.info,
                          onClose: null,
                        ),
                      ],
                      if (_inlineMsg != null || availabilityLoading) const SizedBox(height: 10),

                      BookingDetailsCard(
                        loading: st.locLoading,
                        selectedDateLabel: selectedDateLabel,
                        onPickDate: () async {
                          _clearInline();
                          await _pickDate(
                            context,
                            ctrl: ctrl,
                            state: st,
                            service: s,
                            current: st.selectedDate,
                          );
                        },
                        selectedTimeLabel: selectedTimeLabel,
                        onPickTime: () async {
                          _clearInline();
                          await _pickTime(
                            context,
                            provider: s.provider,
                            selectedDate: st.selectedDate,
                            durationHours: durationHours,
                            minAdvanceBookingHours: kMinAdvanceBookingHours, // ✅ 12 ساعة ثابت
                          );
                        },
                        cityNameAr: cityDisplay,
                        isCityLocked: widget.isCityLocked,
                        areas: st.areas,
                        selectedArea: st.selectedArea,
                        onAreaChanged: (a) {
                          _clearInline();
                          ctrl.setSelectedArea(a);
                        },
                        areaEnabled: st.areas.isNotEmpty && !st.locLoading,
                        notesCtrl: _notesCtrl,
                      ),

                      const SizedBox(height: 12),
                      PackageSelectorTile(
                        hasPackages: s.packages.isNotEmpty,
                        selectedLabel: selectedPackageLabel,
                        onTap: s.packages.isEmpty
                            ? null
                            : () async {
                                _clearInline();
                                await _openPackagePicker(context, ctrl, s);
                              },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    top: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: SizeConfig.h(44),
                  child: ElevatedButton(
                    onPressed: st.bookingLoading ? null : () => _bookNow(context, ctrl, st),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      st.bookingLoading ? 'جارٍ الحجز...' : 'تأكيد الحجز',
                      style: AppTextStyles.semiBold.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required dynamic ctrl,
    required dynamic state,
    required ServiceDetails service,
    required DateTime? current,
  }) async {
    final now = DateTime.now();

    const minAdvance = kMinAdvanceBookingHours;
    final earliestAllowed = now.add(const Duration(hours: minAdvance));

    DateTime first = DateTime(earliestAllowed.year, earliestAllowed.month, earliestAllowed.day);

    final today = todayDateOnly();
    if (first.isBefore(today)) first = today;

    final maxDays = service.maxAdvanceBookingDays <= 0 ? 60 : service.maxAdvanceBookingDays;
    final last = first.add(Duration(days: maxDays));

    final availableSet = safeAvailableDateSet(state);

    bool selectable(DateTime d) {
      final dateOnly = DateTime(d.year, d.month, d.day);

      if (dateOnly.isBefore(first) || dateOnly.isAfter(last)) return false;

      final dateStr = fmtDate(dateOnly);
      if (availableSet.isNotEmpty && !availableSet.contains(dateStr)) return false;

      return hasAnySlotForDay(
        service: service,
        dateOnly: dateOnly,
        minAdvanceHours: minAdvance,
      );
    }

    String? disabledReason(DateTime d) {
      final dateOnly = DateTime(d.year, d.month, d.day);

      if (dateOnly.isBefore(first)) {
        if (minAdvance > 0 && isSameDay(dateOnly, today)) {
          return 'اليوم غير متاح لأن الحجز يجب أن يكون قبل $minAdvance ساعة على الأقل.';
        }
        return 'هذا اليوم غير متاح حسب سياسة الحجز المسبق ($minAdvance ساعة).';
      }

      if (dateOnly.isAfter(last)) return 'هذا اليوم خارج المدة المتاحة للحجز.';

      final dateStr = fmtDate(dateOnly);
      if (availableSet.isNotEmpty && !availableSet.contains(dateStr)) {
        return 'هذا اليوم غير متاح حسب توفر مزود الخدمة.';
      }

      if (!hasAnySlotForDay(
        service: service,
        dateOnly: dateOnly,
        minAdvanceHours: minAdvance,
      )) {
        if (minAdvance > 0 && isSameDay(dateOnly, today)) {
          return 'لا يمكن الحجز اليوم لأن الحجز يجب أن يكون قبل $minAdvance ساعة على الأقل.';
        }
        return 'لا توجد أوقات متاحة في هذا اليوم ضمن ساعات العمل.';
      }

      return null;
    }

    DateTime initial = (current != null && selectable(current)) ? current : first;

    if (!selectable(initial)) {
      DateTime? found;
      DateTime cur = first;
      while (!cur.isAfter(last)) {
        if (selectable(cur)) {
          found = cur;
          break;
        }
        cur = cur.add(const Duration(days: 1));
      }
      if (found == null) {
        _showInline('لا توجد أيام متاحة للحجز ضمن الفترة المحددة.', type: InlineMsgType.error);
        return;
      }
      initial = found;
    }

    final picked = await DatePickerSheet.show(
      context,
      initial: initial,
      first: first,
      last: last,
      isSelectable: selectable,
      disabledReason: disabledReason,
    );

    if (picked == null) return;

    ctrl.setSelectedDate(DateTime(picked.year, picked.month, picked.day));
    if (mounted) setState(() => _selectedTime = null);
  }

  Future<void> _pickTime(
    BuildContext context, {
    required ProviderDetails provider,
    required DateTime? selectedDate,
    required double durationHours,
    required int minAdvanceBookingHours,
  }) async {
    if (selectedDate == null) {
      _showInline('اختَر تاريخ الحجز أولاً ثم اختر الوقت.', type: InlineMsgType.info);
      return;
    }

    final dayKey = weekdayKey(selectedDate);
    final day = provider.dayHours(dayKey);

    if (day != null && day.active == false) {
      _showInline('هذا اليوم غير متاح للحجز عند مزود الخدمة.', type: InlineMsgType.error);
      return;
    }

    final start = (day?.start ?? provider.workingHours.start);
    final end = (day?.end ?? provider.workingHours.end);

    final durationMinutes = (durationHours * 60).round();
    const stepMinutes = 30;

    final now = DateTime.now();
    final earliestAllowed = now.add(Duration(hours: minAdvanceBookingHours));

    final earliestDateOnly = DateTime(earliestAllowed.year, earliestAllowed.month, earliestAllowed.day);
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (selectedDateOnly.isBefore(earliestDateOnly)) {
      _showInline(
        'هذا التاريخ قريب جداً ولا يسمح بالحجز لأن الحجز يجب أن يكون قبل $minAdvanceBookingHours ساعة على الأقل.',
        type: InlineMsgType.error,
      );
      return;
    }

    int? minStartMinutes;
    if (isSameDay(selectedDateOnly, earliestDateOnly)) {
      minStartMinutes = roundUpToStep(minutesOfDay(earliestAllowed), stepMinutes);
    }

    final slots = buildTimeSlots(
      start,
      end,
      durationMinutes: durationMinutes,
      stepMinutes: stepMinutes,
      minStartMinutes: minStartMinutes,
    );

    if (slots.isEmpty) {
      if (isSameDay(selectedDateOnly, todayDateOnly()) && minAdvanceBookingHours > 0) {
        _showInline(
          'لا يمكن الحجز اليوم لأن الحجز يجب أن يكون قبل $minAdvanceBookingHours ساعة على الأقل.',
          type: InlineMsgType.info,
        );
      } else {
        _showInline('لا توجد أوقات متاحة لهذا اليوم ضمن ساعات العمل.', type: InlineMsgType.error);
      }
      return;
    }

    final picked = await BookingTimePickerSheet.show(
      context,
      slots: slots,
      selectedTime: _selectedTime,
    );

    if (picked == null) return;
    setState(() => _selectedTime = picked);
  }

  Future<void> _openPackagePicker(
    BuildContext context,
    dynamic ctrl,
    ServiceDetails s,
  ) async {
    if (s.packages.isEmpty) return;

    final picked = await PackageSelectorSheet.show(
      context,
      packages: s.packages,
      selectedName: ctrl.state.selectedPackageName,
    );

    ctrl.setSelectedPackageName(picked);
  }

  Future<void> _bookNow(
    BuildContext context,
    dynamic ctrl,
    dynamic st,
  ) async {
    _clearInline();

    final s = st.service as ServiceDetails?;
    if (s == null) return;

    if (st.selectedDate == null) {
      _showInline('رجاءً اختر تاريخ الحجز.', type: InlineMsgType.info);
      return;
    }

    if ((_selectedTime ?? '').trim().isEmpty) {
      _showInline('رجاءً اختر وقت الحجز.', type: InlineMsgType.info);
      return;
    }

    final CityOption? city = st.selectedCity;
    final AreaOption? area = st.selectedArea;

    final citySlug = (city?.slug ?? '').trim().isEmpty ? 'amman' : city!.slug.toLowerCase();
    final areaSlug = (area?.slug ?? '').trim().isEmpty ? 'abdoun' : area!.slug.toLowerCase();

    final bookingDate = fmtDate(st.selectedDate!);
    final bookingTime = toTimeWithSeconds(_selectedTime!.trim());

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

      _showInline('تم إنشاء الحجز بنجاح ✅', type: InlineMsgType.success);
      await Future.delayed(const Duration(milliseconds: 750));
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (ctrl.isOtpRequiredError(e)) {
        final parentContext = context;

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetCtx) => GuestBookingSheet(
            onSendOtp: (phone) => ctrl.sendBookingOtp(customerPhone: phone),
            onConfirm: ({
              required String name,
              required String phone,
              required String otp,
            }) async {
              final sheetNav = Navigator.of(sheetCtx);
              final parentNav = Navigator.of(parentContext);

              try {
                await ctrl.createBookingAsGuest(
                  bookingDate: bookingDate,
                  bookingTime: bookingTime,
                  durationHours: durationHours,
                  serviceCity: citySlug,
                  serviceArea: areaSlug,
                  customerName: name,
                  customerPhone: phone,
                  otp: otp,
                  notes: notes,
                );

                if (sheetNav.canPop()) sheetNav.pop();

                if (!mounted) return;
                _showInline('تم إنشاء الحجز كضيف ✅', type: InlineMsgType.success);

                await Future.delayed(const Duration(milliseconds: 750));
                if (!parentContext.mounted) return;
                parentNav.pop(true);
              } catch (e2) {
                if (!mounted) return;
                _showInline('فشل تأكيد الحجز: ${e2.toString()}', type: InlineMsgType.error);
              }
            },
          ),
        );
        return;
      }

      _showInline('تعذر إنشاء الحجز: ${e.toString()}', type: InlineMsgType.error);
    }
  }
}
