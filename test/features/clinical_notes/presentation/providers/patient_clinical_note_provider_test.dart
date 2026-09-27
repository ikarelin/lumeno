import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/clinical_notes/domain/create_patient_clinical_note_input.dart';
import 'package:lumeno/features/clinical_notes/domain/patient_clinical_note.dart';
import 'package:lumeno/features/clinical_notes/domain/patient_clinical_note_repository.dart';
import 'package:lumeno/features/clinical_notes/presentation/providers/patient_clinical_note_provider.dart';

void main() {
  test('patient clinical-note page forwards patient, limit and offset', () async {
    final repository = _FakePatientClinicalNoteRepository();
    final container = ProviderContainer(
      overrides: [
        patientClinicalNoteRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notes = await container.read(
      patientClinicalNotesPageProvider((patientId: 'patient-1', offset: 30))
          .future,
    );

    expect(notes, hasLength(1));
    expect(repository.lastPatientId, 'patient-1');
    expect(repository.lastLimit, 30);
    expect(repository.lastOffset, 30);
  });

  test('legacy patient notes provider keeps first-page behavior', () async {
    final repository = _FakePatientClinicalNoteRepository();
    final container = ProviderContainer(
      overrides: [
        patientClinicalNoteRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(patientClinicalNotesProvider('patient-2').future);

    expect(repository.lastPatientId, 'patient-2');
    expect(repository.lastLimit, 50);
    expect(repository.lastOffset, 0);
  });
}

class _FakePatientClinicalNoteRepository
    implements PatientClinicalNoteRepository {
  String? lastPatientId;
  int? lastLimit;
  int? lastOffset;

  @override
  Future<List<PatientClinicalNote>> fetchForPatient({
    required String patientId,
    int limit = 50,
    int offset = 0,
  }) async {
    lastPatientId = patientId;
    lastLimit = limit;
    lastOffset = offset;
    return [
      PatientClinicalNote(
        id: 'note-$offset',
        patientId: patientId,
        authorUserId: 'doctor-1',
        body: 'Clinical note',
        createdAt: DateTime.utc(2026, 9, 22, 12),
      ),
    ];
  }

  @override
  Future<List<PatientClinicalNote>> fetchForVisit({
    required String patientId,
    required String visitId,
    int limit = 50,
    int offset = 0,
  }) async => <PatientClinicalNote>[];

  @override
  Future<PatientClinicalNote> create(
    CreatePatientClinicalNoteInput input,
  ) {
    throw UnimplementedError();
  }
}
