class Visit {
  const Visit({
    required this.id,
    required this.patientId,
    required this.clinicId,
    required this.startsAt,
    required this.durationMinutes,
    this.note = '',
  });

  final String id;
  final String patientId;
  final String clinicId;
  final DateTime startsAt;
  final int durationMinutes;
  final String note;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
}
