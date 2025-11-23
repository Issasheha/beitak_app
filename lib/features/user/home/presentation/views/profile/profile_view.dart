import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/viewmodels/profile_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/profile_action_item.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/profile_footer.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/support_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // ViewModel يمسك بيانات الملف الشخصي
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: _viewModel.fullName);
    final emailController = TextEditingController(text: _viewModel.email);
    final phoneController = TextEditingController(text: _viewModel.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.edit, color: AppColors.lightGreen),
            const SizedBox(width: 12),
            Text(
              'تعديل المعلومات الشخصية',
              style: TextStyle(
                fontSize: SizeConfig.ts(18),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(
                nameController,
                'الاسم الكامل',
                Icons.person,
              ),
              SizeConfig.v(16),
              _buildEditField(
                emailController,
                'البريد الإلكتروني',
                Icons.email_outlined,
              ),
              SizeConfig.v(16),
              _buildEditField(
                phoneController,
                'رقم الجوال',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _viewModel.updateProfile(
                  fullName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ التغييرات بنجاح!'),
                  backgroundColor: AppColors.lightGreen,
                ),
              );
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('حفظ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.lightGreen),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: SizeConfig.padding(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'الملف الشخصي',
            style: TextStyle(
              fontSize: SizeConfig.ts(22),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: SizeConfig.padding(all: 20),
            child: Column(
              children: [
                // معلومات شخصية مع زر تعديل
                _buildGlassCard(
                  title: 'المعلومات الشخصية',
                  trailing: GestureDetector(
                    onTap: _showEditDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          color: AppColors.lightGreen,
                          size: SizeConfig.w(20),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'تعديل',
                          style: TextStyle(
                            color: AppColors.lightGreen,
                            fontSize: SizeConfig.ts(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'الاسم الكامل',
                        _viewModel.fullName,
                        Icons.person_outline,
                      ),
                      SizeConfig.v(16),
                      _buildInfoRow(
                        'البريد الإلكتروني',
                        _viewModel.email,
                        Icons.email_outlined,
                      ),
                      SizeConfig.v(16),
                      _buildInfoRow(
                        'رقم الجوال',
                        _viewModel.phone,
                        Icons.phone_outlined,
                      ),
                      SizeConfig.v(20),
                      ProfileActionItem(
                        label: 'تغيير كلمة المرور',
                        icon: Icons.lock_outline,
                        onTap: () => context.push(AppRoutes.changePassword),
                      ),
                    ],
                  ),
                ),

                SizeConfig.v(24),

                // الدعم والمساعدة
                _buildGlassCard(
                  title: 'الدعم والمساعدة',
                  child: const SupportSection(),
                ),

                SizeConfig.v(40),

                const ProfileFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.lightGreen,
          size: SizeConfig.w(24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
              ),
            ),
            SizeConfig.v(4),
            Text(
              value,
              style: TextStyle(
                fontSize: SizeConfig.ts(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: SizeConfig.padding(all: 20),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.4),
            ),
            boxShadow: [AppColors.primaryShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (trailing != null) trailing,
                ],
              ),
              SizeConfig.v(20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
