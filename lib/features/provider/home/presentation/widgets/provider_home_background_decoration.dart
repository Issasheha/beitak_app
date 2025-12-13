import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';

class ProviderHomeBackgroundDecoration extends StatelessWidget {
  const ProviderHomeBackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
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
                    stops: const [0.60, 0.84, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(left: -140, top: -110, child: _blob(270, Colors.white.o(0.08))),
            Positioned(
              left: -190,
              bottom: -120,
              child: _arc(size: 420, opacity: 0.13, heightFactor: 0.70, align: Alignment.topRight),
            ),
            Positioned(
              left: -75,
              bottom: -35,
              child: _arc(size: 220, opacity: 0.09, heightFactor: 0.72, align: Alignment.topRight),
            ),
            Positioned(
              right: -210,
              bottom: -135,
              child: _arc(size: 440, opacity: 0.07, heightFactor: 0.60, align: Alignment.topLeft),
            ),
            Align(alignment: const Alignment(0.0, 0.42), child: _blob(320, AppColors.lightGreen.o(0.025))),
            Positioned(left: 24, bottom: 155, child: _dot(12, AppColors.lightGreen.o(0.16))),
            Positioned(left: 52, bottom: 125, child: _dot(6, AppColors.lightGreen.o(0.14))),
            Positioned(right: 34, bottom: 210, child: _dot(10, AppColors.lightGreen.o(0.12))),
            Positioned(right: 58, bottom: 185, child: _dot(5, AppColors.lightGreen.o(0.10))),
            Positioned(right: 46, bottom: 95, child: _dot(9, AppColors.lightGreen.o(0.10))),
          ],
        ),
      ),
    );
  }

  static Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  static Widget _dot(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  static Widget _arc({
    required double size,
    required double opacity,
    required double heightFactor,
    required Alignment align,
  }) {
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
