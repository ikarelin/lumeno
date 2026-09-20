import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/calendar/presentation/controllers/calendar_day_controller.dart';
import 'package:lumeno/features/profile/domain/doctor_profile.dart';
import 'package:lumeno/features/profile/domain/doctor_profile_repository.dart';
import 'package:lumeno/features/profile/presentation/providers/doctor_profile_provider.dart';
import 'package:lumeno/features/scheduling/domain/availability_day.dart';
import 'package:lumeno/features/scheduling/domain/availability_day_repository.dart';
import 'package:lumeno/features/scheduling/domain/schedule_day_exception.dart';
import 'package:lumeno/features/scheduling/domain/schedule_day_exception_repository.dart';
import 'package:lumeno/features/scheduling/presentation/providers/availability_provider.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';
import 'package:lumeno/features/visits/presentation/providers/visit_provider.dart';

void main() {
  test('Calendar Day returns Visits in chronological order', () async {
    final repository = _FakeVisitQueryRepository(
      visits: [
        _visit(id: 'visit-3', hour: 15),
        _visit(id: 'visit-1', hour: 9),
        _visit(id: 'visit-2', hour: 11),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        visitQueryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final selectedDate = DateTime(2026, 9, 15);
    final visits = await container.read(
      calendarDayVisitsProvider(selectedDate).future,
    );

    expect(
      visits.map((visit) => visit.id),
      ['visit-1', 'visit-2', 'visit-3'],
    );
    expect(repository.lastFrom, DateTime(2026, 9, 15));
    expect(repository.lastTo, DateTime(2026, 9, 16));
  });
  test(
    'Calendar Day refreshes availability when Profile scheduling changes',
    () async {
      final profileRepository = _MutableProfileRepository(
        _profile(workingDays: const [1, 2, 3, 5]),
      );
      final visitRepository = _FakeVisitQueryRepository(visits: const []);
      final container = ProviderContainer(
        overrides: [
          doctorProfileRepositoryProvider.overrideWithValue(profileRepository),
          visitQueryRepositoryProvider.overrideWithValue(visitRepository),
          scheduleDayExceptionRepositoryProvider.overrideWithValue(
            _NoopScheduleDayExceptionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final thursday = DateTime(2030, 1, 3);

      final before = await container.read(
        calendarDayAvailabilityProvider(thursday).future,
      );
      expect(before.isWorkingDay, isFalse);

      profileRepository.profile = _profile(
        workingDays: const [1, 2, 3, 4, 5],
      );
      container.invalidate(doctorProfileProvider);

      // This mirrors ProfilePage after a successful save: the profile provider
      // is refreshed, and the scheduling dependency must invalidate Calendar.
      await container.read(doctorProfileProvider.future);

      final after = await container.read(
        calendarDayAvailabilityProvider(thursday).future,
      );
      expect(after.isWorkingDay, isTrue);
    },
  );

  test('Calendar Day loads shared availability for the normalized day', () async {
    final repository = _FakeAvailabilityDayRepository();
    final container = ProviderContainer(
      overrides: [
        availabilityDayRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final availability = await container.read(
      calendarDayAvailabilityProvider(
        DateTime(2026, 9, 15, 17, 45),
      ).future,
    );

    expect(repository.lastDay, DateTime(2026, 9, 15));
    expect(availability.day, DateTime(2026, 9, 15));
    expect(availability.isWorkingDay, isTrue);
  });
}

Visit _visit({
  required String id,
  required int hour,
}) {
  return Visit(
    id: id,
    patientId: 'patient-$id',
    clinicId: 'clinic-1',
    startsAt: DateTime(2026, 9, 15, hour),
    durationMinutes: 30,
  );
}

class _FakeVisitQueryRepository implements VisitQueryRepository {
  _FakeVisitQueryRepository({required this.visits});

  final List<Visit> visits;

  DateTime? lastFrom;
  DateTime? lastTo;

  @override
  Future<List<Visit>> fetchVisits({
    required DateTime from,
    required DateTime to,
  }) async {
    lastFrom = from;
    lastTo = to;
    return visits;
  }
}


DoctorProfile _profile({required List<int> workingDays}) {
  return DoctorProfile(
    userId: 'doctor-1',
    fullName: 'Dr Test',
    specialty: 'Dentist',
    defaultDurationMinutes: 60,
    workingDays: workingDays,
    workdayStart: '09:00',
    workdayEnd: '18:00',
    breakStart: '13:00',
    breakEnd: '14:00',
  );
}

class _MutableProfileRepository implements DoctorProfileRepository {
  _MutableProfileRepository(this.profile);

  DoctorProfile profile;

  @override
  Future<DoctorProfile?> fetchCurrentProfile() async => profile;

  @override
  Future<DoctorProfile> saveCurrentProfile({
    required String fullName,
    required String specialty,
    required String? timeZoneId,
    required int defaultDurationMinutes,
    required List<int> workingDays,
    required String workdayStart,
    required String workdayEnd,
    required String? breakStart,
    required String? breakEnd,
  }) {
    throw UnimplementedError();
  }
}

class _NoopScheduleDayExceptionRepository
    implements ScheduleDayExceptionRepository {
  @override
  Future<ScheduleDayException?> fetchForDay({
    required DateTime day,
  }) async {
    return null;
  }

  @override
  Future<List<ScheduleDayException>> fetchForRange({
    required DateTime from,
    required DateTime to,
  }) async {
    return const [];
  }

  @override
  Future<ScheduleDayException> setWorkingDay({
    required DateTime day,
    required bool isWorkingDay,
  }) {
    throw UnimplementedError();
  }
}

class _FakeAvailabilityDayRepository implements AvailabilityDayRepository {
  DateTime? lastDay;

  @override
  Future<AvailabilityDay> findDayAvailability({
    required DateTime day,
  }) async {
    lastDay = day;
    return AvailabilityDay(
      day: day,
      isWorkingDay: true,
    );
  }
}
