import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:flutter/material.dart';

class ProviderMyServicesBackground extends StatelessWidget {
  const ProviderMyServicesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Positioned.fill(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.lightGreen.o(0.030),
                      AppColors.lightGreen.o(0.055),
                    ],
                    stops: const [0.55, 0.82, 1.0],
                  ),
                ),
              ),
            ),

            Positioned(left: -170, bottom: -120, child: _arc(420, 0.12, 0.70, Alignment.topRight)),
            Positioned(left: -70, bottom: -30, child: _arc(220, 0.08, 0.72, Alignment.topRight)),
            Positioned(right: -210, bottom: -135, child: _arc(440, 0.06, 0.60, Alignment.topLeft)),

            Align(
              alignment: const Alignment(0.0, 0.38),
              child: _blob(310, AppColors.lightGreen.o(0.020)),
            ),

            Positioned(left: 24, bottom: 155, child: _dot(12, AppColors.lightGreen.o(0.16))),
            Positioned(left: 52, bottom: 125, child: _dot(6, AppColors.lightGreen.o(0.14))),
            Positioned(right: 34, bottom: 210, child: _dot(10, AppColors.lightGreen.o(0.12))),
            Positioned(right: 58, bottom: 185, child: _dot(5, AppColors.lightGreen.o(0.10))),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _arc(double size, double opacity, double heightFactor, Alignment align) {
    return ClipRect(
      child: Align(
        alignment: align,
        heightFactor: heightFactor,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGreen.o(opacity),
          ),
        ),
      ),
    );
  }
}
