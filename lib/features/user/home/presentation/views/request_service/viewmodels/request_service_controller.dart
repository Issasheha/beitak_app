import 'dart:io';

import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:beitak_app/features/user/home/presentation/views/request_service/viewmodels/request_service_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

import '../models/city_model.dart';
import '../models/location_models.dart' show AreaModel;
import '../models/service_type_option.dart';
import '../widgets/date_selection_section.dart';
import '../widgets/otp_verify_dialog.dart';
import '../widgets/share_phone_dialog.dart';
import '../widgets/success_dialog.dart';
import 'request_service_state.dart';
import 'request_service_viewmodel.dart';

class RequestServiceController extends StateNotifier<RequestServiceState> {
  final RequestServiceViewModel _vm;
  final AuthLocalDataSourceImpl _authLocal;

  RequestServiceController(this._vm, this._authLocal)
      : super(const RequestServiceState());

  String _normSlug(String s) {
    var x = s.trim().toLowerCase();
    x = x.replaceAll(RegExp(r'\s+'), ' ');
    x = x.replaceAll('_', ' ');
    x = x.replaceAll('-', ' ');
    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();
    return x;
  }

  Future<void> bootstrap() async {
    state = state.copyWith(sessionLoading: true);
    try {
      await _loadSession();
      await _loadCities();
      await _loadCategories();
    } finally {
      if (mounted) {
        state = state.copyWith(sessionLoading: false);
      }
    }
  }

  Future<void> _loadSession() async {
    try {
      final session = await _authLocal.getCachedAuthSession();

      bool isGuest;
      String? sessionName;
      String? sessionPhone;

      if (session == null) {
        isGuest = true;
        sessionName = null;
        sessionPhone = null;
      } else {
        final token = (session.token ?? '').trim();
        isGuest = session.isGuest || token.isEmpty;

        final user = session.user;
        final first = (user?.firstName ?? '').trim();
        final last = (user?.lastName ?? '').trim();
        final fullName = ('$first $last').trim();
        final phone = (user?.phone ?? '').trim();

        sessionName = fullName.isEmpty ? null : fullName;
        sessionPhone = phone.isEmpty ? null : phone;
      }

      if (!mounted) return;
      state = state.copyWith(
        isGuest: isGuest,
        sessionName: sessionName,
        sessionPhone: sessionPhone,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isGuest: true,
        sessionName: null,
        sessionPhone: null,
      );
    }
  }

  Future<void> _loadCities() async {
    if (!mounted) return;
    state = state.copyWith(
      citiesLoading: true,
      citiesError: null,
    );

    try {
      final cities = await _vm.fetchCities();
      if (!mounted) return;

      var selectedCity = state.selectedCity;
      var selectedArea = state.selectedArea;
      var areas = state.areas;

      if (selectedCity != null) {
        final keep = cities.any((c) => c.id == selectedCity?.id);
        if (!keep) {
          selectedCity = null;
          selectedArea = null;
          areas = const [];
        }
      }

      state = state.copyWith(
        cities: cities,
        selectedCity: selectedCity,
        selectedArea: selectedArea,
        areas: areas,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(citiesError: _niceError(e));
    } finally {
      if (mounted) {
        state = state.copyWith(citiesLoading: false);
      }
    }
  }

  Future<void> loadCities() => _loadCities();

  Future<void> loadAreasForCity(CityModel city) async {
    if (!mounted) return;
    state = state.copyWith(
      areasLoading: true,
      areasError: null,
      areas: const [],
      selectedArea: null,
    );

    try {
      final slug = city.slug.trim();
      if (slug.isEmpty) {
        if (!mounted) return;
        state = state.copyWith(areasError: 'لم يتم العثور على slug للمحافظة');
        return;
      }

      final areas = await _vm.fetchAreasByCitySlug(slug);
      if (!mounted) return;

      if (areas.isEmpty) {
        state = state.copyWith(
          areasError: 'لا توجد مناطق متاحة لهذه المحافظة حالياً',
          areas: const [],
        );
      } else {
        state = state.copyWith(areas: areas, areasError: null);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(areasError: _niceError(e));
    } finally {
      if (mounted) {
        state = state.copyWith(areasLoading: false);
      }
    }
  }

  void onCityChanged(CityModel? city) {
    if (!mounted) return;

    if (city == null) {
      state = state.copyWith(
        selectedCity: null,
        selectedArea: null,
        areas: const [],
        areasError: null,
      );
      return;
    }

    state = state.copyWith(
      selectedCity: city,
      selectedArea: null,
      areas: const [],
      areasError: null,
    );

    loadAreasForCity(city);
  }

  void selectArea(AreaModel? area) {
    if (!mounted) return;
    state = state.copyWith(selectedArea: area);
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    state = state.copyWith(categoryError: null);

    try {
      final map = await _vm.fetchCategorySlugToId();
      if (!mounted) return;
      state = state.copyWith(slugToCategoryId: map);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(categoryError: _niceError(e));
    }
  }

  void setDateType(ServiceDateType type) {
    if (!mounted) return;
    state = state.copyWith(dateType: type);
  }

  void setOtherDate(DateTime? date) {
    if (!mounted) return;
    state = state.copyWith(otherDate: date);
  }

  void setSelectedHour(String? hour) {
    if (!mounted) return;
    state = state.copyWith(selectedHour: hour);
  }

  String _apiServiceDateType(ServiceDateType t) {
    switch (t) {
      case ServiceDateType.today:
        return 'today';
      case ServiceDateType.tomorrow:
        return 'tomorrow';
      case ServiceDateType.dayAfter:
        return 'day_after';
      case ServiceDateType.other:
        return 'other';
    }
  }

  void selectServiceType(ServiceTypeOption option) {
    if (!mounted) return;
    state = state.copyWith(selectedServiceType: option);
  }

  Future<void> pickImages(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;

      final newFiles = [
        ...state.files,
        ...picked.map((x) => File(x.path)),
      ];

      if (!mounted) return;
      state = state.copyWith(files: newFiles);
    } catch (e) {
      if (!context.mounted) return;
      _snack(context, _niceError(e));
    }
  }

  void removeFileAt(int index) {
    if (!mounted) return;
    if (index < 0 || index >= state.files.length) return;

    final list = [...state.files]..removeAt(index);
    state = state.copyWith(files: list);
  }

  Future<void> submit({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameCtrl,
    required TextEditingController phoneCtrl,
    required TextEditingController descCtrl,
    required TextEditingController budgetCtrl,
  }) async {
    if (state.sessionLoading) return;

    FocusScope.of(context).unfocus();

    // ✅ كل أخطاء الحقول المطلوبة صارت داخل الفورم (تحت كل حقل)
    final ok = formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final name = state.showNameField
        ? nameCtrl.text.trim()
        : (state.sessionName ?? '').trim();
    final phone = state.showPhoneField
        ? phoneCtrl.text.trim()
        : (state.sessionPhone ?? '').trim();

    if (name.isEmpty) {
      _snack(context, 'الاسم مطلوب');
      return;
    }
    if (phone.isEmpty) {
      _snack(context, 'رقم الهاتف مطلوب');
      return;
    }

    final rawSlug = state.selectedServiceType!.categorySlug;
    final normalized = _normSlug(rawSlug);

    final categoryId =
        state.slugToCategoryId[normalized] ?? state.slugToCategoryId[rawSlug.trim()];

    if (categoryId == null || categoryId <= 0) {
      _snack(
        context,
        'تعذر تحديد الفئة من السيرفر.\n'
        'جرّب تحديث الشاشة أو تأكد من slugs في /api/categories.',
      );
      return;
    }

    final share = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SharePhoneDialog(phone: phone),
    );

    if (!context.mounted) return;
    if (share == null) return;

    if (!mounted) return;
    state = state.copyWith(submitting: true);

    String? guestOtp;

    try {
      if (state.isGuest) {
        await _vm.sendServiceReqOtp(phone: phone);
        if (!context.mounted) return;

        guestOtp = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (_) => OtpVerifyDialog(
            phone: phone,
            onResend: () => _vm.sendServiceReqOtp(phone: phone),
            onVerify: (otp) => _vm.verifyServiceReqOtp(phone: phone, otp: otp),
          ),
        );

        if (!context.mounted) return;

        if (guestOtp == null || guestOtp.trim().isEmpty) {
          _snack(context, 'لم يتم التحقق من الرقم');
          return;
        }
        guestOtp = guestOtp.trim();
      }

      final serviceDateIso = _resolveSelectedDateIso(state.dateType, state.otherDate);
      if (serviceDateIso == null) {
        if (context.mounted) _snack(context, 'تعذر تحديد التاريخ. حاول مجدداً.');
        return;
      }

      final budget = _budgetValue(budgetCtrl.text);
      // ✅ Safety (مع أنه المفروض الفورم يمنعها)
      if (budget != null && (budget < 10 || budget > 10000)) {
        _snack(context, 'الميزانية يجب أن تكون بين 10 و 10000 دينار');
        return;
      }

      final dateTypeApi = _apiServiceDateType(state.dateType);

      final draft = ServiceRequestDraft(
        name: name,
        phone: phone,
        categoryId: categoryId,
        cityId: state.selectedCity!.id,
        areaId: state.selectedArea!.id,
        description: descCtrl.text.trim(),
        budget: budget,
        serviceDateIso: serviceDateIso,
        serviceDateType: dateTypeApi,
        serviceTimeHour: state.selectedHour!, // still "HH:00"
        sharePhoneWithProvider: share,
        files: List<File>.from(state.files),
        isGuest: state.isGuest,
        otp: state.isGuest ? guestOtp : null,
      );

      await _vm.submitServiceRequest(draft);
      if (!context.mounted) return;
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SuccessDialog(),
      );
      if (!context.mounted) return;
      if (!mounted) return;

      // reset
      nameCtrl.clear();
      phoneCtrl.clear();
      descCtrl.clear();
      budgetCtrl.clear();

      state = state.copyWith(
        selectedServiceType: null,
        dateType: ServiceDateType.today,
        otherDate: null,
        selectedHour: null,
        selectedCity: null,
        selectedArea: null,
        areas: const [],
        areasError: null,
        files: const [],
      );

      // ✅ QA: بعد النجاح رجّع المستخدم للهوم
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!context.mounted) return;
      _snack(context, _niceError(e));
    } finally {
      if (mounted) {
        state = state.copyWith(submitting: false);
      }
    }
  }

  double? _budgetValue(String text) {
    final txt = text.trim();
    if (txt.isEmpty) return null;

    final normalized = txt.replaceAll(',', '').replaceAll('٬', '').replaceAll('٫', '.');
    return double.tryParse(normalized);
  }

  String? _resolveSelectedDateIso(ServiceDateType type, DateTime? otherDate) {
    final now = DateTime.now();
    DateTime? date;

    if (type == ServiceDateType.today) {
      date = now;
    } else if (type == ServiceDateType.other) {
      if (otherDate == null) return null;
      date = otherDate;
    } else if (type == ServiceDateType.tomorrow) {
      date = now.add(const Duration(days: 1));
    } else if (type == ServiceDateType.dayAfter) {
      date = now.add(const Duration(days: 2));
    }

    if (date == null) return null;

    final d = DateTime(date.year, date.month, date.day);
    String two(int v) => v < 10 ? '0$v' : '$v';

    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  String _niceError(Object e) {
    final s = e.toString().replaceFirst('Exception: ', '').trim();
    if (s.isEmpty) return 'حدث خطأ غير متوقع';
    return s;
  }

  void _snack(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
