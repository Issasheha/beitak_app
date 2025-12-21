import 'dart:io';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProviderVerificationStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  // ✅ initial state from parent
  final String? idPath;
  final String? licensePath;
  final String? policePath;

  final String? idFileName;
  final String? licenseFileName;
  final String? policeFileName;

  final ValueChanged<String?> onIdSelected;
  final ValueChanged<String?> onLicenseSelected;
  final ValueChanged<String?> onPoliceSelected;

  const ProviderVerificationStep({
    super.key,
    required this.formKey,
    required this.onIdSelected,
    required this.onLicenseSelected,
    required this.onPoliceSelected,
    this.idPath,
    this.licensePath,
    this.policePath,
    this.idFileName,
    this.licenseFileName,
    this.policeFileName,
  });

  @override
  State<ProviderVerificationStep> createState() => _ProviderVerificationStepState();
}

class _ProviderVerificationStepState extends State<ProviderVerificationStep> {
  static const int _maxBytes = 5 * 1024 * 1024; // 5MB
  static const _allowedExt = ['pdf', 'jpg', 'jpeg', 'png'];

  late bool _idUploaded;
  late bool _licenseUploaded;
  late bool _policeUploaded;

  String? _idFileName;
  String? _licenseFileName;
  String? _policeFileName;

  String? _idPath;
  String? _licensePath;
  String? _policePath;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _idPath = widget.idPath;
    _licensePath = widget.licensePath;
    _policePath = widget.policePath;

    _idFileName = widget.idFileName;
    _licenseFileName = widget.licenseFileName;
    _policeFileName = widget.policeFileName;

    _idUploaded = (_idPath != null && _idPath!.isNotEmpty);
    _licenseUploaded = (_licensePath != null && _licensePath!.isNotEmpty);
    _policeUploaded = (_policePath != null && _policePath!.isNotEmpty);
  }

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
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            'يرجى إرفاق الوثائق المطلوبة للتحقق من هويتك.\n'
            'ملاحظة: إذا كانت الهوية وجهين يمكنك رفعها كملف PDF واحد.',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizeConfig.v(16),

          _buildUploadTile(
            title: 'صورة الهوية الشخصية أو الإقامة *',
            subtitle: 'PNG / JPG / PDF (حد أقصى 5MB).',
            uploaded: _idUploaded,
            fileName: _idFileName,
            onTap: () => _onTileTap(_DocType.id),
          ),
          SizeConfig.v(12),

          _buildUploadTile(
            title: 'صورة الترخيص المهني *',
            subtitle: 'PNG / JPG / PDF (حد أقصى 5MB).',
            uploaded: _licenseUploaded,
            fileName: _licenseFileName,
            onTap: () => _onTileTap(_DocType.license),
          ),
          SizeConfig.v(12),

          _buildUploadTile(
            title: 'صورة شهادة عدم المحكومية *',
            subtitle: 'PNG / JPG / PDF (حد أقصى 5MB).',
            uploaded: _policeUploaded,
            fileName: _policeFileName,
            onTap: () => _onTileTap(_DocType.police),
          ),
          SizeConfig.v(12),

          TextFormField(
            validator: (_) {
              if (!_idUploaded || !_licenseUploaded || !_policeUploaded) {
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

  Future<void> _onTileTap(_DocType type) async {
    final uploaded = _isUploaded(type);

    if (!uploaded) {
      await _showPickerSheet(type: type);
      return;
    }

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
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(
                    'استبدال الملف',
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _showPickerSheet(type: type);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(
                    'إزالة الملف',
                    style: AppTextStyles.body14.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeFile(type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isUploaded(_DocType type) {
    switch (type) {
      case _DocType.id:
        return _idUploaded;
      case _DocType.license:
        return _licenseUploaded;
      case _DocType.police:
        return _policeUploaded;
    }
  }

  void _removeFile(_DocType type) {
    setState(() {
      switch (type) {
        case _DocType.id:
          _idUploaded = false;
          _idFileName = null;
          _idPath = null;
          widget.onIdSelected(null);
          break;
        case _DocType.license:
          _licenseUploaded = false;
          _licenseFileName = null;
          _licensePath = null;
          widget.onLicenseSelected(null);
          break;
        case _DocType.police:
          _policeUploaded = false;
          _policeFileName = null;
          _policePath = null;
          widget.onPoliceSelected(null);
          break;
      }
    });
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
                      fontWeight: FontWeight.w600,
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
                color: uploaded ? AppColors.primaryGreen : AppColors.textSecondary,
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
                    'رفع ملف PDF',
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
    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;

    final file = File(picked.path);
    if (!await file.exists()) return;

    final ok = await _validateFile(file.path, name: picked.name);
    if (!ok) return;

    _setFileForType(type, picked.path, picked.name);
  }

  Future<void> _pickDocument({required _DocType type}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExt,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final f = result.files.single;
    final path = f.path;
    if (path == null) return;

    final ok = await _validateFile(path, name: f.name);
    if (!ok) return;

    _setFileForType(type, path, f.name);
  }

  Future<bool> _validateFile(String path, {String? name}) async {
    final file = File(path);
    final fileName = name ?? path.split(Platform.pathSeparator).last;

    final ext = fileName.split('.').last.toLowerCase();
    if (!_allowedExt.contains(ext)) {
      _showError('نوع الملف غير مدعوم. المسموح: PDF / JPG / PNG');
      return false;
    }

    final bytes = await file.length();
    if (bytes > _maxBytes) {
      _showError('حجم الملف كبير. الحد الأقصى 5MB');
      return false;
    }

    return true;
  }

  void _setFileForType(_DocType type, String path, String fileName) {
    setState(() {
      switch (type) {
        case _DocType.id:
          _idUploaded = true;
          _idFileName = fileName;
          _idPath = path;
          widget.onIdSelected(path);
          break;
        case _DocType.license:
          _licenseUploaded = true;
          _licenseFileName = fileName;
          _licensePath = path;
          widget.onLicenseSelected(path);
          break;
        case _DocType.police:
          _policeUploaded = true;
          _policeFileName = fileName;
          _policePath = path;
          widget.onPoliceSelected(path);
          break;
      }
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.body14),
        backgroundColor: Colors.red,
      ),
    );
  }
}

enum _DocType { id, license, police }
