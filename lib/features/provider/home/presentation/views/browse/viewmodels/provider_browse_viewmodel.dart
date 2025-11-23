import 'package:flutter/foundation.dart';

/// نموذج طلب خدمة واحد (جاية من المستخدم)
class ServiceRequest {
  final String id;
  final String title;
  final String clientName;
  final String city;
  final String area;
  final String category;

  final DateTime scheduledDate;
  final String timeLabel;

  final double distanceKm;
  final double minBudget;
  final double maxBudget;

  final String status; // 'قيد الانتظار' / 'مقبولة' / 'مكتملة'

  final String phone;
  final String email;
  final String notes;

  const ServiceRequest({
    required this.id,
    required this.title,
    required this.clientName,
    required this.city,
    required this.area,
    required this.category,
    required this.scheduledDate,
    required this.timeLabel,
    required this.distanceKm,
    required this.minBudget,
    required this.maxBudget,
    required this.status,
    required this.phone,
    required this.email,
    required this.notes,
  });

  String get fullLocation => '$city، $area';

  String get budgetLabel {
    if (minBudget == maxBudget) {
      return '${minBudget.toStringAsFixed(0)} د.أ';
    }
    return '${minBudget.toStringAsFixed(0)}–${maxBudget.toStringAsFixed(0)} د.أ';
  }
}

class ProviderBrowseViewModel {
  // -------- حالة الفلاتر الحالية --------
  String selectedStatus = 'الكل';
  String selectedCategory = 'الكل';
  double minPrice = 0;
  double maxPrice = 200;
  double minRating = 0;

  // -------- البيانات الوهمية --------
  final List<ServiceRequest> _allRequests = [
    ServiceRequest(
      id: 'REQ-1001',
      title: 'Electrical Wiring Check',
      clientName: 'Rania Hussein',
      city: 'إربد',
      area: 'شارع الجامعة',
      category: 'كهربائي',
      scheduledDate: DateTime(2025, 11, 21),
      timeLabel: '11:00 ص',
      distanceKm: 2.5,
      minBudget: 25,
      maxBudget: 40,
      status: 'قيد الانتظار',
      phone: '+962 79 XXX XXXX',
      email: 'client@example.com',
      notes: 'فحص تمديدات كهربائية في شقة جديدة.',
    ),
    ServiceRequest(
      id: 'REQ-1002',
      title: 'Carpentry - Kitchen Cabinets',
      clientName: 'Omar Saleh',
      city: 'عمّان',
      area: 'دابوق',
      category: 'نجارة',
      scheduledDate: DateTime(2025, 11, 24),
      timeLabel: '9:00 ص',
      distanceKm: 5.2,
      minBudget: 35,
      maxBudget: 55,
      status: 'قيد الانتظار',
      phone: '+962 79 XXX XXXX',
      email: 'client@example.com',
      notes: 'تصليح وتركيب خزائن مطبخ جديدة.',
    ),
    ServiceRequest(
      id: 'REQ-1003',
      title: 'Painting - Living Room',
      clientName: 'Noor Haddad',
      city: 'عمّان',
      area: 'جبل عمّان',
      category: 'الدهان',
      scheduledDate: DateTime(2025, 11, 25),
      timeLabel: '8:00 ص',
      distanceKm: 1.8,
      minBudget: 60,
      maxBudget: 80,
      status: 'مقبولة',
      phone: '+962 79 XXX XXXX',
      email: 'client@example.com',
      notes: 'دهان غرفة الجلوس بالكامل بلون فاتح.',
    ),
    ServiceRequest(
      id: 'REQ-1004',
      title: 'Plumbing - Bathroom Leak',
      clientName: 'Layla Ahmad',
      city: 'عمّان',
      area: 'خلدا',
      category: 'مواسرجي',
      scheduledDate: DateTime(2025, 11, 18),
      timeLabel: '3:00 م',
      distanceKm: 3.1,
      minBudget: 45,
      maxBudget: 45,
      status: 'مكتملة',
      phone: '+962 79 XXX XXXX',
      email: 'client@example.com',
      notes: 'إصلاح تهريب ماء في حمام الشقة.',
    ),
  ];

  late List<ServiceRequest> filteredRequests;

  ProviderBrowseViewModel() {
    filteredRequests = List<ServiceRequest>.from(_allRequests);
  }

  // --------- تحديث الفلاتر ---------

  void updateStatus(String status) {
    selectedStatus = status;
    _applyFilters();
  }

  void updateFilters({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) {
    if (category != null) selectedCategory = category;
    if (minPrice != null) this.minPrice = minPrice;
    if (maxPrice != null) this.maxPrice = maxPrice;
    if (minRating != null) this.minRating = minRating;
    _applyFilters();
  }

  void resetFilters() {
    selectedStatus = 'الكل';
    selectedCategory = 'الكل';
    minPrice = 0;
    maxPrice = 200;
    minRating = 0;
    filteredRequests = List<ServiceRequest>.from(_allRequests);
  }

  void _applyFilters() {
    filteredRequests = _allRequests.where((req) {
      final statusOk =
          selectedStatus == 'الكل' || req.status == selectedStatus;

      final catOk =
          selectedCategory == 'الكل' || req.category == selectedCategory;

      final priceOk =
          req.minBudget >= minPrice && req.maxBudget <= maxPrice;

      // حالياً ما في تقييم للطلب نفسه، نخليها دايماً true
      const ratingOk = true;

      return statusOk && catOk && priceOk && ratingOk;
    }).toList();
  }

  // تغيير حالة طلب (مثلاً بعد قبول أو إلغاء)
  void updateRequestStatus(String requestId, String newStatus) {
    final index = _allRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final old = _allRequests[index];
    _allRequests[index] = ServiceRequest(
      id: old.id,
      title: old.title,
      clientName: old.clientName,
      city: old.city,
      area: old.area,
      category: old.category,
      scheduledDate: old.scheduledDate,
      timeLabel: old.timeLabel,
      distanceKm: old.distanceKm,
      minBudget: old.minBudget,
      maxBudget: old.maxBudget,
      status: newStatus,
      phone: old.phone,
      email: old.email,
      notes: old.notes,
    );

    _applyFilters();
  }
}
