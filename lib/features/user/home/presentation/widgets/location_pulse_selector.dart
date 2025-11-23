// هذا يمكن دمجه مع browse_request_row إذا لزم، لكن للكمال: جزء لاختيار موقع مع pulse animation
import 'package:beitak_app/core/constants/colors.dart';
import 'package:flutter/material.dart';



class LocationPulseSelector extends StatelessWidget {
  const LocationPulseSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.location_on, color: AppColors.primaryGreen),
      onPressed: () {
        // لاحقاً: GPS
      },
    );
  }
}