class CreatePatientClinicalNoteInput {
  const CreatePatientClinicalNoteInput({
    required this.patientId,
    required this.body,
  });

  static const maxBodyCodePoints = 20000;

  final String patientId;
  final String body;

  bool get isValid {
    final normalizedBody = body.trim();
    return patientId.trim().isNotEmpty &&
        normalizedBody.isNotEmpty &&
        normalizedBody.runes.length <= maxBodyCodePoints;
  }
}
