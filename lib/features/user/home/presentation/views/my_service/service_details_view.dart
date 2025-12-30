import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/number_format.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/viewmodels/service_details_providers.dart';

import 'widgets_details/status_ui.dart';
import 'widgets_details/booking_header_card.dart';
import 'widgets_details/status_footer_box.dart';
import 'widgets_details/cancel_button.dart';
import 'widgets_details/provider_rating_box.dart';
import 'widgets_details/user_rating_sheet.dart';

// ✅ NEW (Refactor)
import 'widgets_details/service_details_mapper.dart';
import 'widgets_details/service_status_mapper.dart';
import 'widgets_details/service_details_info_section.dart';
import 'widgets_details/service_details_error_box.dart';
import 'widgets_details/service_details_incomplete_note_box.dart';
import 'widgets_details/user_rating_summary_card.dart';
import 'widgets_details/cancel_booking_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(serviceDetailsControllerProvider);
    final details = state.data;

    // ✅ Build ViewModel
    final vm = ServiceDetailsMapper.build(
      base: widget.initialItem,
      details: details,
    );

    final ui = ServiceStatusMapper.ui(vm.status);

    Future<void> openUserRatingSheet() async {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => UserRatingSheet(
          bookingId: widget.initialItem.bookingId,
          serviceTitle: vm.serviceName,
          providerName: vm.providerName ?? 'مزود الخدمة',
        ),
      );

      if (ok == true) {
        await ref
            .read(serviceDetailsControllerProvider.notifier)
            .loadBookingDetails(bookingId: widget.initialItem.bookingId);
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
              .loadBookingDetails(bookingId: widget.initialItem.bookingId),
          child: ListView(
            padding: SizeConfig.padding(horizontal: 16, bottom: 24),
            children: [
              BookingHeaderCard(
                bookingNumber: vm.bookingNumber,
                serviceName: vm.serviceName,
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

              // ✅ details lines (date/time/location/price/provider/phone/cancel reason)
              ServiceDetailsInfoSection(
                date: vm.date,
                time: vm.time,
                location: vm.location,
                priceText: vm.priceText,
                providerName: vm.providerName,
                providerPhone: vm.providerPhone,
                isCancelled: vm.isCancelled,
                // ✅ حسب طلبك: الاندبوينت ما فيها سبب -> خليه "غير محدد"
                cancelReason: 'غير محدد',
              ),

              if (state.isLoading) ...[
                SizeConfig.v(14),
                const Center(child: CircularProgressIndicator()),
              ],

              if (state.error != null) ...[
                SizeConfig.v(12),
                ServiceDetailsErrorBox(message: state.error!),
              ],

              SizeConfig.v(18),

              StatusFooterBox(
                text: ui.footerText,
                bg: ui.bg,
                border: ui.border,
                textColor: ui.color,
              ),

              if (vm.isCompleted) ...[
                SizeConfig.v(12),
                ProviderRatingBox(
                  rating: vm.providerRating,
                  amountPaid: vm.amountPaidProvider,
                  currency: 'د.أ',
                  message: vm.providerResponse,
                  ratedAt: (vm.providerRatedAt == null ||
                          vm.providerRatedAt!.trim().isEmpty)
                      ? null
                      : NumberFormat.smart(vm.providerRatedAt!.trim()),
                ),
              ],

              if (vm.isCompleted) ...[
                SizeConfig.v(12),
                UserRatingSummaryCard(
                  hasRated: vm.userHasRated,
                  rating: vm.userRatingValue,
                  review: vm.userReview,
                  amountPaid: vm.userAmountPaid,
                  currency: 'د.أ',
                  ratedAt: vm.userRatedAt.isEmpty ? null : vm.userRatedAt,
                  onRate: vm.userHasRated ? null : openUserRatingSheet,
                ),
              ],

              if (vm.isIncomplete && vm.incompleteNote.isNotEmpty) ...[
                SizeConfig.v(12),
                ServiceDetailsIncompleteNoteBox(text: vm.incompleteNote),
              ],

              if (!vm.isCancelled &&
                  !vm.isCompleted &&
                  !vm.isIncomplete &&
                  (vm.isPending || vm.isUpcoming))
                CancelButton(
                  isLoading:
                      ref.watch(serviceDetailsControllerProvider).isCancelling,
                  onPressed: () => _confirmCancel(vm.status),
                ),

              SizeConfig.v(10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(String currentStatus) async {
    final res = await CancelBookingDialog.show(context);
    if (res == null || res.confirmed != true) return;

    final controller = ref.read(serviceDetailsControllerProvider.notifier);

    final success = await controller.cancelBooking(
      bookingId: widget.initialItem.bookingId,
      currentStatus: currentStatus,
      cancellationCategory: res.category,
      cancellationReason: res.note,
    );

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
