import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/auth/presentation/views/provider/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class ProviderPersonalInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const ProviderPersonalInfoStep({super.key, required this.formKey});

  @override
  State<ProviderPersonalInfoStep> createState() =>
      _ProviderPersonalInfoStepState();
}

class _ProviderPersonalInfoStepState extends State<ProviderPersonalInfoStep> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final _passwordController = TextEditingController();

  String? _selectedCity;
  String? _selectedArea;

  final _cities = const [
    'عمان',
    'إربد',
    'الزرقاء',
    'العقبة',
    'مادبا',
    'السلط',
    'الكرك',
    'المفرق',
    'جرش',
    'عجلون',
    'الطفيلة',
  ];

  final Map<String, List<String>> _areasByCity = const {
    'عمان': [
      'عبدون',
      'البلدة القديمة',
      'جبل الحسين',
      'جبل عمان',
      'الجبيهة',
      'خلدا',
      'شارع الرينبو',
      'الشميساني',
      'الشفا',
      'تلاع العلي',
    ],
    'الزرقاء': [
      'وسط المدينة',
      'الهاشمي',
      'الزرقاء الجديدة',
      'مخيم الزرقاء',
      'الرصيفة',
    ],
    'إربد': [
      'شارع الحسين',
      'وسط المدينة',
      'شارع البترا',
      'شارع الجامعة',
    ],
  };

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الشخصية',
            style: TextStyle(
              fontSize: SizeConfig.ts(17),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(4),
          Text(
            'لنبدأ بمعلوماتك الأساسية.',
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
            ),
          ),
          SizeConfig.v(14),

          Row(
            children: [
           const    Expanded(
                child:  AuthTextField(
                  label: 'الاسم الأول *',
                  hint: 'أحمد',
                  icon: Icons.person_outline,
                  validator: _requiredValidator,
                  onDarkBackground: false,
                ),
              ),
              SizeConfig.hSpace(10),
             const  Expanded(
                child: AuthTextField(
                  label: 'اسم العائلة *',
                  hint: 'محمد',
                  icon: Icons.person_outline,
                  validator: _requiredValidator,
                  onDarkBackground: false,
                ),
              ),
            ],
          ),
          SizeConfig.v(14),

          const AuthTextField(
            label: 'رقم الجوال *',
            hint: '077 123 4567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _phoneValidator,
            onDarkBackground: false,
          ),
          SizeConfig.v(14),

          AuthTextField(
            label: 'البريد الإلكتروني (اختياري)',
            hint: 'ahmad@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(value)) return 'البريد الإلكتروني غير صالح';
              return null;
            },
            onDarkBackground: false,
          ),
          SizeConfig.v(14),

          AuthTextField(
            label: 'كلمة المرور *',
            hint: 'أدنى 8 أحرف',
            icon: Icons.lock_outline,
            obscureText: _obscurePass,
            controller: _passwordController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
              if (value.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
              return null;
            },
            onDarkBackground: false,
          ),
          SizeConfig.v(14),

          AuthTextField(
            label: 'تأكيد كلمة المرور *',
            hint: 'أعد كتابة كلمة المرور',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'تأكيد كلمة المرور مطلوب';
              }
              if (value != _passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
            onDarkBackground: false,
          ),
          SizeConfig.v(14),

          _buildDropdown(
            label: 'المحافظة *',
            hint: 'اختر المحافظة',
            value: _selectedCity,
            items: _cities,
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _selectedArea = null;
              });
            },
            validator: (v) => v == null ? 'المحافظة مطلوبة' : null,
          ),
          SizeConfig.v(14),

          _buildDropdown(
            label: 'المنطقة *',
            hint: 'اختر المنطقة',
            value: _selectedArea,
            items: _areasByCity[_selectedCity] ?? const [],
            onChanged: (value) => setState(() => _selectedArea = value),
            validator: (v) => v == null ? 'المنطقة مطلوبة' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizeConfig.v(6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.h(10),
              horizontal: SizeConfig.w(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  static String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }

  static String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'رقم الجوال مطلوب';
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final regex = RegExp(r'^07(7|8|9)\d{7}$');
    if (!regex.hasMatch(cleaned)) {
      return 'يجب أن يبدأ بـ 077 أو 078 أو 079 ويتكوّن من 10 أرقام';
    }
    return null;
  }
}
