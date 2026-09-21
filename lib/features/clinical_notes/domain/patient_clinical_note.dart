/// A patient-scoped clinical entry. This is not the operational Visit.note.
class PatientClinicalNote {
  const PatientClinicalNote({
    required this.id,
    required this.patientId,
    this.visitId,
    required this.authorUserId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String patientId;

  /// Null for an independent patient note, or if a linked visit was deleted.
  final String? visitId;
  final String authorUserId;
  final String body;

  /// An absolute timestamp from the backend; display conversion belongs to UI.
  final DateTime createdAt;
}
