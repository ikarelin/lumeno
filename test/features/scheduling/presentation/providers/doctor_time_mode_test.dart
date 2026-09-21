import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/profile/domain/doctor_profile.dart';
import 'package:lumeno/features/profile/presentation/providers/doctor_profile_provider.dart';
import 'package:lumeno/features/scheduling/presentation/providers/doctor_time_mode.dart';

void main() {
  test('doctor-zone mode is the default in all builds', () async {
    final container = ProviderContainer(
      overrides: [
        doctorProfileProvider.overrideWith(
          (ref) async => const DoctorProfile(
            userId: 'doctor-1',
            fullName: 'Doctor',
            specialty: 'General',
            timeZoneId: 'Asia/Tokyo',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final time = await container.read(calendarCivilTimeProvider.future);
    final visitInstant = DateTime.utc(2026, 9, 13, 23, 30);
    expect(enableDoctorTimeZoneInProduction, isTrue);
    expect(container.read(doctorTimeZoneEnabledProvider), isTrue);
    expect(time.doctorTime?.timeZoneId, 'Asia/Tokyo');
    expect(time.civilDayAt(visitInstant), DateTime(2026, 9, 14));
    expect(time.clockLabel(visitInstant), '08:30');
    expect(time.displayInstant(visitInstant).toUtc(), visitInstant);
  });

  test('legacy adapter remains available only through explicit test override', () async {
    final container = ProviderContainer(
      overrides: [
        doctorTimeZoneEnabledProvider.overrideWith((ref) => false),
        doctorProfileProvider.overrideWith((ref) async {
          throw StateError('Legacy test override must not fetch profile.');
        }),
      ],
    );
    addTearDown(container.dispose);
    final time = await container.read(calendarCivilTimeProvider.future);
    expect(time.doctorTime, isNull);
  });

  test('blank profile zone requests explicit setup by default', () async {
    final container = ProviderContainer(
      overrides: [
        doctorProfileProvider.overrideWith(
          (ref) async => const DoctorProfile(
            userId: 'doctor-2',
            fullName: 'Doctor',
            specialty: 'General',
            timeZoneId: '  ',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(calendarCivilTimeProvider.future),
      throwsA(isA<DoctorTimeZoneNotConfigured>()),
    );
  });

  test('missing profile zone fails closed by default', () async {
    final container = ProviderContainer(
      overrides: [
        doctorProfileProvider.overrideWith(
          (ref) async => const DoctorProfile(
            userId: 'doctor-1',
            fullName: 'Doctor',
            specialty: 'General',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(calendarCivilTimeProvider.future),
      throwsA(isA<DoctorTimeZoneNotConfigured>()),
    );
  });
}
