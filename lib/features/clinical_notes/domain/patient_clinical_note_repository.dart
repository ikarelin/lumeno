import 'create_patient_clinical_note_input.dart';
import 'patient_clinical_note.dart';

abstract interface class PatientClinicalNoteRepository {
  /// Returns the latest entries belonging to one patient, newest first.
  Future<List<PatientClinicalNote>> fetchForPatient({
    required String patientId,
    int limit = 50,
  });

  /// Creates a new entry. Existing entries cannot be mutated in this slice.
  Future<PatientClinicalNote> create(
    CreatePatientClinicalNoteInput input,
  );
}
