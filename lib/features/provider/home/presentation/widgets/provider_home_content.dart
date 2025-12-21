import 'dart:async';

import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/provider/home/presentation/viewmodels/provider_home_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_empty_white_box.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_expandable_section_header.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_new_request_card.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_today_task_card.dart';

@immutable
class ProviderNewRequestUI {
  final String serviceName;
  final String customerName;
  const ProviderNewRequestUI({
    required this.serviceName,
    required this.customerName,
  });
}

@immutable
class ProviderTodayTaskUI {
  final String serviceName;
  final String customerName;
  final String timeText;
  final String durationText;
  final String locationText;
  final String priceText;

  const ProviderTodayTaskUI({
    required this.serviceName,
    required this.customerName,
    required this.timeText,
    required this.durationText,
    required this.locationText,
    required this.priceText,
  });
}

/// Dashboard body + ✅ smart silent polling (route-aware via isCurrent)
class ProviderHomeContent extends StatefulWidget {
  const ProviderHomeContent({
    super.key,
    required this.vm,
    required this.expandNewRequests,
    required this.expandTodayTask,
    required this.todayBusy,
    required this.hasNew,
    required this.hasToday,
    required this.onToggleNewRequests,
    required this.onToggleTodayTask,
    required this.onNewRequestsTap,
    required this.todayTaskUi,
    required this.newRequestUi,
    required this.onTodayDetailsTap,
    required this.onTodayCompleteTap,
    required this.onTodayCancelTap,

    // ✅ A) Smart polling defaults
    this.enablePolling = true,
    this.pollingInterval = const Duration(seconds: 25),
    this.refreshOnResume = true,

    // optional: if you want to skip while expanded
    this.skipPollingWhenExpanded = false,
  });

  final ProviderHomeViewModel vm;

  final bool expandNewRequests;
  final bool expandTodayTask;
  final bool todayBusy;

  final bool hasNew;
  final bool hasToday;

  final VoidCallback onToggleNewRequests;
  final VoidCallback onToggleTodayTask;

  final VoidCallback onNewRequestsTap;

  final ProviderTodayTaskUI? todayTaskUi;
  final ProviderNewRequestUI? newRequestUi;

  final VoidCallback onTodayDetailsTap;
  final VoidCallback? onTodayCompleteTap;
  final VoidCallback? onTodayCancelTap;

  final bool enablePolling;
  final Duration pollingInterval;
  final bool refreshOnResume;
  final bool skipPollingWhenExpanded;

  @override
  State<ProviderHomeContent> createState() => _ProviderHomeContentState();
}

class _ProviderHomeContentState extends State<ProviderHomeContent>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startPolling();
    });
  }

  @override
  void didUpdateWidget(covariant ProviderHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final settingsChanged =
        oldWidget.enablePolling != widget.enablePolling ||
        oldWidget.pollingInterval != widget.pollingInterval ||
        oldWidget.skipPollingWhenExpanded != widget.skipPollingWhenExpanded;

    if (settingsChanged) {
      _stopPolling();
      _startPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ Route visibility: stops updates when BottomSheet / navigation opened
  bool _isPageVisible() {
    if (!mounted) return false;
    final route = ModalRoute.of(context);
    if (route == null) return true; // fallback
    return route.isCurrent;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.refreshOnResume) return;

    if (state == AppLifecycleState.resumed) {
      // ✅ resume refresh (silent)
      _safeRefresh(silent: true);

      // ✅ restart polling
      _stopPolling();
      _startPolling();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (!widget.enablePolling) return;

    _timer = Timer.periodic(widget.pollingInterval, (_) async {
      // Only if visible
      if (!_isPageVisible()) return;

      // optionally skip when expanded
      if (widget.skipPollingWhenExpanded &&
          (widget.expandNewRequests || widget.expandTodayTask)) {
        return;
      }

      // ✅ silent polling
      await _safeRefresh(silent: true);
    });
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _safeRefresh({required bool silent}) async {
    if (!mounted) return;
    if (!_isPageVisible()) return;
    if (_inFlight) return;

    // avoid stacking on existing loading
    if (!silent && widget.vm.isLoading) return;

    _inFlight = true;
    try {
      // ✅ silent refresh won't flicker loading UI
      await widget.vm.refresh(silent: silent);
    } catch (_) {
      // viewmodel already handles error policy; silent ignores new errors
    } finally {
      _inFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SizeConfig.padding(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Only show loading banner when it's a real loading (not silent)
            if (widget.vm.isLoading)
              const ProviderEmptyWhiteBox(text: 'جاري التحميل...')
            else if (widget.vm.errorMessage != null)
              ProviderEmptyWhiteBox(text: widget.vm.errorMessage!)
            else
              const SizedBox.shrink(),

            SizedBox(height: SizeConfig.h(8)),

            ProviderExpandableSectionHeader(
              title: 'طلبات خدمات جديدة',
              subtitle: 'بانتظار قبولك وتقديم عروضك',
              count: widget.vm.totalRequestsCount,
              emoji: '📥',
              expanded: widget.expandNewRequests,
              onTap: widget.onToggleNewRequests,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: widget.expandNewRequests
                  ? Padding(
                      padding: EdgeInsets.only(top: SizeConfig.h(10)),
                      child: (!widget.hasNew || widget.newRequestUi == null)
                          ? const ProviderEmptyWhiteBox(
                              text: 'لا توجد طلبات جديدة حالياً',
                            )
                          : ProviderNewRequestCard(
                              serviceName: widget.newRequestUi!.serviceName,
                              customerName: widget.newRequestUi!.customerName,
                              onTap: widget.onNewRequestsTap,
                            ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: SizeConfig.h(10)),

            ProviderExpandableSectionHeader(
              title: 'مهمة اليوم',
              subtitle: 'خدماتك المجدولة لهذا اليوم',
              count: widget.hasToday ? 1 : 0,
              emoji: '📌',
              expanded: widget.expandTodayTask,
              onTap: widget.onToggleTodayTask,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: widget.expandTodayTask
                  ? Padding(
                      padding: EdgeInsets.only(top: SizeConfig.h(10)),
                      child: (!widget.hasToday || widget.todayTaskUi == null)
                          ? const ProviderEmptyWhiteBox(
                              text: 'لا يوجد شغل مجدول لليوم',
                            )
                          : ProviderTodayTaskCard(
                              item: widget.todayTaskUi!,
                              busy: widget.todayBusy,
                              onDetailsTap: widget.onTodayDetailsTap,
                              onCompleteTap: widget.onTodayCompleteTap,
                              onCancelTap: widget.onTodayCancelTap,
                            ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(height: SizeConfig.h(24)),
          ],
        ),
      ),
    );
  }
}
