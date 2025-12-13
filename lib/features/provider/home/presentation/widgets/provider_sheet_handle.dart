import 'package:flutter/material.dart';

class ProviderSheetHandle extends StatelessWidget {
  const ProviderSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
