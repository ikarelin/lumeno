class AvailabilitySlot {
  const AvailabilitySlot({
    required this.startsAt,
    required this.durationMinutes,
  });

  final DateTime startsAt;
  final int durationMinutes;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
}
