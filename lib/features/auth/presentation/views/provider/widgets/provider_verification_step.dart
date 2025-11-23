import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ProviderVerificationStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const ProviderVerificationStep({super.key, required this.formKey});

  @override
  State<ProviderVerificationStep> createState() =>
      _ProviderVerificationStepState();
}

class _ProviderVerificationStepState extends State<ProviderVerificationStep> {
  bool _idUploaded = false;
  bool _licenseUploaded = false;
  bool _certificateUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وثائق التحقق',
            style: TextStyle(
              fontSize: SizeConfig.ts(17),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            'يرجى إرفاق الوثائق المطلوبة للتحقق من هويتك.',
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
            ),
          ),
          SizeConfig.v(16),
          _buildUploadTile(
            title: 'صورة الهوية الشخصية *',
            subtitle: 'أرفق صورة واضحة للهوية الوطنية.',
            uploaded: _idUploaded,
            onTap: () {
              // TODO: ربط مع FilePicker / ImagePicker
              setState(() => _idUploaded = true);
            },
          ),
          SizeConfig.v(12),
          _buildUploadTile(
            title: 'صورة الترخيص المهني *',
            subtitle: 'رخصة مزاولة المهنة أو السجل التجاري.',
            uploaded: _licenseUploaded,
            onTap: () {
              setState(() => _licenseUploaded = true);
            },
          ),
          SizeConfig.v(12),
          _buildUploadTile(
            title: 'صورة شهادة عدم المحكومية *',
            subtitle: 'شهادة جنائية حديثة.',
            uploaded: _certificateUploaded,
            onTap: () {
              setState(() => _certificateUploaded = true);
            },
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
              color:
                  uploaded ? AppColors.primaryGreen : AppColors.textSecondary,
              size: SizeConfig.w(22),
            ),
            SizeConfig.hSpace(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizeConfig.hSpace(8),
            Text(
              uploaded ? 'تم الإرفاق' : 'إرفاق',
              style: TextStyle(
                fontSize: SizeConfig.ts(12),
                color:
                    uploaded ? AppColors.primaryGreen : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
