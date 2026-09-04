import 'clinic.dart';
import 'create_clinic_input.dart';

abstract interface class ClinicRepository {
  Future<List<Clinic>> fetchClinics();

  Future<Clinic> createClinic(CreateClinicInput input);
}
