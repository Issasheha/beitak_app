// lib/features/provider/home/presentation/views/profile/documents/widgets/document_card.dart

import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/viewmodels/provider_documents_state.dart';

class DocumentCard extends StatelessWidget {
  final ProviderDocument document;
  final VoidCallback? onUploadTap;
  final VoidCallback? onOpenTap;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onUploadTap,
    required this.onOpenTap,
  });

  String _fileLine(ProviderDocument d) {
    if (d.fileNames.isEmpty) return 'لم يتم رفع أي ملف بعد';
    if (d.fileNames.length == 1) return d.fileNames.first;

    final firstTwo = d.fileNames.take(2).toList();
    final more = d.fileNames.length - firstTwo.length;
    final joined = firstTwo.join(' ، ');
    return more > 0 ? '$joined ... (+$more)' : joined;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = document.isVerified
        ? AppColors.lightGreen
        : AppColors.borderLight.withValues(alpha: 0.8);

    final hasFiles = document.fileNames.isNotEmpty;

    final statusColor =
        document.isVerified ? AppColors.lightGreen : AppColors.textSecondary;

    final statusText = document.isVerified
        ? 'موثّقة'
        : (!hasFiles
            ? (document.isRequired
                ? 'مطلوبة'
                : (document.isRecommended ? 'موصى بها' : 'اختيارية'))
            : 'قيد المراجعة');

    final statusIcon = document.isVerified
        ? Icons.check_circle
        : (hasFiles ? Icons.hourglass_top_rounded : Icons.lock_outline);

    final buttonLabel = !hasFiles ? 'رفع الوثائق' : 'تحديث الوثائق';
    final fileLine = _fileLine(document);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: borderColor),
      ),
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                size: SizeConfig.ts(18),
                color: statusColor,
              ),
              SizeConfig.hSpace(6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(14),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizeConfig.v(2),
                    Text(
                      statusText,
                      style: AppTextStyles.caption11.copyWith(
                        fontSize: SizeConfig.ts(11.5),
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizeConfig.v(10),

          Container(
            padding: SizeConfig.padding(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
              onTap: hasFiles ? onOpenTap : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fileLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(12.5),
                        color: !hasFiles
                            ? AppColors.textSecondary.withValues(alpha: 0.7)
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        decoration: hasFiles
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  SizeConfig.hSpace(6),
                  Icon(
                    hasFiles ? Icons.open_in_new : Icons.cloud_upload_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          SizeConfig.v(10),

          SizedBox(
            height: SizeConfig.h(42),
            child: ElevatedButton(
              onPressed: onUploadTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
                ),
              ),
              child: document.isUploading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonLabel,
                          style: AppTextStyles.body14.copyWith(
                            fontSize: SizeConfig.ts(13),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizeConfig.hSpace(6),
                        const Icon(Icons.upload_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
