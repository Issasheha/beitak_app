import 'package:beitak_app/features/provider/home/presentation/views/bookings/manage_availability_view.dart';
import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderManageAvailabilitySheet extends StatelessWidget {
  const ProviderManageAvailabilitySheet({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.96,
          minChildSize: 0.82,
          maxChildSize: 0.98,
          builder: (context, controller) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SizeConfig.radius(26)),
              ),
              child: Material(
                color: AppColors.background,
                child: Column(
                  children: [
                    SizedBox(height: SizeConfig.h(10)),
                    Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(10)),
                    Expanded(
                      child: ProviderManageAvailabilityView(
                        scrollController: controller,
                        onClose: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
