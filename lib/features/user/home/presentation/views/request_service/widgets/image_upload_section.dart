// lib/features/home/presentation/views/request_widgets/image_upload_section.dart
import 'dart:io';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ImageUploadSection extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onPickImage;

  const ImageUploadSection({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إرفاق صور (اختياري)', style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary)),
        SizeConfig.v(8),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            height: SizeConfig.h(120),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: selectedImage == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       const  Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.lightGreen),
                        SizeConfig.v(8),
                        const Text('اضغط لإضافة صورة', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity),
                  ),
          ),
        ),
      ],
    );
  }
}