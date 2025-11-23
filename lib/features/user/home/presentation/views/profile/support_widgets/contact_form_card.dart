// lib/features/support/presentation/views/support_widgets/contact_form_card.dart
import 'dart:ui';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ContactFormCard extends StatefulWidget {
  final VoidCallback onSend;

  const ContactFormCard({super.key, required this.onSend});

  @override
  State<ContactFormCard> createState() => _ContactFormCardState();
}

class _ContactFormCardState extends State<ContactFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSend();
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: SizeConfig.padding(all: 28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5),),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أرسل لنا رسالة', style: TextStyle(fontSize: SizeConfig.ts(19), fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizeConfig.v(8),
                Text('املأ النموذج وسنرد عليك خلال 24 ساعة.', style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary)),
                SizeConfig.v(24),

                _buildField(_nameController, 'الاسم الكامل *', 'أحمد محمد'),
                SizeConfig.v(16),
                _buildField(_emailController, 'البريد الإلكتروني *', 'you@email.com', keyboardType: TextInputType.emailAddress),
                SizeConfig.v(16),
                _buildField(_phoneController, 'رقم الجوال (اختياري)', '+962 79XXXXXXX', keyboardType: TextInputType.phone, required: false),
                SizeConfig.v(16),
                _buildField(_messageController, 'الرسالة *', 'كيف يمكننا مساعدتك؟', maxLines: 6),

                SizeConfig.v(32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      padding: SizeConfig.padding(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 12,
                    ),
                    child: Text('إرسال الرسالة', style: TextStyle(fontSize: SizeConfig.ts(18), fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: SizeConfig.ts(14), fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        SizeConfig.v(8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            contentPadding: SizeConfig.padding(horizontal: 20, vertical: 18),
          ),
          validator: required ? (v) => v!.trim().isEmpty ? 'مطلوب' : null : null,
        ),
      ],
    );
  }
}