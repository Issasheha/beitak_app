import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderNewRequestCard extends StatelessWidget {
  const ProviderNewRequestCard({
    super.key,
    required this.serviceName,
    required this.customerName,
    required this.onTap,
  });

  final String serviceName;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        child: Container(
          margin: EdgeInsets.only(bottom: SizeConfig.h(8)),
          padding: SizeConfig.padding(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.o(0.05),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: SizeConfig.w(54),
                height: SizeConfig.w(54),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                  color: AppColors.lightGreen.o(0.12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '📩',
                  style: TextStyle(fontSize: SizeConfig.ts(22), height: 1),
                ),
              ),
              SizedBox(width: SizeConfig.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(
                        fontSize: SizeConfig.ts(13.5),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(5)),
                    Text(
                      customerName,
                      style: TextStyle(
                        fontSize: SizeConfig.ts(12.2),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: SizeConfig.w(12)),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: SizeConfig.ts(16),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
