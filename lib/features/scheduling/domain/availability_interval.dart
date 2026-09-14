class AvailabilityInterval {
  AvailabilityInterval({
    required this.startsAt,
    required this.endsAt,
  }) {
    if (!startsAt.isBefore(endsAt)) {
      throw ArgumentError.value(
        '$startsAt – $endsAt',
        'interval',
        'Availability interval must have a start before its end.',
      );
    }
  }

  final DateTime startsAt;
  final DateTime endsAt;

  Duration get duration => endsAt.difference(startsAt);

  bool canFitMinutes(int durationMinutes) {
    if (durationMinutes <= 0) {
      return false;
    }

    return !startsAt
        .add(Duration(minutes: durationMinutes))
        .isAfter(endsAt);
  }

  @override
  String toString() => 'AvailabilityInterval($startsAt, $endsAt)';
}
