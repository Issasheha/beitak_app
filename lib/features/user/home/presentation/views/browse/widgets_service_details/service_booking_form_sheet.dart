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

enum _InlineMsgType { info, error, success }

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

class _ServiceBookingFormSheetState
    extends ConsumerState<ServiceBookingFormSheet> {
  final TextEditingController _notesCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String? _selectedTime; // HH:mm

  String? _inlineMsg;
  _InlineMsgType _inlineMsgType = _InlineMsgType.info;

  @override
  void dispose() {
    _notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showInline(
    String msg, {
    _InlineMsgType type = _InlineMsgType.error,
  }) {
    if (!mounted) return;

    setState(() {
      _inlineMsg = msg.trim();
      _inlineMsgType = type;
    });

    // خليه يشوف الرسالة فوراً
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
    final ctrl =
        ref.read(serviceDetailsControllerProvider(widget.args).notifier);

    final s = st.service;
    if (st.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.lightGreen),
      );
    }
    if (st.error != null || s == null) {
      return _SheetError(
        message: st.error ?? 'حدث خطأ غير متوقع',
        onRetry: () => ctrl.loadAll(),
      );
    }

    // لو controller حاطط bookingError، خليه يبين فوق الفورم
    if (st.bookingError != null &&
        st.bookingError!.trim().isNotEmpty &&
        _inlineMsg != st.bookingError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInline(st.bookingError!, type: _InlineMsgType.error);
      });
    }

    final cityDisplay = st.locLoading
        ? '...'
        : ((st.selectedCity?.nameAr ?? '').trim().isNotEmpty
            ? st.selectedCity!.nameAr
            : '—');

    final selectedDateLabel =
        st.selectedDate == null ? '' : _fmtDate(st.selectedDate!);
    final selectedTimeLabel = _selectedTime ?? '';

    final selectedPackageLabel =
        st.selectedPackageName == null ? 'بدون باقة' : st.selectedPackageName!;

    final durationHours = s.durationHours <= 0 ? 1.0 : s.durationHours;

    // (اختياري) إذا عندك availabilityLoading بالحالة
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
                      icon: const Icon(Icons.close,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              // المحتوى
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
                        child: (_inlineMsg == null ||
                                _inlineMsg!.trim().isEmpty)
                            ? const SizedBox.shrink()
                            : _InlineBanner(
                                key: const ValueKey('inline_banner'),
                                message: _inlineMsg!,
                                type: _inlineMsgType,
                                onClose: _clearInline,
                              ),
                      ),

                      if (availabilityLoading) ...[
                        const SizedBox(height: 10),
                        const _InlineBanner(
                          message: 'جارٍ تحميل الأيام المتاحة…',
                          type: _InlineMsgType.info,
                          onClose: null,
                        ),
                      ],

                      if (_inlineMsg != null || availabilityLoading)
                        const SizedBox(height: 10),

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
                        areaEnabled:
                            st.areas.isNotEmpty && !st.locLoading,
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

              // زر تأكيد الحجز
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
                    onPressed: st.bookingLoading
                        ? null
                        : () => _bookNow(context, ctrl, st),
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

  // ---------------- اختيار التاريخ ----------------

  Future<void> _pickDate(
    BuildContext context, {
    required dynamic ctrl,
    required dynamic state,
    required ServiceDetails service,
    required DateTime? current,
  }) async {
    final now = DateTime.now();

    // أقل وقت مسموح للحجز حسب إعداد الخدمة
    final earliest = now.add(Duration(hours: service.minAdvanceBookingHours));
    DateTime first = DateTime(earliest.year, earliest.month, earliest.day);

    // لا نسمح بتاريخ قبل اليوم
    final today = _todayDateOnly();
    if (first.isBefore(today)) first = today;

    // آخر تاريخ مسموح للحجز
    final maxDays =
        service.maxAdvanceBookingDays <= 0 ? 60 : service.maxAdvanceBookingDays;
    final last = first.add(Duration(days: maxDays));

    // التواريخ القادمة من السيرفر (إن وُجدت)
    final availableSet = _safeAvailableDateSet(state);

    bool selectable(DateTime d) {
      final dateOnly = DateTime(d.year, d.month, d.day);

      if (dateOnly.isBefore(first) || dateOnly.isAfter(last)) {
        return false;
      }

      final dateStr = _fmtDate(dateOnly); // YYYY-MM-DD

      // لو السيرفر رجع لنا تواريخ جاهزة → نعتمدها
      if (availableSet.isNotEmpty) {
        return availableSet.contains(dateStr);
      }

      // لو ما في أي داتا عن التوفر → نسمح بكل الأيام داخل النطاق
      return true;
    }

    // اختَر initialDate مناسب
    DateTime initial =
        (current != null && selectable(current)) ? current : first;

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
        _showInline(
          'لا توجد أيام متاحة للحجز ضمن الفترة المحددة.',
          type: _InlineMsgType.error,
        );
        return;
      }

      initial = found;
    }

    final picked = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: initial,
      selectableDayPredicate: selectable,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.lightGreen,
              primary: AppColors.lightGreen,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked == null) return;

    ctrl.setSelectedDate(DateTime(picked.year, picked.month, picked.day));
    if (mounted) {
      // تغيير التاريخ → صفّر الوقت
      setState(() => _selectedTime = null);
    }
  }

  // ---------------- اختيار الوقت ----------------

  Future<void> _pickTime(
    BuildContext context, {
    required ProviderDetails provider,
    required DateTime? selectedDate,
    required double durationHours,
  }) async {
    if (selectedDate == null) {
      _showInline(
        'اختَر تاريخ الحجز أولاً ثم اختر الوقت.',
        type: _InlineMsgType.info,
      );
      return;
    }

    final dayKey = _weekdayKey(selectedDate);
    final day = provider.dayHours(dayKey);

    if (day != null && day.active == false) {
      _showInline(
        'هذا اليوم غير متاح للحجز عند مزود الخدمة.',
        type: _InlineMsgType.error,
      );
      return;
    }

    final start = (day?.start ?? provider.workingHours.start);
    final end = (day?.end ?? provider.workingHours.end);

    final durationMinutes = (durationHours * 60).round();
    final slots = _buildTimeSlots(
      start,
      end,
      durationMinutes: durationMinutes,
      stepMinutes: 30,
    );

    if (slots.isEmpty) {
      _showInline(
        'لا توجد أوقات متاحة لهذا اليوم ضمن ساعات العمل.',
        type: _InlineMsgType.error,
      );
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: Container(
              margin: EdgeInsets.only(top: SizeConfig.h(120)),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(22)),
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
                            'وقت الحجز',
                            style: AppTextStyles.screenTitle.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: SizeConfig.ts(15.5),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding:
                          const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      itemCount: slots.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final t = slots[i];
                        final selected = (_selectedTime == t);
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pop(context, t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.lightGreen
                                      .withValues(alpha: 0.10)
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppColors.lightGreen
                                        .withValues(alpha: 0.35)
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: AppColors.lightGreen,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t,
                                    style: AppTextStyles.semiBold
                                        .copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize:
                                          SizeConfig.ts(13.5),
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.lightGreen,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked == null) return;
    setState(() => _selectedTime = picked);
  }

  List<String> _buildTimeSlots(
    String start,
    String end, {
    required int durationMinutes,
    int stepMinutes = 30,
  }) {
    int? parseToMin(String v) {
      final s = v.trim();
      final parts = s.split(':');
      if (parts.length < 2) return null;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) return null;
      if (h < 0 || h > 23 || m < 0 || m > 59) return null;
      return h * 60 + m;
    }

    String fmt(int minutes) {
      final h = (minutes ~/ 60).toString().padLeft(2, '0');
      final m = (minutes % 60).toString().padLeft(2, '0');
      return '$h:$m';
    }

    final a = parseToMin(start);
    final b = parseToMin(end);
    if (a == null || b == null) return const [];
    if (b <= a) return const [];

    final lastStart = b - durationMinutes;
    if (lastStart < a) return const [];

    final out = <String>[];
    for (int t = a; t <= lastStart; t += stepMinutes) {
      out.add(fmt(t));
    }
    return out;
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
      _showInline(
        'رجاءً اختر تاريخ الحجز.',
        type: _InlineMsgType.info,
      );
      return;
    }

    if ((_selectedTime ?? '').trim().isEmpty) {
      _showInline(
        'رجاءً اختر وقت الحجز.',
        type: _InlineMsgType.info,
      );
      return;
    }

    final CityOption? city = st.selectedCity;
    final AreaOption? area = st.selectedArea;

    final citySlug =
        (city?.slug ?? '').trim().isEmpty ? 'amman' : city!.slug.toLowerCase();
    final areaSlug =
        (area?.slug ?? '').trim().isEmpty ? 'abdoun' : area!.slug.toLowerCase();

    final bookingDate = _fmtDate(st.selectedDate!);
    final bookingTime =
        _toTimeWithSeconds(_selectedTime!.trim()); // HH:mm:ss

    final durationHours =
        s.durationHours <= 0 ? 1.0 : s.durationHours;
    final notes =
        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    try {
      await ctrl.createBookingAsUser(
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        durationHours: durationHours,
        serviceCity: citySlug,
        serviceArea: areaSlug,
        notes: notes,
      );

      _showInline(
        'تم إنشاء الحجز بنجاح ✅',
        type: _InlineMsgType.success,
      );
      await Future.delayed(const Duration(milliseconds: 750));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (ctrl.isOtpRequiredError(e)) {
        final parentContext = context;

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetCtx) => GuestBookingSheet(
            onSendOtp: (phone) =>
                ctrl.sendBookingOtp(customerPhone: phone),
            onConfirm: ({
              required String name,
              required String phone,
              required String otp,
            }) async {
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

                if (Navigator.canPop(sheetCtx)) {
                  Navigator.pop(sheetCtx);
                }

                if (mounted) {
                  _showInline(
                    'تم إنشاء الحجز كضيف ✅',
                    type: _InlineMsgType.success,
                  );
                  await Future.delayed(
                      const Duration(milliseconds: 750));
                  if (mounted) {
                    Navigator.pop(parentContext, true);
                  }
                }
              } catch (e2) {
                if (mounted) {
                  _showInline(
                    'فشل تأكيد الحجز: ${e2.toString()}',
                    type: _InlineMsgType.error,
                  );
                }
              }
            },
          ),
        );
        return;
      }

      _showInline(
        'تعذر إنشاء الحجز: ${e.toString()}',
        type: _InlineMsgType.error,
      );
    }
  }

  String _toTimeWithSeconds(String hm) {
    final s = hm.trim();
    final parts = s.split(':');
    if (parts.length == 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
    }
    if (parts.length >= 3) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
    }
    return '09:00:00';
  }

  // ---------------- التواريخ القادمة من السيرفر ----------------

  Set<String> _safeAvailableDateSet(dynamic state) {
    // نطلع تاريخ واحد من أي شكل سترنج
    String? _extractDate(String s) {
      s = s.trim();
      if (s.isEmpty) return null;

      // لو ISO زي 2025-12-21 أو 2025-12-21T...
      final match = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(s);
      if (match != null) {
        return match.group(0);
      }
      return null;
    }

    // نضيف عنصر واحد (string أو map) للمجموعة
    void _addOne(dynamic v, Set<String> out) {
      if (v == null) return;

      if (v is Map) {
        final raw =
            v['date'] ?? v['day_date'] ?? v['booking_date'] ?? v['dayDate'];
        if (raw != null) {
          final s = raw.toString();
          final d = _extractDate(s);
          if (d != null && d.isNotEmpty) out.add(d);
        }
        return;
      }

      // لو سترنج أو أي نوع آخر
      final d = _extractDate(v.toString());
      if (d != null && d.isNotEmpty) out.add(d);
    }

    Set<String> _normalize(dynamic raw) {
      final out = <String>{};
      if (raw is Iterable) {
        for (final v in raw) {
          _addOne(v, out);
        }
      } else {
        _addOne(raw, out);
      }
      return out;
    }

    // نحاول availableDates أولاً
    try {
      final raw = (state as dynamic).availableDates;
      final normalized = _normalize(raw);
      if (normalized.isNotEmpty) return normalized;
    } catch (_) {}

    // fallback: availableDays
    try {
      final raw = (state as dynamic).availableDays;
      final normalized = _normalize(raw);
      if (normalized.isNotEmpty) return normalized;
    } catch (_) {}

    return <String>{};
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

  String _weekdayKey(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'monday';
    }
  }
}

// =================== Widgets مساعدة ===================

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    super.key,
    required this.message,
    required this.type,
    required this.onClose,
  });

  final String message;
  final _InlineMsgType type;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    IconData icon;

    switch (type) {
      case _InlineMsgType.success:
        bg = AppColors.lightGreen.withValues(alpha: 0.10);
        border = AppColors.lightGreen.withValues(alpha: 0.35);
        icon = Icons.check_circle_rounded;
        break;
      case _InlineMsgType.info:
        bg = AppColors.cardBackground;
        border = AppColors.borderLight;
        icon = Icons.info_outline_rounded;
        break;
      case _InlineMsgType.error:
      default:
        bg = Colors.redAccent.withValues(alpha: 0.08);
        border = Colors.redAccent.withValues(alpha: 0.35);
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: type == _InlineMsgType.error
                ? Colors.redAccent
                : AppColors.lightGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: SizeConfig.ts(12.8),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onClose,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetError extends StatelessWidget {
  const _SheetError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 120),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
