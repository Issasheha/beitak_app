import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ServiceDetailsIncompleteNoteBox extends StatelessWidget {
  final String text;

  const ServiceDetailsIncompleteNoteBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
