import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/quick_create/domain/availability_slot.dart';
import 'package:lumeno/features/quick_create/domain/clinic.dart';
import 'package:lumeno/features/quick_create/domain/patient.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_context.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_inputs.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_intent.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_source.dart';
import 'package:lumeno/features/quick_create/domain/visit.dart';

void main() {
  test('visit and availability slot derive endsAt from duration', () {
    final startsAt = DateTime(2026, 9, 1, 10);
    final visit = Visit(
      id: 'visit-1',
      patientId: 'patient-1',
      clinicId: 'clinic-1',
      startsAt: startsAt,
      durationMinutes: 45,
      note: 'Follow-up',
    );
    final slot = AvailabilitySlot(startsAt: startsAt, durationMinutes: 30);

    expect(visit.endsAt, DateTime(2026, 9, 1, 10, 45));
    expect(slot.endsAt, DateTime(2026, 9, 1, 10, 30));
  });

  test('context preserves all supplied launch values', () {
    const patient = Patient(
      id: 'patient-1',
      name: 'Anna Petrova',
      phone: '+7 900 000-00-00',
      note: 'Prefers mornings',
    );
    const clinic = Clinic(id: 'clinic-1', name: 'Lumeno Central');
    final startsAt = DateTime(2026, 9, 1, 12, 30);

    final context = QuickCreateContext(
      intent: QuickCreateIntent.nextAvailableSlot,
      source: QuickCreateSource.dashboardAvailableSlot,
      patient: patient,
      clinic: clinic,
      startsAt: startsAt,
      durationMinutes: 60,
    );

    expect(context.patient, same(patient));
    expect(context.clinic, same(clinic));
    expect(context.startsAt, startsAt);
    expect(context.durationMinutes, 60);
  });

  test('create inputs expose trimmed validity', () {
    expect(
      const CreatePatientInput(name: '  Anna  ', phone: '', note: '').isValid,
      isFalse,
    );
    expect(const CreatePatientInput(name: '   ').isValid, isFalse);
    expect(
      const CreatePatientInput(name: 'Anna', phone: '123').isValid,
      isTrue,
    );
    expect(const CreateClinicInput(name: '  Central  ').isValid, isTrue);
    expect(const CreateClinicInput(name: '').isValid, isFalse);

    final visitInput = CreateVisitInput(
      patientId: 'patient-1',
      clinicId: 'clinic-1',
      startsAt: DateTime(2026, 9, 1, 10),
      durationMinutes: 30,
      note: '',
    );

    expect(visitInput.isValid, isTrue);
    expect(visitInput.endsAt, DateTime(2026, 9, 1, 10, 30));
  });
}
