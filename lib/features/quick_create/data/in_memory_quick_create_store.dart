import '../domain/availability_slot.dart';
import '../domain/clinic.dart';
import '../domain/patient.dart';
import '../domain/quick_create_inputs.dart';
import '../domain/quick_create_repositories.dart';
import '../domain/visit.dart';

class InMemoryQuickCreateStore
    implements
        PatientRepository,
        ClinicRepository,
        VisitRepository,
        AvailabilityRepository {
  InMemoryQuickCreateStore({
    List<Patient> patients = const [],
    List<Clinic> clinics = const [],
    List<Visit> visits = const [],
  }) : _patients = [...patients],
       _clinics = [...clinics],
       _visits = [...visits];

  factory InMemoryQuickCreateStore.seeded() {
    return InMemoryQuickCreateStore(
      patients: const [
        Patient(
          id: 'patient-1',
          name: 'Anna Brown',
          phone: '+1 202 555 0147',
          note: 'Prefers morning visits',
        ),
        Patient(
          id: 'patient-2',
          name: 'Michael Wilson',
          phone: '+1 202 555 0184',
        ),
        Patient(id: 'patient-3', name: 'Emma Davis', phone: '+1 202 555 0119'),
      ],
      clinics: const [
        Clinic(id: 'clinic-1', name: 'Lumeno Dental Center'),
        Clinic(id: 'clinic-2', name: 'Riverside Clinic'),
      ],
    );
  }

  final List<Patient> _patients;
  final List<Clinic> _clinics;
  final List<Visit> _visits;

  int _patientSequence = 100;
  int _clinicSequence = 100;
  int _visitSequence = 100;

  @override
  Future<List<Patient>> searchPatients(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return List.unmodifiable(_patients);
    }

    return List.unmodifiable(
      _patients.where((patient) {
        return patient.name.toLowerCase().contains(normalizedQuery) ||
            patient.phone.toLowerCase().contains(normalizedQuery);
      }),
    );
  }

  @override
  Future<Patient> createPatient(CreatePatientInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Patient name and phone are required');
    }

    final patient = Patient(
      id: 'patient-${_patientSequence++}',
      name: input.name.trim(),
      phone: input.phone.trim(),
      note: input.note.trim(),
    );

    _patients.add(patient);
    return patient;
  }

  @override
  Future<List<Clinic>> fetchClinics() async {
    return List.unmodifiable(_clinics);
  }

  @override
  Future<Clinic> createClinic(CreateClinicInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Clinic name is required');
    }

    final clinic = Clinic(
      id: 'clinic-${_clinicSequence++}',
      name: input.name.trim(),
    );

    _clinics.add(clinic);
    return clinic;
  }

  @override
  Future<Visit> createVisit(CreateVisitInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Patient, clinic, time and duration are required');
    }

    final visit = Visit(
      id: 'visit-${_visitSequence++}',
      patientId: input.patientId,
      clinicId: input.clinicId,
      startsAt: input.startsAt,
      durationMinutes: input.durationMinutes,
      note: input.note.trim(),
    );

    _visits.add(visit);
    return visit;
  }

  @override
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  }) async {
    final slots = <AvailabilitySlot>[];
    var candidate = _roundUpToHalfHour(from);

    while (slots.length < limit) {
      final slot = AvailabilitySlot(
        startsAt: candidate,
        durationMinutes: durationMinutes,
      );

      final overlaps = _visits.any((visit) {
        return slot.startsAt.isBefore(visit.endsAt) &&
            slot.endsAt.isAfter(visit.startsAt);
      });

      if (!overlaps) {
        slots.add(slot);
      }

      candidate = candidate.add(const Duration(minutes: 30));
    }

    return slots;
  }

  DateTime _roundUpToHalfHour(DateTime value) {
    final base = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute >= 30 ? 30 : 0,
    );

    if (base.isBefore(value)) {
      return base.add(const Duration(minutes: 30));
    }

    return base;
  }
}
