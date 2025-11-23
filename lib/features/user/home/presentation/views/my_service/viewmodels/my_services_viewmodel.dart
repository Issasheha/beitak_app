// lib/features/user/home/presentation/viewmodels/my_services_viewmodel.dart

/// ViewModel لشاشة "خدماتي".
///
/// حالياً:
/// - يستخدم بيانات وهمية (dummy) محلياً.
/// - يقدّم دالة واحدة getFilteredServices بنفس منطق
///   _getFilteredServices القديم في الـ View.
/// لاحقاً يمكن استبدال الداتا الوهمية بنداء API حقيقي.
class MyServicesViewModel {
  final List<Map<String, dynamic>> _allServices;

  MyServicesViewModel() : _allServices = _generateDummyServices();

  /// الحصول على قائمة الطلبات بعد تطبيق:
  /// - فلتر الحالة (statusFilter مثل Pending)
  /// - الفلتر النصي (filter مثل "طلباتي القادمة")
  List<Map<String, dynamic>> getFilteredServices({
    String? statusFilter,
    required String filter,
  }) {
    var filtered = List<Map<String, dynamic>>.from(_allServices);

    // 1) فلتر الحالة (تبويب "قيد الانتظار" مثلاً)
    if (statusFilter != null) {
      filtered =
          filtered.where((s) => s['status'] == statusFilter).toList();
    }

    // 2) فلتر القائمة المنسدلة (الكل / القادمة / الملغية / المكتملة)
    if (filter != 'الكل') {
      if (filter == 'طلباتي القادمة') {
        filtered = filtered
            .where((s) =>
                s['type'] == 'قادمة' || s['status'] == 'Pending')
            .toList();
      } else if (filter == 'طلباتي الملغية') {
        filtered = filtered.where((s) => s['type'] == 'ملغاة').toList();
      } else if (filter == 'طلباتي المكتملة') {
        filtered = filtered.where((s) => s['type'] == 'مكتملة').toList();
      }
    }

    return filtered;
  }

  // ================= Helpers =================

  static List<Map<String, dynamic>> _generateDummyServices() {
    return List.generate(20, (i) {
      final types = ['قادمة', 'ملغاة', 'مكتملة', 'قيد الانتظار'];
      final type = types[i % 4];

      final status = type == 'قيد الانتظار'
          ? 'Pending'
          : (type == 'مكتملة' ? 'Completed' : 'Cancelled');

      return {
        'id': '#1258${500 + i}',
        'service': i % 3 == 0
            ? 'تنظيف منزلي شامل'
            : i % 3 == 1
                ? 'صيانة تكييف'
                : 'تركيب ستائر وديكور',
        'date': ['12/12/2025', '15/01/2026', '05/11/2025'][i % 3],
        'time': ['9:00 ص', '2:30 م', '6:00 م'][i % 3],
        'location': 'عمان، عبدون - برج الجوهرة',
        'type': type,
        'status': status,
      };
    });
  }
}
