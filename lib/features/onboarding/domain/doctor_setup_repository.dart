abstract interface class DoctorSetupRepository {
  Future<void> completeDoctorSetup({
    required String doctorName,
    required String specialty,
  });
}
