import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ServiceDetailsErrorBox extends StatelessWidget {
  final String message;

  const ServiceDetailsErrorBox({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(all: 14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.20)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: SizeConfig.ts(13),
          color: Colors.red.shade700,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
