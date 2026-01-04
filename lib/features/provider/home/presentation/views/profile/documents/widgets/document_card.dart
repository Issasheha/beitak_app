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

  int _maxFilesForDoc(ProviderDocument d) {
    // الهوية فقط 2، غيرها 1
    return d.kind == ProviderDocKind.idCard ? 2 : 1;
  }

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
    final hasFiles = document.fileNames.isNotEmpty;
    final maxFiles = _maxFilesForDoc(document);
    final isAtLimit = document.fileNames.length >= maxFiles;

    final borderColor = document.isVerified
        ? AppColors.lightGreen
        : AppColors.borderLight.withValues(alpha: 0.8);

    final statusColor =
        document.isVerified ? AppColors.lightGreen : AppColors.textSecondary;

    // ✅ كل الوثائق مطلوبة (لا اختياري/موصى بها)
    final statusText = document.isVerified
        ? 'موثّقة'
        : (!hasFiles ? 'مطلوبة' : 'قيد المراجعة');

    final statusIcon = document.isVerified
        ? Icons.check_circle
        : (hasFiles ? Icons.hourglass_top_rounded : Icons.lock_outline);

    // ✅ زر الرفع: إذا وصلت الحد وما في استبدال/حذف => نوقفه
    final canUpload = (onUploadTap != null) && !document.isUploading && !isAtLimit;

    final buttonLabel = !hasFiles
        ? 'رفع الوثائق'
        : (isAtLimit ? 'تم الرفع' : 'إضافة / تحديث');

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
              onPressed: canUpload ? onUploadTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                disabledBackgroundColor:
                    AppColors.lightGreen.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
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
                        Icon(
                          isAtLimit ? Icons.check_circle_outline : Icons.upload_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),

          // ✅ سطر بسيط يوضح السبب لما يكون Disabled
          if (isAtLimit && !document.isVerified) ...[
            SizeConfig.v(6),
            Text(
              document.kind == ProviderDocKind.idCard
                  ? 'تم رفع الحد الأقصى للهوية (2 ملفات).'
                  : 'تم رفع الحد الأقصى لهذه الوثيقة (ملف واحد).',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption11.copyWith(
                fontSize: SizeConfig.ts(11.2),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
