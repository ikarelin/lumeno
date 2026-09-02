import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_context.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_intent.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_models.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_repositories.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_source.dart';
import 'package:lumeno/features/quick_create/presentation/controllers/quick_create_controller.dart';

void main() {
  group('QuickCreateController', () {
    test('save and schedule keeps the created patient selected', () async {
      final repositories = _FakeRepositories();
      final controller = QuickCreateController(
        context: const QuickCreateContext(
          intent: QuickCreateIntent.newPatient,
          source: QuickCreateSource.sidebarQuickAction,
        ),
        patientRepository: repositories,
        clinicRepository: repositories,
        visitRepository: repositories,
        availabilityRepository: repositories,
      );

      addTearDown(controller.dispose);

      controller.updatePatientDraft(
        name: 'Maya Stone',
        phone: '+44 7700 900123',
        note: 'Referral',
      );

      final result = await controller.savePatient(continueToSchedule: true);

      expect(result, isA<PatientCreatedResult>());
      expect(controller.state.selectedPatient?.name, 'Maya Stone');
      expect(controller.state.isSchedulingPatient, isTrue);
      expect(repositories.createPatientCalls, 1);
    });

    test('visit retry does not create the patient twice', () async {
      final repositories = _FakeRepositories()..visitFailuresRemaining = 1;
      final controller = QuickCreateController(
        context: const QuickCreateContext(
          intent: QuickCreateIntent.newPatient,
          source: QuickCreateSource.sidebarQuickAction,
        ),
        patientRepository: repositories,
        clinicRepository: repositories,
        visitRepository: repositories,
        availabilityRepository: repositories,
      );

      addTearDown(controller.dispose);

      controller.updatePatientDraft(
        name: 'Maya Stone',
        phone: '+44 7700 900123',
      );
      await controller.savePatient(continueToSchedule: true);
      controller.selectClinic(
        const Clinic(id: 'clinic-1', name: 'Lumeno Clinic'),
      );
      controller.selectStartsAt(DateTime(2026, 9, 2, 11));

      expect(await controller.saveVisit(), isNull);
      expect(controller.state.selectedPatient?.name, 'Maya Stone');
      expect(repositories.createPatientCalls, 1);

      expect(await controller.saveVisit(), isA<VisitCreatedResult>());
      expect(repositories.createPatientCalls, 1);
      expect(repositories.createVisitCalls, 2);
    });
  });
}

class _FakeRepositories
    implements
        PatientRepository,
        ClinicRepository,
        VisitRepository,
        AvailabilityRepository {
  int createPatientCalls = 0;
  int createVisitCalls = 0;
  int visitFailuresRemaining = 0;

  @override
  Future<Patient> createPatient(CreatePatientInput input) async {
    createPatientCalls += 1;

    return Patient(
      id: 'patient-$createPatientCalls',
      name: input.name,
      phone: input.phone,
      note: input.note,
    );
  }

  @override
  Future<Clinic> createClinic(CreateClinicInput input) async {
    return Clinic(id: 'clinic-created', name: input.name);
  }

  @override
  Future<Visit> createVisit(CreateVisitInput input) async {
    createVisitCalls += 1;

    if (visitFailuresRemaining > 0) {
      visitFailuresRemaining -= 1;
      throw StateError('Visit failed');
    }

    return Visit(
      id: 'visit-$createVisitCalls',
      patientId: input.patientId,
      clinicId: input.clinicId,
      startsAt: input.startsAt,
      durationMinutes: input.durationMinutes,
      note: input.note,
    );
  }

  @override
  Future<List<Clinic>> fetchClinics() async {
    return const [Clinic(id: 'clinic-1', name: 'Lumeno Clinic')];
  }

  @override
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  }) async {
    return [
      AvailabilitySlot(
        startsAt: DateTime(2026, 9, 2, 11),
        durationMinutes: durationMinutes,
      ),
    ];
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    return const [];
  }
}
