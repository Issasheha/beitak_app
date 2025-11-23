import 'dart:io';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/viewmodels/request_service_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/widgets/date_selection_section.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/widgets/image_upload_section.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/widgets/request_text_field.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/widgets/share_phone_dialog.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class RequestServiceView extends StatefulWidget {
  const RequestServiceView({super.key});

  @override
  State<RequestServiceView> createState() => _RequestServiceViewState();
}

class _RequestServiceViewState extends State<RequestServiceView> {
  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();

  late final RequestServiceViewModel _viewModel;

  File? _selectedImage;
  DateTime? _selectedDate;
  String _selectedDateLabel = 'اليوم';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _viewModel = RequestServiceViewModel();

    // قيمة ابتدائية منطقية
    _selectedDate = DateTime.now();
    _selectedDateLabel = 'اليوم';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _selectDateOption(String label) {
    setState(() {
      _selectedDateLabel = label;
      switch (label) {
        case 'اليوم':
          _selectedDate = DateTime.now();
          break;
        case 'غدًا':
          _selectedDate = DateTime.now().add(const Duration(days: 1));
          break;
        case 'بعد غد':
          _selectedDate = DateTime.now().add(const Duration(days: 2));
          break;
      }
    });
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.lightGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDateLabel = 'تاريخ مخصص';
      });
    }
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;

    final hasPhone = _phoneController.text.trim().isNotEmpty;

    if (hasPhone) {
      // نعرض Dialog مشاركة رقم الهاتف أولاً
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SharePhoneDialog(
          onShare: () {
            Navigator.of(context).pop(); // إغلاق Dialog المشاركة
            _doSubmit(sharePhone: true);
          },
          onNotShare: () {
            Navigator.of(context).pop();
            _doSubmit(sharePhone: false);
          },
        ),
      );
    } else {
      _doSubmit(sharePhone: false);
    }
  }

  Future<void> _doSubmit({required bool sharePhone}) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // محاولة تحويل الميزانية إلى double
    double? expectedPrice;
    final priceText = _priceController.text.trim();
    if (priceText.isNotEmpty) {
      final numeric =
          priceText.replaceAll(RegExp(r'[^0-9.]'), '');
      expectedPrice = double.tryParse(numeric);
    }

    final success = await _viewModel.submitRequest(
      categoryName: _categoryController.text.trim(),
      serviceName: _serviceNameController.text.trim(),
      description: _descriptionController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      preferredDate: _selectedDate,
      expectedPrice: expectedPrice,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      sharePhone: sharePhone,
      imageFile: _selectedImage,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      _showSuccessDialog();
    } else {
      final message = _viewModel.lastErrorMessage ??
          'تعذر إرسال الطلب حالياً، حاول مرة أخرى.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SuccessDialog(),
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
          title: Text(
            'طلب خدمة جديدة',
            style: TextStyle(
              fontSize: SizeConfig.ts(20),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: SizeConfig.padding(all: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DateSelectionSection(
                  selectedDate: _selectedDate,
                  selectedDateLabel: _selectedDateLabel,
                  onToday: () => _selectDateOption('اليوم'),
                  onTomorrow: () => _selectDateOption('غدًا'),
                  onDayAfter: () => _selectDateOption('بعد غد'),
                  onCustom: _pickCustomDate,
                ),
                SizeConfig.v(20),
                RequestTextField(
                  controller: _categoryController,
                  label: 'اسم الفئة *',
                  hint: 'مثال: تنظيف، صيانة...',
                ),
                SizeConfig.v(16),
                RequestTextField(
                  controller: _serviceNameController,
                  label: 'اسم الخدمة *',
                  hint: 'مثال: تنظيف منزل كامل',
                ),
                SizeConfig.v(16),
                RequestTextField(
                  controller: _descriptionController,
                  label: 'الوصف *',
                  hint: 'وصف مفصل...',
                  maxLines: 5,
                ),
                SizeConfig.v(16),
                Row(
                  children: [
                    Expanded(
                      child: RequestTextField(
                        controller: _cityController,
                        label: 'المدينة *',
                        hint: 'عمان',
                      ),
                    ),
                    SizeConfig.hSpace(16),
                    Expanded(
                      child: RequestTextField(
                        controller: _addressController,
                        label: 'العنوان التفصيلي *',
                        hint: 'عبدون، شارع...',
                      ),
                    ),
                  ],
                ),
                SizeConfig.v(16),
                RequestTextField(
                  controller: _priceController,
                  label: 'الميزانية المتوقعة',
                  hint: 'مثال: 50 دينار',
                  keyboardType: TextInputType.number,
                  required: false,
                ),
                SizeConfig.v(20),
                Text(
                  'معلومات التواصل (اختياري)',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizeConfig.v(8),
                RequestTextField(
                  controller: _phoneController,
                  label: 'رقم الجوال',
                  hint: '+962 79XXXXXXX',
                  required: false,
                ),
                SizeConfig.v(20),
                ImageUploadSection(
                  selectedImage: _selectedImage,
                  onPickImage: _pickImage,
                ),
                SizeConfig.v(40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => context.go(AppRoutes.home),
                        style: OutlinedButton.styleFrom(
                          padding: SizeConfig.padding(vertical: 18),
                          side: const BorderSide(
                            color: AppColors.buttonBackground,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: SizeConfig.ts(16),
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizeConfig.hSpace(16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          padding: SizeConfig.padding(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'إرسال الطلب',
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(16),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                SizeConfig.v(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
