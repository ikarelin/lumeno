import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/clinical_notes/domain/create_patient_clinical_note_input.dart';

void main() {
  group('CreatePatientClinicalNoteInput', () {
    test('requires both patient ID and nonblank note body', () {
      expect(
        const CreatePatientClinicalNoteInput(patientId: ' ', body: 'Note')
            .isValid,
        isFalse,
      );
      expect(
        const CreatePatientClinicalNoteInput(patientId: 'patient-1', body: ' \n')
            .isValid,
        isFalse,
      );
      expect(
        const CreatePatientClinicalNoteInput(
          patientId: 'patient-1',
          body: 'Clinical observation',
        ).isValid,
        isTrue,
      );
    });

    test('enforces the note-body length bound', () {
      final atLimit = 'a' * CreatePatientClinicalNoteInput.maxBodyCodePoints;
      expect(
        CreatePatientClinicalNoteInput(
          patientId: 'patient-1',
          body: atLimit,
        ).isValid,
        isTrue,
      );
      expect(
        CreatePatientClinicalNoteInput(
          patientId: 'patient-1',
          body: '${atLimit}a',
        ).isValid,
        isFalse,
      );
    });
  });
}
