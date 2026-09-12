import 'doctor_profile.dart';

abstract interface class DoctorProfileRepository {
  Future<DoctorProfile?> fetchCurrentProfile();

  Future<DoctorProfile> saveCurrentProfile({
    required String fullName,
    required String specialty,
    required int defaultDurationMinutes,
    required List<int> workingDays,
    required String workdayStart,
    required String workdayEnd,
    required String? breakStart,
    required String? breakEnd,
  });
}
