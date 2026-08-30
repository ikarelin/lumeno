import 'doctor_profile.dart';

abstract interface class DoctorProfileRepository {
  Future<DoctorProfile?> fetchCurrentProfile();

  Future<DoctorProfile> saveCurrentProfile({
    required String fullName,
    required String specialty,
  });
}
