import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/viewmodels/service_details_providers.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/detail_row_tile.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/status_header_card.dart';

class ServiceDetailsView extends ConsumerStatefulWidget {
  final BookingListItem initialItem;

  const ServiceDetailsView({
    super.key,
    required this.initialItem,
  });

  @override
  ConsumerState<ServiceDetailsView> createState() =>
      _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends ConsumerState<ServiceDetailsView> {
  @override
  void initState() {
    super.initState();
    // تحميل التفاصيل أول ما تفتح الشاشة
    Future.microtask(() {
      ref
          .read(serviceDetailsControllerProvider.notifier)
          .loadBookingDetails(
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(serviceDetailsControllerProvider);
    final details = state.data;
    final base = widget.initialItem;

    final status = details != null
        ? _readString(details, ['status'], fallback: base.status)
        : base.status;

    final isCancelled = status == 'cancelled' || status == 'refunded';
    final isCompleted = status == 'completed';
    final isPending =
        status == 'pending_provider_accept' || status == 'pending';

    final isUpcoming = const {
      'confirmed',
      'provider_on_way',
      'provider_arrived',
      'in_progress',
    }.contains(status);

    final title = isCancelled
        ? 'خدمة ملغاة'
        : isCompleted
            ? 'خدمة مكتملة'
            : isPending
                ? 'طلب قيد الانتظار'
                : 'طلب قادم';

    final subtitle = isCancelled
        ? 'تم إلغاء هذا الطلب ولن يتم تنفيذه.'
        : isCompleted
            ? 'تم تنفيذ الخدمة بنجاح.'
            : isPending
                ? 'بانتظار موافقة مزود الخدمة.'
                : 'تمت الموافقة وسيتم تنفيذ الخدمة حسب الموعد.';

    final headerColor = isCancelled
        ? Colors.red.shade600
        : isCompleted
            ? Colors.blue.shade700
            : isPending
                ? Colors.orange.shade700
                : AppColors.lightGreen;

    final headerIcon = isCancelled
        ? Icons.cancel_rounded
        : isCompleted
            ? Icons.verified_rounded
            : isPending
                ? Icons.hourglass_top_rounded
                : Icons.schedule_rounded;

    // service name
    String serviceName = base.serviceName;
    if (details != null) {
      final service = details['service'];
      if (service is Map<String, dynamic>) {
        serviceName = _readString(
          service,
          ['name_localized', 'name_ar', 'name'],
          fallback: serviceName,
        );
      }
    }

    final date = details != null
        ? _readString(details, ['booking_date'], fallback: base.date)
        : base.date;

    final timeRaw = details != null
        ? _readString(details, ['booking_time'], fallback: base.time)
        : base.time;

    final city = details != null
        ? _readString(details, ['service_city'], fallback: '')
        : '';
    final area = details != null
        ? _readString(details, ['service_area'], fallback: '')
        : '';
    final address = details != null
        ? _readString(details, ['service_address'], fallback: '')
        : '';

    final locRaw = [city, area, address]
        .where((e) => e.trim().isNotEmpty)
        .join('، ');
    final loc = locRaw.isNotEmpty ? locRaw : base.location;

    final price = details != null
        ? (_readNum(details, ['total_price', 'base_price']) ?? base.price)
        : base.price;

    final currency = base.currency ?? 'JOD';
    final priceText = price == null
        ? 'غير محدد'
        : '$currency ${price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2)}';

    // provider info
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
              .loadBookingDetails(
                bookingId: widget.initialItem.bookingId,
              ),
          child: ListView(
            padding: SizeConfig.padding(horizontal: 16, bottom: 24),
            children: [
              StatusHeaderCard(
                title: title,
                subtitle: subtitle,
                color: headerColor,
                icon: headerIcon,
              ),
              SizeConfig.v(14),

              // بطاقة العنوان + رقم الطلب
              Container(
                padding: SizeConfig.padding(all: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color:
                            AppColors.lightGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.build_rounded,
                        color: AppColors.lightGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            style: TextStyle(
                              fontSize: SizeConfig.ts(16),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'رقم الطلب: ${base.bookingNumber}',
                            style: TextStyle(
                              fontSize: SizeConfig.ts(12),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizeConfig.v(12),

              DetailRowTile(
                icon: Icons.calendar_today_rounded,
                label: 'التاريخ',
                value: date.isEmpty ? '—' : date,
              ),
              DetailRowTile(
                icon: Icons.access_time_rounded,
                label: 'الوقت',
                value: timeRaw.isEmpty ? '—' : timeRaw,
              ),
              DetailRowTile(
                icon: Icons.location_on_rounded,
                label: 'الموقع',
                value: loc.isEmpty ? '—' : loc,
              ),
              DetailRowTile(
                icon: Icons.payments_rounded,
                label: 'السعر',
                value: priceText,
              ),
              DetailRowTile(
                icon: Icons.person_rounded,
                label: 'مزود الخدمة',
                value: providerName ?? 'غير متاح حالياً',
              ),
              if (providerPhone != null && providerPhone.trim().isNotEmpty)
                DetailRowTile(
                  icon: Icons.phone_rounded,
                  label: 'هاتف مزود الخدمة',
                  value: providerPhone!,
                ),

              if (state.isLoading) ...[
                SizeConfig.v(12),
                const Center(child: CircularProgressIndicator()),
              ],

              if (state.error != null) ...[
                SizeConfig.v(12),
                Container(
                  padding: SizeConfig.padding(all: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(13),
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              // قسم الإلغاء (لو لسه مش ملغى/مكتمل)
              if (!isCancelled && !isCompleted && (isPending || isUpcoming))
                _buildCancelSection(
                  status: status,
                  isPending: isPending,
                  isUpcoming: isUpcoming,
                ),

              SizeConfig.v(10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSection({
    required String status,
    required bool isPending,
    required bool isUpcoming,
  }) {
    final state = ref.watch(serviceDetailsControllerProvider);

    return Padding(
      padding: SizeConfig.padding(top: 14),
      child: Container(
        padding: SizeConfig.padding(all: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إلغاء الطلب',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w900,
                color: Colors.red.shade700,
              ),
            ),
            SizeConfig.v(8),
            Text(
              isPending
                  ? 'يمكنك إلغاء الطلب الآن قبل قبول مزود الخدمة.'
                  : 'سيتم إرسال طلب إلغاء (قد يفشل إذا كان الوقت متأخرًا حسب سياسة الإلغاء).',
              style: TextStyle(
                fontSize: SizeConfig.ts(12),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            SizeConfig.v(12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: state.isCancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_rounded),
                label: Text(
                  state.isCancelling ? 'جارٍ الإلغاء...' : 'إلغاء الطلب',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(
                    color: Colors.red.withValues(alpha: 0.55),
                    width: 1.4,
                  ),
                  padding: SizeConfig.padding(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: state.isCancelling
                    ? null
                    : () => _confirmCancel(status),
              ),
            ),
          ],
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
                    Icon(Icons.cancel_rounded,
                        color: Colors.red.shade700),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: categories.map((c) {
                          final isSelected = selectedCategory == c;
                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () =>
                                setState(() => selectedCategory = c),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.red
                                        .withValues(alpha: 0.12)
                                    : Colors.grey
                                        .withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                          .withValues(alpha: 0.55)
                                      : Colors.grey
                                          .withValues(alpha: 0.20),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(12),
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.red.shade700
                                      : AppColors.textPrimary,
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
                        decoration: InputDecoration(
                          hintText:
                              'مثلاً: أريد تأجيل الموعد إلى يوم آخر...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.red
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (currentStatus != 'pending_provider_accept' &&
                          currentStatus != 'pending')
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'قد يتم رفض طلب الإلغاء إذا كان موعد الخدمة قد اقترب جداً حسب سياسة الإلغاء.',
                            style: TextStyle(
                              fontSize: SizeConfig.ts(11.5),
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
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

    if (ok != true) return;

    final controller =
        ref.read(serviceDetailsControllerProvider.notifier);

    final success = await controller.cancelBooking(
      bookingId: widget.initialItem.bookingId,
      currentStatus: currentStatus,
      cancellationCategory: selectedCategory,
      cancellationReason: noteCtrl.text.trim().isEmpty
          ? null
          : noteCtrl.text.trim(),
    );

    final latest = ref.read(serviceDetailsControllerProvider);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
      );

      // ✅ هذا هو الربط مع MyServices: نرجع true
      context.pop(true);
    } else {
      final msg = latest.error ?? 'تعذّر إلغاء الطلب';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}
