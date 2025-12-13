enum RecentActivityType {
  profileUpdated,
  serviceCompleted,
  cancelledRequest,
  reviewSubmitted,
}

class RecentActivityEntity {
  final RecentActivityType type;
  final String title;
  final String subtitle;
  final DateTime time;

  const RecentActivityEntity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
