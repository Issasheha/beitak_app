import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class PulsingAvatar extends StatefulWidget {
  final String initials;

  const PulsingAvatar({super.key, required this.initials});

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen
                    .withValues(alpha: _controller.value * 0.10),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: SizeConfig.w(30),
            backgroundColor: AppColors.lightGreen,
            child: Text(widget.initials,
                style: TextStyle(
                    fontSize: SizeConfig.ts(18), color: AppColors.white)),
          ),
        );
      },
    );
  }
}
