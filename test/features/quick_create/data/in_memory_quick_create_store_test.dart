import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/quick_create/data/in_memory_quick_create_store.dart';
import 'package:lumeno/features/quick_create/domain/clinic.dart';
import 'package:lumeno/features/quick_create/domain/patient.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_inputs.dart';

void main() {
  group('InMemoryQuickCreateStore', () {
    test('shares created records across all repository contracts', () async {
      final store = InMemoryQuickCreateStore(
        patients: const [
          Patient(id: 'patient-1', name: 'Anna Petrova', phone: '123'),
        ],
        clinics: const [Clinic(id: 'clinic-1', name: 'Central')],
      );

      final patient = await store.createPatient(
        const CreatePatientInput(
          name: '  Boris Ivanov  ',
          phone: '  456  ',
          note: '  First visit  ',
        ),
      );
      final clinic = await store.createClinic(
        const CreateClinicInput(name: '  Riverside  '),
      );
      final visit = await store.createVisit(
        CreateVisitInput(
          patientId: patient.id,
          clinicId: clinic.id,
          startsAt: DateTime(2026, 9, 1, 10),
          durationMinutes: 45,
          note: '  Consultation  ',
        ),
      );

      expect(patient.name, 'Boris Ivanov');
      expect(patient.phone, '456');
      expect(clinic.name, 'Riverside');
      expect(visit.note, 'Consultation');
      expect(await store.searchPatients('boris'), [patient]);
      expect(await store.fetchClinics(), contains(clinic));
    });

    test('suggestions skip times occupied by existing visits', () async {
      final from = DateTime(2026, 9, 1, 10);
      final store = InMemoryQuickCreateStore(
        patients: const [Patient(id: 'patient-1', name: 'Anna')],
        clinics: const [Clinic(id: 'clinic-1', name: 'Central')],
      );

      await store.createVisit(
        CreateVisitInput(
          patientId: 'patient-1',
          clinicId: 'clinic-1',
          startsAt: from,
          durationMinutes: 30,
          note: '',
        ),
      );

      final slots = await store.findAvailableSlots(
        from: from,
        durationMinutes: 30,
        limit: 2,
      );

      expect(slots, hasLength(2));
      expect(slots.first.startsAt, DateTime(2026, 9, 1, 10, 30));
      expect(slots.last.startsAt, DateTime(2026, 9, 1, 11));
    });
  });
}
