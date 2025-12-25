import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'viewmodels/request_service_providers.dart';
import 'widgets/area_dropdown_field.dart';
import 'widgets/city_dropdown_field.dart';
import 'widgets/date_selection_section.dart';
import 'widgets/image_upload_section.dart';
import 'widgets/request_text_field.dart';
import 'widgets/service_type_field.dart';
import 'widgets/time_selection_field.dart';
import 'models/service_type_option.dart';

class RequestServiceView extends ConsumerStatefulWidget {
  const RequestServiceView({super.key});

  @override
  ConsumerState<RequestServiceView> createState() => _RequestServiceViewState();
}

class _RequestServiceViewState extends ConsumerState<RequestServiceView> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  // ---------- Validators helpers ----------

  bool _containsHtml(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('<') || lower.contains('>')) return true;
    if (lower.contains('script')) return true;
    return false;
  }

  bool _containsEmoji(String s) {
    // تغطية جيدة لمعظم الإيموجي (مش 100% لكن كافي للـ QA)
    final r = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
      unicode: true,
    );
    return r.hasMatch(s);
  }

  String? _validateDescription(String? v) {
    final s = (v ?? '').trim();

    if (s.isEmpty) return 'الوصف مطلوب (من 10 إلى 500 حرف)';
    if (s.length < 10) return 'الوصف قصير جدًا (الحد الأدنى 10 أحرف)';
    if (s.length > 500) return 'الوصف طويل جدًا (الحد الأقصى 500 حرف)';
    if (_containsHtml(s)) return 'الوصف لا يسمح بـ HTML أو scripts';
    if (_containsEmoji(s)) return 'الوصف لا يسمح بالإيموجي';
    return null;
  }

  String? _validateBudget(String? v) {
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return null;

    // إزالة المسافات/الفواصل
    final cleaned = raw.replaceAll(' ', '').replaceAll(',', '');

    final numVal = int.tryParse(cleaned);
    if (numVal == null) return 'يرجى إدخال رقم ميزانية صحيح';

    if (numVal < 10) return 'الميزانية يجب أن تكون على الأقل 10 د.أ';
    if (numVal > 10000) return 'الميزانية يجب أن لا تتجاوز 10000 د.أ';

    return null;
  }

  TextStyle _errorStyle() => TextStyle(
        fontSize: SizeConfig.ts(12),
        color: Colors.red.shade700,
        fontWeight: FontWeight.w800,
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(requestServiceControllerProvider.notifier).bootstrap(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestServiceControllerProvider);
    final controller = ref.read(requestServiceControllerProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'طلب خدمة',
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: SizeConfig.ts(16),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: state.sessionLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: SizeConfig.padding(horizontal: 16, vertical: 16),
                  child: Container(
                    padding: SizeConfig.padding(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب خدمة جديدة',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: SizeConfig.ts(15),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(4)),
                          Text(
                            'املأ البيانات التالية لإرسال طلبك',
                            style: AppTextStyles.helper.copyWith(
                              fontSize: SizeConfig.ts(12),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          if (state.showNameField) ...[
                            RequestTextField(
                              controller: _nameCtrl,
                              label: 'الاسم *',
                              hint: 'مثال: أحمد محمد',
                              validator: (v) {
                                final s = (v ?? '').trim();
                                if (s.isEmpty) return 'الاسم مطلوب';
                                if (s.length < 3) return 'الاسم قصير جدًا';
                                return null;
                              },
                            ),
                            SizedBox(height: SizeConfig.h(12)),
                          ],

                          if (state.showPhoneField) ...[
                            RequestTextField(
                              controller: _phoneCtrl,
                              label: 'رقم الجوال *',
                              hint: '07xxxxxxxx',
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                final s = (v ?? '').trim();
                                if (s.isEmpty) return 'رقم الجوال مطلوب';
                                if (s.length < 9) return 'رقم الجوال غير صالح';
                                return null;
                              },
                            ),
                            SizedBox(height: SizeConfig.h(14)),
                          ],

                          // ✅ Service type: error تحت الحقل
                          FormField<ServiceTypeOption>(
                            initialValue: state.selectedServiceType,
                            validator: (_) =>
                                (state.selectedServiceType == null) ? 'نوع الخدمة مطلوب' : null,
                            builder: (field) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ServiceTypeField(
                                    selected: state.selectedServiceType,
                                    onSelected: (opt) {
                                      controller.selectServiceType(opt);
                                      field.didChange(opt);
                                    },
                                  ),
                                  if (field.hasError) ...[
                                    SizedBox(height: SizeConfig.h(8)),
                                    Text(field.errorText ?? '', style: _errorStyle()),
                                  ],
                                ],
                              );
                            },
                          ),

                          if (state.categoryError != null) ...[
                            SizedBox(height: SizeConfig.h(8)),
                            Text(
                              'تنبيه: تعذر تحميل الفئات من السيرفر - ${state.categoryError!}',
                              style: AppTextStyles.caption11.copyWith(
                                fontSize: SizeConfig.ts(11),
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          SizedBox(height: SizeConfig.h(14)),

                          // ✅ Description: min/max + منع طول زائد
                          RequestTextField(
                            controller: _descCtrl,
                            label: 'الوصف / الملاحظات *',
                            hint: 'اكتب تفاصيل ما تحتاجه...',
                            maxLines: 4,
                            maxLength: 500,
                            validator: _validateDescription,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(500),
                            ],
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          // ✅ Budget: digits only + range
                          RequestTextField(
                            controller: _budgetCtrl,
                            label: 'الميزانية (اختياري)',
                            hint: 'مثال: 50',
                            keyboardType: TextInputType.number,
                            validator: _validateBudget,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(5), // 10000 max
                            ],
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          // ✅ Date: error تحت القسم (بدون snack)
                          FormField<int>(
                            initialValue: 0,
                            validator: (_) {
                              if (state.dateType == ServiceDateType.other && state.otherDate == null) {
                                return 'التاريخ مطلوب';
                              }
                              return null;
                            },
                            builder: (field) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DateSelectionSection(
                                    selectedType: state.dateType,
                                    selectedOtherDate: state.otherDate,
                                    onTypeSelected: (t) {
                                      controller.setDateType(t);
                                      field.didChange(field.value);
                                    },
                                    onOtherPicked: (d) {
                                      controller.setOtherDate(d);
                                      field.didChange(field.value);
                                    },
                                  ),
                                  if (field.hasError) ...[
                                    SizedBox(height: SizeConfig.h(8)),
                                    Text(field.errorText ?? '', style: _errorStyle()),
                                  ],
                                ],
                              );
                            },
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          // ✅ Time: error تحت الحقل (بدون snack) + AM/PM display
                          FormField<String>(
                            initialValue: state.selectedHour,
                            validator: (_) => (state.selectedHour == null) ? 'الوقت مطلوب' : null,
                            builder: (field) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TimeSelectionField(
                                    selectedHour: state.selectedHour,
                                    onPickHour: (v) {
                                      controller.setSelectedHour(v);
                                      field.didChange(v);
                                    },
                                  ),
                                  if (field.hasError) ...[
                                    SizedBox(height: SizeConfig.h(8)),
                                    Text(field.errorText ?? '', style: _errorStyle()),
                                  ],
                                ],
                              );
                            },
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          // ✅ City/Area صاروا validators تحت الحقول
                          CityDropdownField(
                            loading: state.citiesLoading,
                            error: state.citiesError,
                            cities: state.cities,
                            selected: state.selectedCity,
                            onChanged: controller.onCityChanged,
                            onRetry: controller.loadCities,
                          ),
                          SizedBox(height: SizeConfig.h(12)),

                          AreaDropdownField(
                            enabled: state.selectedCity != null,
                            loading: state.areasLoading,
                            error: state.areasError,
                            areas: state.areas,
                            selected: state.selectedArea,
                            onChanged: controller.selectArea,
                            onRetry: () {
                              final c = state.selectedCity;
                              if (c != null) {
                                controller.loadAreasForCity(c);
                              }
                            },
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          ImageUploadSection(
                            files: state.files,
                            onPick: () => controller.pickImages(context),
                            onRemoveAt: controller.removeFileAt,
                          ),
                          SizedBox(height: SizeConfig.h(18)),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.submitting
                                  ? null
                                  : () => controller.submit(
                                        context: context,
                                        formKey: _formKey,
                                        nameCtrl: _nameCtrl,
                                        phoneCtrl: _phoneCtrl,
                                        descCtrl: _descCtrl,
                                        budgetCtrl: _budgetCtrl,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGreen,
                                padding: SizeConfig.padding(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                state.submitting ? 'جارٍ الإرسال...' : 'إرسال الطلب',
                                style: AppTextStyles.semiBold.copyWith(
                                  fontSize: SizeConfig.ts(14),
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
