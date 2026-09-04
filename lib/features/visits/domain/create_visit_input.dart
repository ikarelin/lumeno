class CreateVisitInput {
  const CreateVisitInput({
    required this.patientId,
    required this.clinicId,
    required this.startsAt,
    required this.durationMinutes,
    this.note = '',
  });

  final String patientId;
  final String clinicId;
  final DateTime startsAt;
  final int durationMinutes;
  final String note;

  bool get isValid =>
      patientId.trim().isNotEmpty &&
      clinicId.trim().isNotEmpty &&
      durationMinutes > 0;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
}
