import 'availability_slot.dart';
import 'clinic.dart';
import 'patient.dart';
import 'quick_create_inputs.dart';
import 'visit.dart';

abstract interface class PatientRepository {
  Future<List<Patient>> searchPatients(String query);

  Future<Patient> createPatient(CreatePatientInput input);
}

abstract interface class ClinicRepository {
  Future<List<Clinic>> fetchClinics();

  Future<Clinic> createClinic(CreateClinicInput input);
}

abstract interface class VisitRepository {
  Future<Visit> createVisit(CreateVisitInput input);
}

abstract interface class AvailabilityRepository {
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  });
}
