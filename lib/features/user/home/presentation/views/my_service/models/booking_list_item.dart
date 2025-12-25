class BookingListItem {
  final int bookingId; // مهم جداً للتفاصيل /bookings/:id
  final String bookingNumber; // للعرض
  final String status; // raw
  final String typeLabel; // "قيد الانتظار" / "قادمة" / ...
  final String serviceName;
  final String date; // raw date string
  final String time; // formatted time
  final String location;

  final double? price;
  final String? currency;

  final String? providerName;
  final String? providerPhone;

  const BookingListItem({
    required this.bookingId,
    required this.bookingNumber,
    required this.status,
    required this.typeLabel,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.location,
    this.price,
    this.currency,
    this.providerName,
    this.providerPhone,
  });

  String get idLabel => '#$bookingNumber';

  bool get isCancelled => status == 'cancelled' || status == 'refunded';
  bool get isCompleted => status == 'completed';

  // ✅ NEW
  bool get isIncomplete => status == 'incomplete';

  bool get isPending =>
      status == 'pending_provider_accept' || status == 'pending';

  bool get isUpcoming => const {
        'confirmed',
        'provider_on_way',
        'provider_arrived',
        'in_progress',
      }.contains(status);

  BookingListItem copyWith({
    double? price,
    String? currency,
    String? providerName,
    String? providerPhone,
  }) {
    return BookingListItem(
      bookingId: bookingId,
      bookingNumber: bookingNumber,
      status: status,
      typeLabel: typeLabel,
      serviceName: serviceName,
      date: date,
      time: time,
      location: location,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
    );
  }
}
