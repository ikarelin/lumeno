import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/profile/domain/doctor_profile.dart';

void main() {
  test('existing doctor profiles have no inferred time zone', () {
    const profile = DoctorProfile(
      userId: 'doctor-1',
      fullName: 'Dr Test',
      specialty: 'Dentist',
    );

    expect(profile.timeZoneId, isNull);
    expect(profile.workdayStart, '09:00');
    expect(profile.workingDays, [1, 2, 3, 4, 5]);
  });

  test('copyWith preserves time zone across unrelated profile changes', () {
    const profile = DoctorProfile(
      userId: 'doctor-1',
      fullName: 'Dr Test',
      specialty: 'Dentist',
      timeZoneId: 'Europe/Moscow',
    );

    final updated = profile.copyWith(fullName: 'Dr Updated');

    expect(updated.timeZoneId, 'Europe/Moscow');
    expect(updated.fullName, 'Dr Updated');
    expect(updated.workdayStart, profile.workdayStart);
  });

  test('copyWith can set an explicitly chosen IANA time zone', () {
    const profile = DoctorProfile(
      userId: 'doctor-1',
      fullName: 'Dr Test',
      specialty: 'Dentist',
    );

    expect(profile.copyWith(timeZoneId: 'Asia/Tokyo').timeZoneId, 'Asia/Tokyo');
  });
}
