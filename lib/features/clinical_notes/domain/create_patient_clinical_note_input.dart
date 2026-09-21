class CreatePatientClinicalNoteInput {
  const CreatePatientClinicalNoteInput({
    required this.patientId,
    required this.body,
    this.visitId,
  });

  static const maxBodyCodePoints = 20000;

  final String patientId;
  final String body;

  /// Null for a general patient note; otherwise the linked Visit UUID.
  final String? visitId;

  bool get isValid {
    final normalizedBody = body.trim();
    return patientId.trim().isNotEmpty &&
        (visitId == null || visitId!.trim().isNotEmpty) &&
        normalizedBody.isNotEmpty &&
        normalizedBody.runes.length <= maxBodyCodePoints;
  }
}
