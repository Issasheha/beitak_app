class ProviderMyServiceViewModel {
  final List<Map<String, dynamic>> _jobs;

  ProviderMyServiceViewModel() : _jobs = _generateDummyJobs();

  List<Map<String, dynamic>> getFilteredJobs({
    String? statusFilter,
    required String filter,
  }) {
    var filtered = List<Map<String, dynamic>>.from(_jobs);

    if (statusFilter != null) {
      filtered = filtered.where((j) => j['status'] == statusFilter).toList();
    }

    if (filter != 'الكل') {
      if (filter == 'الوظائف الحالية') {
        filtered = filtered.where((j) => j['type'] == 'نشطة').toList();
      } else if (filter == 'الوظائف المكتملة') {
        filtered = filtered.where((j) => j['type'] == 'مكتملة').toList();
      } else if (filter == 'الملغاة') {
        filtered = filtered.where((j) => j['type'] == 'ملغاة').toList();
      }
    }

    return filtered;
  }

  static List<Map<String, dynamic>> _generateDummyJobs() {
    return [
      {
        'id': '#J1021',
        'service': 'AC Maintenance',
        'client': 'Khaled Ali',
        'date': '23/11/2025',
        'time': '2:00 م',
        'location': 'عمان، الصويفية',
        'price': '50 JOD',
        'status': 'Approved',
        'type': 'نشطة',
      },
      {
        'id': '#J1022',
        'service': 'Plumbing Repair',
        'client': 'Sara Mohammad',
        'date': '22/11/2025',
        'time': '10:00 ص',
        'location': 'عمان، عبدون',
        'price': '40 JOD',
        'status': 'Pending',
        'type': 'قيد التأكيد',
      },
      {
        'id': '#J1023',
        'service': 'House Cleaning',
        'client': 'Layla Ahmad',
        'date': '20/11/2025',
        'time': '9:00 ص',
        'location': 'عمان، خلدا',
        'price': '60 JOD',
        'status': 'Completed',
        'type': 'مكتملة',
      },
      {
        'id': '#J1024',
        'service': 'Electrical Wiring',
        'client': 'Rania Hussein',
        'date': '19/11/2025',
        'time': '11:00 ص',
        'location': 'إربد، شارع الجامعة',
        'price': '30 JOD',
        'status': 'Cancelled',
        'type': 'ملغاة',
      },
    ];
  }
}
