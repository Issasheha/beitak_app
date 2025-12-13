class BookingResult {
  final int id;
  final String status;

  const BookingResult({required this.id, required this.status});

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? json.cast<String, dynamic>();
    return BookingResult(
      id: (data['id'] is int) ? data['id'] as int : int.tryParse('${data['id']}') ?? 0,
      status: (data['status'] ?? '').toString(),
    );
  }
}
