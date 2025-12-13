import 'dart:io';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ImageUploadSection extends StatelessWidget {
  final List<File> files;
  final VoidCallback onPick;
  final ValueChanged<int> onRemoveAt;

  const ImageUploadSection({
    super.key,
    required this.files,
    required this.onPick,
    required this.onRemoveAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إرفاق صور (اختياري)',
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload),
                label: const Text('رفع صور'),
                style: OutlinedButton.styleFrom(
                  padding: SizeConfig.padding(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.borderLight),
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        if (files.isNotEmpty) ...[
          SizedBox(height: SizeConfig.h(10)),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              separatorBuilder: (_, __) => SizedBox(width: SizeConfig.w(10)),
              itemBuilder: (context, i) {
                final f = files[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        f,
                        width: 86,
                        height: 86,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => onRemoveAt(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
