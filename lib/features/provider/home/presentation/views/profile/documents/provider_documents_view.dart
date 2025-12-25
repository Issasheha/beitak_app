// lib/features/provider/home/presentation/views/profile/documents/provider_documents_view.dart

import 'dart:io';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/viewmodels/provider_documents_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/viewmodels/provider_documents_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/widgets/document_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/widgets/document_file_picker.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/widgets/documents_error_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/widgets/documents_hint_box.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/documents/widgets/provider_doc_viewer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProviderDocumentsView extends ConsumerWidget {
  const ProviderDocumentsView({super.key});

  static const int _maxFilesPerDoc = DocumentFilePicker.maxFilesPerDoc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final asyncState = ref.watch(providerDocumentsControllerProvider);
    final controller = ref.read(providerDocumentsControllerProvider.notifier);

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
          error: (err, _) => DocumentsErrorView(
            message: err.toString(),
            onRetry: () => controller.refresh(),
          ),
          data: (state) {
            return RefreshIndicator(
              onRefresh: () => controller.refresh(),
              child: SafeArea(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                  itemCount: state.docs.length + 1, // + hint box
                  separatorBuilder: (_, __) => SizedBox(height: SizeConfig.h(12)),
                  itemBuilder: (ctx, index) {
                    // آخر عنصر: hint box
                    if (index == state.docs.length) {
                      return Column(
                        children: [
                          SizedBox(height: SizeConfig.h(8)),
                          const DocumentsHintBox(),
                          SizedBox(height: SizeConfig.h(24)),
                        ],
                      );
                    }

                    final doc = state.docs[index];

                    return DocumentCard(
                      document: doc,
                      onUploadTap: doc.isUploading
                          ? null
                          : () => _pickAndUpload(context, ref, doc),
                      onOpenTap: doc.fileNames.isEmpty
                          ? null
                          : () => _openDoc(context, doc),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===================== Open file =====================

  Future<void> _openDoc(
    BuildContext context,
    ProviderDocument doc,
  ) async {
    if (doc.fileNames.isEmpty) return;

    // لو ملف واحد
    if (doc.fileNames.length == 1) {
      await ProviderDocViewer.open(
        context: context,
        fileName: doc.fileNames.first,
        title: doc.title,
      );
      return;
    }

    // لو أكثر من ملف: اختار
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.radius(20)),
        ),
      ),
      builder: (_) {
        final files = doc.fileNames.take(_maxFilesPerDoc).toList();

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
                    'اختر ملف لعرضه',
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(14.5),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(10),
                  ...files.asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final name = e.value;

                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file_outlined),
                      title: Text(
                        'ملف $idx',
                        style: AppTextStyles.body14.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption11.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await ProviderDocViewer.open(
                          context: context,
                          fileName: name,
                          title: doc.title,
                        );
                      },
                    );
                  }),
                  SizeConfig.v(8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===================== Upload flow =====================

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
                    'يمكنك رفع ملفين كحد أقصى لنفس الوثيقة (PDF أو صور)',
                    style: AppTextStyles.caption11.copyWith(
                      fontSize: SizeConfig.ts(11.5),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizeConfig.v(12),

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
                          await DocumentFilePicker.captureUpToTwoFromCamera(
                        picker,
                        askAddMore: () => _askAddMoreImage(context),
                      );
                      if (files.isEmpty) return;

                      await _uploadFiles(context, ref, doc, files);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: Text(
                      'اختيار صور من المعرض (حتى 2)',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      final files =
                          await DocumentFilePicker.pickUpToTwoFromGallery(
                        picker,
                      );
                      if (files.isEmpty) return;

                      await _uploadFiles(context, ref, doc, files);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    title: Text(
                      'اختيار ملفات (PDF / صور) حتى 2',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      final files = await DocumentFilePicker.pickWithFilePicker();
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

  Future<bool> _askAddMoreImage(BuildContext context) async {
    final res = await showDialog<bool>(
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
              'هل تريد إضافة صورة أخرى؟ (الحد الأقصى: 2)',
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

    return res;
  }

  Future<void> _uploadFiles(
    BuildContext context,
    WidgetRef ref,
    ProviderDocument doc,
    List<File> files,
  ) async {
    final trimmed = files.take(_maxFilesPerDoc).toList();

    final validation = await DocumentFilePicker.validateFiles(trimmed);
    if (validation != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            validation,
            style: AppTextStyles.body14.copyWith(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final controller = ref.read(providerDocumentsControllerProvider.notifier);

    final error = await controller.uploadDocument(
      kind: doc.kind,
      files: trimmed,
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
