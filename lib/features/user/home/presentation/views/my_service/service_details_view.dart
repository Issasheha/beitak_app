import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/viewmodels/service_details_providers.dart';

import 'widgets_details/status_ui.dart';
import 'widgets_details/booking_header_card.dart';
import 'widgets_details/details_line.dart';
import 'widgets_details/status_footer_box.dart';
import 'widgets_details/cancel_button.dart';
import 'widgets_details/provider_rating_box.dart';

class ServiceDetailsView extends ConsumerStatefulWidget {
  final BookingListItem initialItem;

  const ServiceDetailsView({
    super.key,
    required this.initialItem,
  });

  @override
  ConsumerState<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends ConsumerState<ServiceDetailsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(serviceDetailsControllerProvider.notifier).loadBookingDetails(
            bookingId: widget.initialItem.bookingId,
          );
    });
  }

  String _readString(
    Map<String, dynamic> j,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final k in keys) {
      final v = j[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return fallback;
  }

  double? _readNum(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      final v = j[k];
      if (v is num) return v.toDouble();
      final parsed = double.tryParse('$v');
      if (parsed != null) return parsed;
    }
    return null;
  }

  int? _readInt(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      final v = j[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      final parsed = int.tryParse('$v');
      if (parsed != null) return parsed;
    }
    return null;
  }

  bool _hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  String _toArabicDigits(String input) {
    const map = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    final b = StringBuffer();
    for (final ch in input.runes) {
      final c = String.fromCharCode(ch);
      b.write(map[c] ?? c);
    }
    return b.toString();
  }

  String _onlyArabicCity(String raw) {
    var r = raw.trim();
    if (r.isEmpty) return '';

    r = r.split(',').first.trim();
    r = r.split('،').first.trim();

    if (_hasArabic(r)) return r;

    final k = r.toLowerCase().trim();
    const map = <String, String>{
      'amman': 'عمان',
      'zarqa': 'الزرقاء',
      'irbid': 'إربد',
      'aqaba': 'العقبة',
      'salt': 'السلط',
      'madaba': 'مادبا',
      'jerash': 'جرش',
      'mafraq': 'المفرق',
      'karak': 'الكرك',
      'tafileh': 'الطفيلة',
      'maan': 'معان',
      'ajloun': 'عجلون',
      'dubai': 'دبي',
    };

    return map[k] ?? '';
  }

  String _formatTimeArabic(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';

    if (r.contains('ص')) return _toArabicDigits(r.replaceAll('ص', 'صباحاً'));
    if (r.contains('م')) return _toArabicDigits(r.replaceAll('م', 'مساءً'));

    final parts = r.split(':');
    if (parts.length >= 2) {
      int h = int.tryParse(parts[0]) ?? 0;
      final m = parts[1];

      final suffix = h >= 12 ? 'مساءً' : 'صباحاً';
      if (h == 0) h = 12;
      if (h > 12) h -= 12;

      return _toArabicDigits('$h:$m $suffix');
    }

    return _toArabicDigits(r);
  }

  String _incompleteNoteArabic(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';
    if (_hasArabic(r)) return r;

    final lower = r.toLowerCase();

    if (lower.contains('automatically marked as incomplete')) {
      final isoMatch = RegExp(r'on\s+([0-9T:\.\-Z]+)').firstMatch(r);
      final hoursMatch = RegExp(r'\(([\d\.]+)\s*hours').firstMatch(r);

      final iso = isoMatch?.group(1) ?? '';
      final hours = hoursMatch?.group(1) ?? '';

      String when = '';
      if (iso.isNotEmpty && iso.contains('T')) {
        final parts = iso.split('T');
        final date = parts[0];
        final time = parts[1].replaceAll('Z', '');
        final hhmm = time.length >= 5 ? time.substring(0, 5) : time;
        when = '${_toArabicDigits(date)} ${_toArabicDigits(hhmm)}';
      } else if (iso.isNotEmpty) {
        when = _toArabicDigits(iso);
      }

      final hoursText = hours.isEmpty ? '' : _toArabicDigits(hours);

      final w = when.isEmpty ? '' : ' بتاريخ $when';
      final h = hoursText.isEmpty ? '' : ' بعد تأخر $hoursText ساعة عن الموعد';

      return 'تم تحويل الحجز إلى "غير مكتمل"$w$h.';
    }

    return 'ملاحظة: $r';
  }

  StatusUi _statusUi(String status) {
    final isCancelled = status == 'cancelled' || status == 'refunded';
    final isCompleted = status == 'completed';
    final isIncomplete = status == 'incomplete';
    final isPending = status == 'pending_provider_accept' || status == 'pending';

    final isUpcoming = const {
      'confirmed',
      'provider_on_way',
      'provider_arrived',
      'in_progress',
    }.contains(status);

    if (isCancelled) {
      return StatusUi(
        label: 'ملغاة',
        color: Colors.red.shade700,
        bg: Colors.red.withValues(alpha: 0.10),
        border: Colors.red.withValues(alpha: 0.35),
        footerText: 'تم إلغاء هذا الحجز ولن يتم تنفيذه.',
      );
    }
    if (isCompleted) {
      return StatusUi(
        label: 'مكتمل',
        color: Colors.blue.shade700,
        bg: Colors.blue.withValues(alpha: 0.10),
        border: Colors.blue.withValues(alpha: 0.35),
        footerText: 'تم تنفيذ الخدمة بنجاح.',
      );
    }
    if (isPending) {
      return StatusUi(
        label: 'قيد الانتظار',
        color: Colors.orange.shade800,
        bg: Colors.orange.withValues(alpha: 0.10),
        border: Colors.orange.withValues(alpha: 0.35),
        footerText: 'بانتظار موافقة مزود الخدمة على طلبك.',
      );
    }
    if (isUpcoming) {
      return StatusUi(
        label: 'قادمة',
        color: AppColors.lightGreen,
        bg: AppColors.lightGreen.withValues(alpha: 0.12),
        border: AppColors.lightGreen.withValues(alpha: 0.35),
        footerText: 'تمت الموافقة على طلبك وسيتم تنفيذ الخدمة حسب الموعد.',
      );
    }
    if (isIncomplete) {
      return StatusUi(
        label: 'غير مكتملة',
        color: Colors.grey.shade700,
        bg: Colors.grey.withValues(alpha: 0.10),
        border: Colors.grey.withValues(alpha: 0.35),
        footerText: 'لم يتم تنفيذ الخدمة ضمن الوقت المحدد وتم تحويلها إلى "غير مكتملة".',
      );
    }

    return StatusUi(
      label: 'حالة الطلب',
      color: Colors.orange.shade800,
      bg: Colors.orange.withValues(alpha: 0.10),
      border: Colors.orange.withValues(alpha: 0.35),
      footerText: 'بانتظار تحديث حالة الطلب.',
    );
  }

  String _cancelReasonArabic(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';
    if (_hasArabic(r)) return r;

    final k = r.toLowerCase();
    if (k.contains('provider')) return 'تم الإلغاء من قبل المزود';
    if (k.contains('customer') || k.contains('user')) return 'تم الإلغاء من قبل العميل';
    if (k.contains('system')) return 'تم الإلغاء تلقائياً';
    return 'سبب الإلغاء غير محدد';
  }

  // ✅ NEW: قراءة تقييم المزود من حالتين:
  // 1) rating.provider_rating / rating.amount_paid / rating.provider_response
  // 2) provider_rating / amount_paid / provider_response مباشرة داخل booking
  Map<String, dynamic>? _readRatingMap(Map<String, dynamic> booking) {
    final r = booking['rating'];
    if (r is Map<String, dynamic>) return r;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(serviceDetailsControllerProvider);
    final details = state.data;
    final base = widget.initialItem;

    final status = details != null
        ? _readString(details, ['status'], fallback: base.status)
        : base.status;

    final ui = _statusUi(status);

    final isCancelled = status == 'cancelled' || status == 'refunded';
    final isCompleted = status == 'completed';
    final isIncomplete = status == 'incomplete';
    final isPending = status == 'pending_provider_accept' || status == 'pending';

    final isUpcoming = const {
      'confirmed',
      'provider_on_way',
      'provider_arrived',
      'in_progress',
    }.contains(status);

    String serviceName = base.serviceName;
    if (details != null) {
      final service = details['service'];
      if (service is Map<String, dynamic>) {
        final ar = _readString(
          service,
          ['name_ar', 'nameAr', 'name_localized', 'nameLocalized'],
          fallback: '',
        );

        if (ar.isNotEmpty && _hasArabic(ar)) {
          serviceName = ar;
        }
      }
    }

    String date = details != null
        ? _readString(details, ['booking_date'], fallback: base.date)
        : base.date;
    date = _toArabicDigits(date);

    final timeRaw = details != null
        ? _readString(details, ['booking_time'], fallback: base.time)
        : base.time;
    final time = _formatTimeArabic(timeRaw);

    String city = details != null ? _readString(details, ['service_city']) : '';
    city = _onlyArabicCity(city);
    final loc = city.isEmpty ? '' : city;
const currency = 'د.أ';

    final price = details != null
        ? (_readNum(details, ['total_price', 'base_price']) ?? base.price)
        : base.price;
        
    final priceText = price == null
    ? 'غير محدد'
    : '${_toArabicDigits(price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2))} $currency';

    String? providerName = base.providerName;
    String? providerPhone = base.providerPhone;

    if (details != null) {
      final provider = details['provider'];
      if (provider is Map<String, dynamic>) {
        final user = provider['user'];
        if (user is Map<String, dynamic>) {
          final fn = _readString(user, ['first_name'], fallback: '');
          final ln = _readString(user, ['last_name'], fallback: '');
          final full = ('$fn $ln').trim();
          if (full.isNotEmpty) providerName = full;

          final ph = user['phone'];
          if (ph != null) {
            final p = ph.toString().trim();
            if (p.isNotEmpty) providerPhone = p;
          }
        }
      }
    }

    final rawCancelReason = details == null
        ? ''
        : _readString(details, [
            'cancellation_reason',
            'cancel_reason',
            'cancellation_note',
          ]);
    final cancelReason = _cancelReasonArabic(rawCancelReason);

    final rawProviderNotes = details == null ? '' : _readString(details, ['provider_notes']);
    final incompleteNote = isIncomplete ? _incompleteNoteArabic(rawProviderNotes) : '';

    final bookingNumber = _toArabicDigits(
      base.bookingNumber.startsWith('#') ? base.bookingNumber : '#${base.bookingNumber}',
    );

    // ✅ NEW: rating data
    final ratingMap = details == null ? null : _readRatingMap(details);

    final providerRating = details == null
        ? null
        : (_readInt(ratingMap ?? details, ['provider_rating', 'providerRating']));

    final amountPaid = details == null
        ? null
        : (_readNum(ratingMap ?? details, ['amount_paid', 'amountPaid']));

    final providerResponse = details == null
        ? ''
        : _readString(
            ratingMap ?? details,
            ['provider_response', 'providerResponse'],
            fallback: '',
          );

    final providerRatedAt = details == null
        ? null
        : _readString(
            ratingMap ?? details,
            ['provider_response_at', 'providerResponseAt'],
            fallback: '',
          ).trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'تفاصيل الخدمة',
            style: TextStyle(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () => ref
              .read(serviceDetailsControllerProvider.notifier)
              .loadBookingDetails(bookingId: widget.initialItem.bookingId),
          child: ListView(
            padding: SizeConfig.padding(horizontal: 16, bottom: 24),
            children: [
              BookingHeaderCard(
                bookingNumber: bookingNumber,
                serviceName: serviceName,
                statusLabel: ui.label,
                statusColor: ui.color,
                background: ui.bg,
              ),
              SizeConfig.v(18),

              Center(
                child: Text(
                  'تفاصيل الخدمة',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizeConfig.v(18),

              DetailsLine(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.textSecondary,
                label: 'التاريخ:',
                value: date.isEmpty ? '—' : date,
              ),
              DetailsLine(
                icon: Icons.access_time_rounded,
                iconColor: AppColors.textSecondary,
                label: 'الوقت:',
                value: time.isEmpty ? '—' : time,
              ),
              if (loc.isNotEmpty)
                DetailsLine(
                  icon: Icons.location_on_rounded,
                  iconColor: Colors.red.shade600,
                  label: 'الموقع:',
                  value: loc,
                ),
              DetailsLine(
                icon: Icons.payments_rounded,
                iconColor: AppColors.textSecondary,
                label: 'السعر:',
                value: priceText,
              ),
              DetailsLine(
                icon: Icons.person_rounded,
                iconColor: AppColors.textSecondary,
                label: 'المزود:',
                value: providerName ?? 'غير متاح حالياً',
              ),
              if (providerPhone != null && providerPhone.trim().isNotEmpty)
                DetailsLine(
                  icon: Icons.phone_rounded,
                  iconColor: AppColors.textSecondary,
                  label: 'الهاتف:',
                  value: _toArabicDigits(providerPhone),
                ),

              if (isCancelled)
                DetailsLine(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.red.shade700,
                  label: 'سبب الإلغاء:',
                  value: cancelReason.isEmpty ? 'غير محدد' : cancelReason,
                ),

              if (state.isLoading) ...[
                SizeConfig.v(14),
                const Center(child: CircularProgressIndicator()),
              ],

              if (state.error != null) ...[
                SizeConfig.v(12),
                Container(
                  padding: SizeConfig.padding(all: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.20)),
                  ),
                  child: Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(13),
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              SizeConfig.v(18),

              StatusFooterBox(
                text: ui.footerText,
                bg: ui.bg,
                border: ui.border,
                textColor: ui.color,
              ),

              // ✅ NEW: عرض تقييم مزود الخدمة للمستخدم (ضمن الحجز المكتمل)
              if (isCompleted) ...[
                SizeConfig.v(12),
                ProviderRatingBox(
                  rating: providerRating,
                  amountPaid: amountPaid,
                  currency: currency,
                  message: providerResponse,
                  ratedAt: providerRatedAt!.isEmpty ? null : providerRatedAt,
                ),
              ],

              // ✅ صندوق ملاحظة incomplete من provider_notes
              if (isIncomplete && incompleteNote.isNotEmpty) ...[
                SizeConfig.v(12),
                Container(
                  padding: SizeConfig.padding(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          incompleteNote,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(13),
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade800,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ✅ ما بنعرض إلغاء للحالات غير المناسبة
              if (!isCancelled && !isCompleted && !isIncomplete && (isPending || isUpcoming))
                CancelButton(
                  isLoading: ref.watch(serviceDetailsControllerProvider).isCancelling,
                  onPressed: () => _confirmCancel(status),
                ),

              SizeConfig.v(10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(String currentStatus) async {
    final noteCtrl = TextEditingController();

    const categories = <String>[
      'تغيير الموعد',
      'لم أعد بحاجة للخدمة',
      'وجدت مزود خدمة آخر',
      'سعر غير مناسب',
      'سبب آخر',
    ];

    String? selectedCategory;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    const Text('تأكيد إلغاء الطلب'),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'اختر سبب الإلغاء:',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: categories.map((c) {
                          final isSelected = selectedCategory == c;
                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => setState(() => selectedCategory = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.red.withValues(alpha: 0.12)
                                    : Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red.withValues(alpha: 0.55)
                                      : Colors.grey.withValues(alpha: 0.20),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(12),
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.red.shade700 : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'ملاحظات إضافية (اختياري):',
                        style: TextStyle(
                          fontSize: SizeConfig.ts(13),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteCtrl,
                        maxLines: 2,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'مثلاً: أريد تأجيل الموعد إلى يوم آخر...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.red.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(
                      'رجوع',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('تأكيد الإلغاء'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (ok != true) {
      noteCtrl.dispose();
      return;
    }

    final controller = ref.read(serviceDetailsControllerProvider.notifier);

    final success = await controller.cancelBooking(
      bookingId: widget.initialItem.bookingId,
      currentStatus: currentStatus,
      cancellationCategory: selectedCategory,
      cancellationReason: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
    );

    noteCtrl.dispose();

    final latest = ref.read(serviceDetailsControllerProvider);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
      );

      if (!context.mounted) return;
      context.pop(true);
    } else {
      final msg = latest.error ?? 'تعذّر إلغاء الطلب';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
