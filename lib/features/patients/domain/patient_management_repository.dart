import 'patient.dart';
import 'update_patient_input.dart';

abstract interface class PatientManagementRepository {
  Future<List<Patient>> fetchPatients();

  Future<Patient?> fetchPatientById({required String patientId});

  Future<Patient> updatePatient(UpdatePatientInput input);

  Future<void> archivePatient({required String patientId});
}
