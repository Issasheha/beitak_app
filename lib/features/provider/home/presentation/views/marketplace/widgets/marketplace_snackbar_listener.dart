import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceSnackbarListener extends ConsumerWidget {
  final Widget child;
  const MarketplaceSnackbarListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(marketplaceControllerProvider, (prev, next) {
      final msg = next.uiMessage;
      if (msg != null && msg.isNotEmpty && msg != prev?.uiMessage) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        Future.microtask(() {
          ref.read(marketplaceControllerProvider.notifier).clearUiMessage();
        });
      }
    });

    return child;
  }
}
