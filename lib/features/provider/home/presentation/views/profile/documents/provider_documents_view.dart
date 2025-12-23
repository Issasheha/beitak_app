import 'dart:io';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/provider_documents_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/provider_documents_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProviderDocumentsView extends ConsumerWidget {
  const ProviderDocumentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final asyncState = ref.watch(providerDocumentsControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'إدارة الوثائق',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: () => ref
                .read(providerDocumentsControllerProvider.notifier)
                .refresh(),
          ),
          data: (state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: SizeConfig.padding(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...state.docs.map(
                      (doc) => Padding(
                        padding: EdgeInsets.only(bottom: SizeConfig.h(12)),
                        child: _DocumentCard(
                          document: doc,
                          onUploadTap: () => _pickAndUpload(context, ref, doc),
                        ),
                      ),
                    ),
                    SizeConfig.v(8),
                    const _DocumentsHintBox(),
                    SizeConfig.v(24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    ProviderDocument doc,
  ) async {
    final picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.radius(20)),
        ),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: SizeConfig.padding(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: SizeConfig.h(12)),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Text(
                    'إرفاق ${doc.title}',
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(15),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(6),
                  Text(
                    'يمكنك رفع أكثر من صورة لنفس الوثيقة (مثال: وجه/ظهر)',
                    style: AppTextStyles.caption11.copyWith(
                      fontSize: SizeConfig.ts(11.5),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizeConfig.v(12),

                  // ✅ Camera: التقط أكثر من صورة
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: Text(
                      'التقاط صور بالكاميرا',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      final files =
                          await _captureMultipleFromCamera(context, picker);
                      if (files.isEmpty) return;

                      await _uploadFiles(context, ref, doc, files);
                    },
                  ),

                  // ✅ Gallery: اختر عدة صور
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: Text(
                      'اختيار عدة صور من المعرض / الملفات',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      final files = await _pickMultipleFromGallery(picker);
                      if (files.isEmpty) return;

                      await _uploadFiles(context, ref, doc, files);
                    },
                  ),

                  SizeConfig.v(8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ✅ كاميرا: صورة ثم يسأل إذا بدك تضيف كمان (وجه/ظهر)
  Future<List<File>> _captureMultipleFromCamera(
    BuildContext context,
    ImagePicker picker,
  ) async {
    final result = <File>[];

    while (true) {
      final xFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (xFile == null) break;

      result.add(File(xFile.path));

      final addMore = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (_) => AlertDialog(
              title: Text(
                'تم التقاط الصورة',
                style: AppTextStyles.body16.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              content: Text(
                'هل تريد إضافة صورة أخرى؟',
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'تم',
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'إضافة صورة',
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!addMore) break;
    }

    return result;
  }

  /// ✅ معرض: pickMultiImage (ولو مش مدعوم fallback لصورة واحدة)
  Future<List<File>> _pickMultipleFromGallery(ImagePicker picker) async {
    try {
      final list = await picker.pickMultiImage(imageQuality: 85);
      if (list.isNotEmpty) {
        return list.map((x) => File(x.path)).toList();
      }
    } catch (_) {
      // ignore and fallback
    }

    final one = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (one == null) return <File>[];
    return <File>[File(one.path)];
  }

  Future<void> _uploadFiles(
    BuildContext context,
    WidgetRef ref,
    ProviderDocument doc,
    List<File> files,
  ) async {
    final controller = ref.read(providerDocumentsControllerProvider.notifier);

    final error = await controller.uploadDocument(
      kind: doc.kind,
      files: files,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null ? 'تم رفع ${doc.title} بنجاح' : error,
          style: AppTextStyles.body14.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ===================== Widgets مساعدة =====================

class _DocumentCard extends StatelessWidget {
  final ProviderDocument document;
  final VoidCallback onUploadTap;

  const _DocumentCard({
    required this.document,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = document.isVerified
        ? AppColors.lightGreen
        : AppColors.borderLight.withValues(alpha: 0.8);

    final statusColor =
        document.isVerified ? AppColors.lightGreen : AppColors.textSecondary;

    final hasFiles = document.fileNames.isNotEmpty;

    final statusText = document.isVerified
        ? 'موثّقة'
        : (!hasFiles
            ? (document.isRequired ? 'مطلوبة' : 'اختيارية')
            : 'قيد المراجعة');

    final statusIcon =
        document.isVerified ? Icons.check_circle : Icons.lock_outline;

    final buttonLabel = !hasFiles ? 'رفع الوثائق' : 'تحديث الوثائق';

    final fileLine = !hasFiles
        ? 'لم يتم رفع أي ملف بعد'
        : (document.fileNames.length == 1
            ? document.fileNames.first
            : 'تم رفع ${document.fileNames.length} صور');

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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizeConfig.hSpace(6),
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          SizeConfig.v(10),

          SizedBox(
            height: SizeConfig.h(42),
            child: ElevatedButton(
              onPressed: document.isUploading ? null : onUploadTap,
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
                        const Icon(
                          Icons.upload_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsHintBox extends StatelessWidget {
  const _DocumentsHintBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'متطلبات الوثائق',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(6),
          _bullet('الصيغ المدعومة: PDF, JPG, PNG'),
          _bullet('يمكن رفع أكثر من صورة لنفس الوثيقة (وجه/ظهر)'),
          _bullet('جميع الوثائق تخضع للمراجعة والموافقة'),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.h(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: AppTextStyles.body14.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption11.copyWith(
                fontSize: SizeConfig.ts(11.5),
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
              ),
            ),
            SizeConfig.v(12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
