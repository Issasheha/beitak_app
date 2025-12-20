// lib/features/user/home/presentation/views/request_service/request_service_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'viewmodels/request_service_providers.dart';
import 'widgets/area_dropdown_field.dart';
import 'widgets/city_dropdown_field.dart';
import 'widgets/date_selection_section.dart';
import 'widgets/image_upload_section.dart';
import 'widgets/request_text_field.dart';
import 'widgets/service_type_field.dart';
import 'widgets/time_selection_field.dart';

class RequestServiceView extends ConsumerStatefulWidget {
  const RequestServiceView({super.key});

  @override
  ConsumerState<RequestServiceView> createState() => _RequestServiceViewState();
}

class _RequestServiceViewState extends ConsumerState<RequestServiceView> {
  final _formKey = GlobalKey<FormState>();

  // Guest fields
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Common fields
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

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
                                final s = v?.trim() ?? '';
                                if (s.length < 3) {
                                  return 'الاسم مطلوب';
                                }
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
                                final s = v?.trim() ?? '';
                                if (s.length < 9) {
                                  return 'رقم الجوال مطلوب';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: SizeConfig.h(14)),
                          ],

                          ServiceTypeField(
                            selected: state.selectedServiceType,
                            onSelected: controller.selectServiceType,
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

                          RequestTextField(
                            controller: _descCtrl,
                            label: 'الوصف / الملاحظات *',
                            hint: 'اكتب تفاصيل ما تحتاجه...',
                            maxLines: 4,
                            validator: (v) {
                              final s = v?.trim() ?? '';
                              if (s.length < 10) {
                                return 'الرجاء كتابة وصف كافٍ للطلب';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          RequestTextField(
                            controller: _budgetCtrl,
                            label: 'الميزانية (اختياري)',
                            hint: 'مثال: 50',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          DateSelectionSection(
                            selectedType: state.dateType,
                            selectedOtherDate: state.otherDate,
                            onTypeSelected: controller.setDateType,
                            onOtherPicked: controller.setOtherDate,
                          ),
                          SizedBox(height: SizeConfig.h(14)),

                          TimeSelectionField(
                            selectedHour: state.selectedHour,
                            onPickHour: controller.setSelectedHour,
                          ),
                          SizedBox(height: SizeConfig.h(14)),

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
