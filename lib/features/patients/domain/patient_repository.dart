import 'create_patient_input.dart';
import 'patient.dart';

abstract interface class PatientRepository {
  Future<List<Patient>> searchPatients(String query);

  Future<Patient> createPatient(CreatePatientInput input);
}
