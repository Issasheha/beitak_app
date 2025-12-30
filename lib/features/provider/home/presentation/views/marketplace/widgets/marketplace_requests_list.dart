import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/widgets/marketplace_request_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/widgets/marketplace_states_widgets.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_request_ui_model.dart';

class MarketplaceRequestsList extends StatelessWidget {
  final MarketplaceState state;
  final ScrollController scrollController;

  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;

  final void Function(MarketplaceRequestUiModel req) onOpenDetails;
  final void Function(int requestId) onAccept;
  final VoidCallback onLoadMore;

  const MarketplaceRequestsList({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRetry,
    required this.onRefresh,
    required this.onOpenDetails,
    required this.onAccept,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.allRequests.isEmpty) {
      return MarketplaceErrorState(message: state.errorMessage!, onRetry: onRetry);
    }

    final items = state.visibleRequests;
    if (items.isEmpty) return const MarketplaceEmptyState();

    final showFooter =
        state.isLoadingMore || state.loadMoreFailed || state.hasMore;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: items.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.loadMoreFailed) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: TextButton(
                    onPressed: onLoadMore,
                    child: const Text(
                      'فشل تحميل المزيد — اضغط لإعادة المحاولة',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              );
            }

            return const SizedBox(height: 8);
          }

          final req = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MarketplaceRequestCard(
              request: req,
              onTap: () => onOpenDetails(req),
              onAccept: () => onAccept(req.id),
            ),
          );
        },
      ),
    );
  }
}
