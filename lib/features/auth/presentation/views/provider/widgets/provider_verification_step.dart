// lib/features/auth/presentation/views/provider/widgets/provider_verification_step.dart

import 'dart:io';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProviderVerificationStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  final ValueChanged<String?> onIdSelected;
  final ValueChanged<String?> onLicenseSelected;
  final ValueChanged<String?> onCertificateSelected;

  const ProviderVerificationStep({
    super.key,
    required this.formKey,
    required this.onIdSelected,
    required this.onLicenseSelected,
    required this.onCertificateSelected,
  });

  @override
  State<ProviderVerificationStep> createState() =>
      _ProviderVerificationStepState();
}

class _ProviderVerificationStepState extends State<ProviderVerificationStep> {
  bool _idUploaded = false;
  bool _licenseUploaded = false;
  bool _certificateUploaded = false;

  String? _idFileName;
  String? _licenseFileName;
  String? _certificateFileName;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وثائق التحقق',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(17),
              fontWeight: FontWeight.w700, // كان bold
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            'يرجى إرفاق الوثائق المطلوبة للتحقق من هويتك.',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizeConfig.v(16),
          _buildUploadTile(
            title: 'صورة الهوية الشخصية *',
            subtitle: 'أرفق صورة أو ملف PDF / Word للهوية الوطنية.',
            uploaded: _idUploaded,
            fileName: _idFileName,
            onTap: () => _showPickerSheet(type: _DocType.id),
          ),
          SizeConfig.v(12),
          _buildUploadTile(
            title: 'صورة الترخيص المهني *',
            subtitle: 'رخصة مزاولة المهنة أو السجل التجاري.',
            uploaded: _licenseUploaded,
            fileName: _licenseFileName,
            onTap: () => _showPickerSheet(type: _DocType.license),
          ),
          SizeConfig.v(12),
          _buildUploadTile(
            title: 'صورة شهادة عدم المحكومية *',
            subtitle: 'شهادة جنائية حديثة (صورة أو ملف).',
            uploaded: _certificateUploaded,
            fileName: _certificateFileName,
            onTap: () => _showPickerSheet(type: _DocType.certificate),
          ),
          SizeConfig.v(12),
          TextFormField(
            validator: (_) {
              if (!_idUploaded || !_licenseUploaded || !_certificateUploaded) {
                return 'يجب إرفاق جميع وثائق التحقق المطلوبة';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTile({
    required String title,
    required String subtitle,
    required bool uploaded,
    required VoidCallback onTap,
    String? fileName,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
      child: Container(
        padding: EdgeInsets.all(SizeConfig.h(10)),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
          border: Border.all(
            color: uploaded ? AppColors.primaryGreen : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              uploaded ? Icons.check_circle : Icons.upload_file,
              color: uploaded ? AppColors.primaryGreen : AppColors.textSecondary,
              size: SizeConfig.w(22),
            ),
            SizeConfig.hSpace(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(14),
                      fontWeight: FontWeight.w600, // كان w600
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(2),
                  Text(
                    fileName ?? subtitle,
                    style: AppTextStyles.label12.copyWith(
                      fontSize: SizeConfig.ts(12),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizeConfig.hSpace(8),
            Text(
              uploaded ? 'تم الإرفاق' : 'إرفاق',
              style: AppTextStyles.label12.copyWith(
                fontSize: SizeConfig.ts(12),
                color:
                    uploaded ? AppColors.primaryGreen : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPickerSheet({required _DocType type}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.radius(20)),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: SizeConfig.padding(all: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر طريقة الإرفاق',
                  style: AppTextStyles.body16.copyWith(
                    fontSize: SizeConfig.ts(15),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(12),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(
                    'التقاط صورة بالكاميرا',
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(type: type, source: ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(
                    'اختيار صورة من المعرض',
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(type: type, source: ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    'رفع ملف PDF / Word',
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickDocument(type: type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage({
    required _DocType type,
    required ImageSource source,
  }) async {
    final XFile? picked =
        await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final file = File(picked.path);
    if (!await file.exists()) return;

    _setFileForType(type, picked.path, picked.name);
  }

  Future<void> _pickDocument({required _DocType type}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final path = file.path;
    if (path == null) return;

    _setFileForType(type, path, file.name);
  }

  void _setFileForType(_DocType type, String path, String fileName) {
    setState(() {
      switch (type) {
        case _DocType.id:
          _idUploaded = true;
          _idFileName = fileName;
          widget.onIdSelected(path);
          break;
        case _DocType.license:
          _licenseUploaded = true;
          _licenseFileName = fileName;
          widget.onLicenseSelected(path);
          break;
        case _DocType.certificate:
          _certificateUploaded = true;
          _certificateFileName = fileName;
          widget.onCertificateSelected(path);
          break;
      }
    });
  }
}

enum _DocType { id, license, certificate }
