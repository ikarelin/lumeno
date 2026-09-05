import 'clinic.dart';
import 'update_clinic_input.dart';

abstract interface class ClinicManagementRepository {
  Future<Clinic> updateClinic(UpdateClinicInput input);

  Future<void> archiveClinicMembership({required String clinicId});
}
