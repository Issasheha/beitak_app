import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class StatusFooterBox extends StatelessWidget {
  final String text;
  final Color bg;
  final Color border;
  final Color textColor;

  const StatusFooterBox({
    super.key,
    required this.text,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
