
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/profile/domain/doctor_profile.dart';
import 'package:lumeno/features/profile/domain/doctor_profile_repository.dart';
import 'package:lumeno/features/scheduling/data/profile_visit_availability_repository.dart';
import 'package:lumeno/features/scheduling/domain/schedule_day_exception.dart';
import 'package:lumeno/features/scheduling/domain/schedule_day_exception_repository.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';

void main() {
  group('ProfileVisitAvailabilityRepository', () {
    group('findDayAvailability', () {
      test('returns continuous free intervals and the recurring break', () async {
        final visits = _FakeVisitQueryRepository([
          Visit(
            id: 'visit-1',
            patientId: 'patient-1',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 14, 10),
            durationMinutes: 30,
          ),
          Visit(
            id: 'visit-cancelled',
            patientId: 'patient-2',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 14, 11),
            durationMinutes: 30,
            status: VisitStatus.cancelled,
          ),
        ]);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(
              workingDays: const [DateTime.monday],
              workdayStart: '09:00',
              workdayEnd: '18:00',
              breakStart: '13:00',
              breakEnd: '14:00',
            ),
          ),
          visitQueryRepository: visits,
          now: () => DateTime(2026, 9, 14, 8),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );

        expect(day.isWorkingDay, isTrue);
        expect(day.breakIntervals, hasLength(1));
        expect(
          day.breakIntervals.single.startsAt,
          DateTime(2026, 9, 14, 13),
        );
        expect(
          day.breakIntervals.single.endsAt,
          DateTime(2026, 9, 14, 14),
        );
        expect(day.availableIntervals, hasLength(3));
        expect(
          day.availableIntervals[0].startsAt,
          DateTime(2026, 9, 14, 9),
        );
        expect(
          day.availableIntervals[0].endsAt,
          DateTime(2026, 9, 14, 10),
        );
        expect(
          day.availableIntervals[1].startsAt,
          DateTime(2026, 9, 14, 10, 30),
        );
        expect(
          day.availableIntervals[1].endsAt,
          DateTime(2026, 9, 14, 13),
        );
        expect(
          day.availableIntervals[2].startsAt,
          DateTime(2026, 9, 14, 14),
        );
        expect(
          day.availableIntervals[2].endsAt,
          DateTime(2026, 9, 14, 18),
        );
        expect(visits.lastFrom, DateTime(2026, 9, 14));
        expect(visits.lastTo, DateTime(2026, 9, 15));
      });

      test('keeps short free fragments for Calendar rendering', () async {
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(
              workingDays: const [DateTime.monday],
              workdayStart: '09:00',
              workdayEnd: '10:00',
              breakStart: null,
              breakEnd: null,
            ),
          ),
          visitQueryRepository: _FakeVisitQueryRepository([
            Visit(
              id: 'visit-1',
              patientId: 'patient-1',
              clinicId: 'clinic-1',
              startsAt: DateTime(2026, 9, 14, 9, 15),
              durationMinutes: 30,
            ),
          ]),
          now: () => DateTime(2026, 9, 14, 8),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );

        expect(day.availableIntervals, hasLength(2));
        expect(
          day.availableIntervals[0].duration,
          const Duration(minutes: 15),
        );
        expect(
          day.availableIntervals[1].duration,
          const Duration(minutes: 15),
        );
      });

      test('returns recurring day-off intervals split around Visits', () async {
        final visits = _FakeVisitQueryRepository([
          Visit(
            id: 'urgent-visit',
            patientId: 'patient-1',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 14, 10),
            durationMinutes: 30,
          ),
        ]);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(
              workingDays: const [DateTime.tuesday],
              workdayStart: '09:00',
              workdayEnd: '18:00',
            ),
          ),
          visitQueryRepository: visits,
          now: () => DateTime(2026, 9, 14, 8),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );

        expect(day.isWorkingDay, isFalse);
        expect(day.availableIntervals, isEmpty);
        expect(day.breakIntervals, isEmpty);
        expect(day.dayOffIntervals, hasLength(2));
        expect(
          day.dayOffIntervals[0].startsAt,
          DateTime(2026, 9, 14, 9),
        );
        expect(
          day.dayOffIntervals[0].endsAt,
          DateTime(2026, 9, 14, 10),
        );
        expect(
          day.dayOffIntervals[1].startsAt,
          DateTime(2026, 9, 14, 10, 30),
        );
        expect(
          day.dayOffIntervals[1].endsAt,
          DateTime(2026, 9, 14, 18),
        );
        expect(visits.fetchCalls, 1);
      });

      test('splits a recurring Break around an override Visit', () async {
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(
              workingDays: const [DateTime.monday],
              workdayStart: '09:00',
              workdayEnd: '18:00',
              breakStart: '13:00',
              breakEnd: '14:00',
            ),
          ),
          visitQueryRepository: _FakeVisitQueryRepository([
            Visit(
              id: 'urgent-visit',
              patientId: 'patient-1',
              clinicId: 'clinic-1',
              startsAt: DateTime(2026, 9, 14, 13, 15),
              durationMinutes: 30,
            ),
          ]),
          now: () => DateTime(2026, 9, 14, 8),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );

        expect(day.breakIntervals, hasLength(2));
        expect(
          day.breakIntervals[0].startsAt,
          DateTime(2026, 9, 14, 13),
        );
        expect(
          day.breakIntervals[0].endsAt,
          DateTime(2026, 9, 14, 13, 15),
        );
        expect(
          day.breakIntervals[1].startsAt,
          DateTime(2026, 9, 14, 13, 45),
        );
        expect(
          day.breakIntervals[1].endsAt,
          DateTime(2026, 9, 14, 14),
        );
      });

      test('one-date exception can turn a recurring workday into Day off', () async {
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(workingDays: const [DateTime.monday]),
          ),
          visitQueryRepository: _FakeVisitQueryRepository(const []),
          scheduleDayExceptionRepository: _FakeScheduleDayExceptionRepository([
            ScheduleDayException(
              day: DateTime(2026, 9, 14),
              isWorkingDay: false,
            ),
          ]),
          now: () => DateTime(2026, 9, 14, 8),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );

        expect(day.isWorkingDay, isFalse);
        expect(day.availableIntervals, isEmpty);
        expect(day.dayOffIntervals, hasLength(1));
        expect(day.dayOffIntervals.single.startsAt, DateTime(2026, 9, 14, 9));
        expect(day.dayOffIntervals.single.endsAt, DateTime(2026, 9, 14, 18));
      });

      test('one-date exception can turn a recurring Day off into working day', () async {
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(workingDays: const [DateTime.tuesday]),
          ),
          visitQueryRepository: _FakeVisitQueryRepository(const []),
          scheduleDayExceptionRepository: _FakeScheduleDayExceptionRepository([
            ScheduleDayException(
              day: DateTime(2026, 9, 14),
              isWorkingDay: true,
            ),
          ]),
          now: () => DateTime(2026, 9, 14, 8),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );

        expect(day.isWorkingDay, isTrue);
        expect(day.availableIntervals, hasLength(2));
        expect(day.breakIntervals, hasLength(1));
      });

      test('does not expose past free time for today', () async {
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(
              workingDays: const [DateTime.monday],
              breakStart: null,
              breakEnd: null,
            ),
          ),
          visitQueryRepository: _FakeVisitQueryRepository(const []),
          now: () => DateTime(2026, 9, 14, 10, 20),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );

        expect(
          day.availableIntervals.single.startsAt,
          DateTime(2026, 9, 14, 10, 20),
        );
      });
    });

    group('findRangeAvailability', () {
      test('loads profile, Visits, and exceptions once for the whole range', () async {
        final visits = _FakeVisitQueryRepository([
          Visit(
            id: 'visit-1',
            patientId: 'patient-1',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 14, 10),
            durationMinutes: 30,
          ),
        ]);
        final exceptions = _FakeScheduleDayExceptionRepository([
          ScheduleDayException(
            day: DateTime(2026, 9, 15),
            isWorkingDay: false,
          ),
          ScheduleDayException(
            day: DateTime(2026, 9, 16),
            isWorkingDay: true,
          ),
        ]);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(workingDays: const [DateTime.monday, DateTime.tuesday]),
          ),
          visitQueryRepository: visits,
          scheduleDayExceptionRepository: exceptions,
          now: () => DateTime(2026, 9, 14, 8),
        );

        final days = await repository.findRangeAvailability(
          from: DateTime(2026, 9, 14),
          to: DateTime(2026, 9, 17),
        );

        expect(days, hasLength(3));
        expect(days.map((day) => day.isWorkingDay), [true, false, true]);
        expect(days.first.availableIntervals, hasLength(3));
        expect(visits.fetchCalls, 1);
        expect(visits.lastFrom, DateTime(2026, 9, 14));
        expect(visits.lastTo, DateTime(2026, 9, 17));
        expect(exceptions.rangeFetchCalls, 1);
        expect(exceptions.lastRangeFrom, DateTime(2026, 9, 14));
        expect(exceptions.lastRangeTo, DateTime(2026, 9, 17));
      });
    });

    test('uses recurring work hours, break, and scheduled Visits', () async {
      final profileRepository = _FakeProfileRepository(
        _profile(
          workingDays: const [DateTime.monday],
          workdayStart: '09:00:00',
          workdayEnd: '18:00:00',
          breakStart: '13:00:00',
          breakEnd: '14:00:00',
        ),
      );
      final visitRepository = _FakeVisitQueryRepository([
        Visit(
          id: 'visit-1',
          patientId: 'patient-1',
          clinicId: 'clinic-1',
          startsAt: DateTime(2026, 9, 14, 10),
          durationMinutes: 30,
        ),
      ]);
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: profileRepository,
        visitQueryRepository: visitRepository,
        now: () => DateTime(2026, 9, 14, 8),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 8),
        durationMinutes: 30,
        limit: 6,
      );

      expect(
        slots.map((slot) => slot.startsAt),
        [
          DateTime(2026, 9, 14, 9),
          DateTime(2026, 9, 14, 9, 30),
          DateTime(2026, 9, 14, 10, 30),
          DateTime(2026, 9, 14, 11),
          DateTime(2026, 9, 14, 11, 30),
          DateTime(2026, 9, 14, 12),
        ],
      );
      expect(slots.every((slot) => slot.durationMinutes == 30), isTrue);
    });

    test(
      'can exclude only the Visit being moved from availability',
      () async {
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(
              workingDays: const [DateTime.monday],
              breakStart: null,
              breakEnd: null,
            ),
          ),
          visitQueryRepository: _FakeVisitQueryRepository([
            Visit(
              id: 'current-visit',
              patientId: 'patient-1',
              clinicId: 'clinic-1',
              startsAt: DateTime(2026, 9, 14, 10),
              durationMinutes: 30,
            ),
            Visit(
              id: 'other-visit',
              patientId: 'patient-2',
              clinicId: 'clinic-1',
              startsAt: DateTime(2026, 9, 14, 11),
              durationMinutes: 30,
            ),
          ]),
          excludedVisitId: 'current-visit',
          now: () => DateTime(2026, 9, 14, 8),
        );

        final slots = await repository.findAvailableSlots(
          from: DateTime(2026, 9, 14, 9),
          durationMinutes: 30,
          limit: 6,
        );

        expect(
          slots.map((slot) => slot.startsAt),
          [
            DateTime(2026, 9, 14, 9),
            DateTime(2026, 9, 14, 9, 30),
            DateTime(2026, 9, 14, 10),
            DateTime(2026, 9, 14, 10, 30),
            DateTime(2026, 9, 14, 11, 30),
            DateTime(2026, 9, 14, 12),
          ],
        );
      },
    );

    test('slot search respects one-date working overrides', () async {
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: _FakeProfileRepository(
          _profile(workingDays: const [DateTime.monday]),
        ),
        visitQueryRepository: _FakeVisitQueryRepository(const []),
        scheduleDayExceptionRepository: _FakeScheduleDayExceptionRepository([
          ScheduleDayException(
            day: DateTime(2026, 9, 14),
            isWorkingDay: false,
          ),
          ScheduleDayException(
            day: DateTime(2026, 9, 15),
            isWorkingDay: true,
          ),
        ]),
        now: () => DateTime(2026, 9, 14, 8),
        searchHorizonDays: 2,
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 8),
        durationMinutes: 30,
        limit: 1,
      );

      expect(slots.single.startsAt, DateTime(2026, 9, 15, 9));
    });

    test('cancelled Visit does not occupy availability', () async {
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: _FakeProfileRepository(
          _profile(workingDays: const [DateTime.monday]),
        ),
        visitQueryRepository: _FakeVisitQueryRepository([
          Visit(
            id: 'visit-cancelled',
            patientId: 'patient-1',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 14, 9),
            durationMinutes: 30,
            status: VisitStatus.cancelled,
          ),
        ]),
        now: () => DateTime(2026, 9, 14, 8),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 8),
        durationMinutes: 30,
        limit: 1,
      );

      expect(slots.single.startsAt, DateTime(2026, 9, 14, 9));
    });

    test('never returns availability before current time', () async {
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: _FakeProfileRepository(
          _profile(workingDays: const [DateTime.monday]),
        ),
        visitQueryRepository: _FakeVisitQueryRepository(const []),
        now: () => DateTime(2026, 9, 14, 10, 20),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 9),
        durationMinutes: 30,
        limit: 2,
      );

      expect(slots.first.startsAt, DateTime(2026, 9, 14, 10, 30));
      expect(slots[1].startsAt, DateTime(2026, 9, 14, 11));
    });

    test('scans forward to the next configured working day', () async {
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: _FakeProfileRepository(
          _profile(workingDays: const [DateTime.tuesday]),
        ),
        visitQueryRepository: _FakeVisitQueryRepository(const []),
        now: () => DateTime(2026, 9, 14, 8),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 8),
        durationMinutes: 30,
        limit: 1,
      );

      expect(slots.single.startsAt, DateTime(2026, 9, 15, 9));
    });

    test('uses 15-minute precision for deliberate 15-minute Visit', () async {
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: _FakeProfileRepository(
          _profile(
            workingDays: const [DateTime.monday],
            defaultDurationMinutes: 60,
          ),
        ),
        visitQueryRepository: _FakeVisitQueryRepository(const []),
        now: () => DateTime(2026, 9, 14, 9, 1),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 9, 1),
        durationMinutes: 15,
        limit: 2,
      );

      expect(slots.first.startsAt, DateTime(2026, 9, 14, 9, 15));
      expect(slots[1].startsAt, DateTime(2026, 9, 14, 9, 30));
    });

    test('queries Visits using local calendar-day boundaries', () async {
      final visits = _FakeVisitQueryRepository(const []);
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: _FakeProfileRepository(
          _profile(workingDays: const [DateTime.monday]),
        ),
        visitQueryRepository: visits,
        now: () => DateTime(2026, 9, 14, 8),
        searchHorizonDays: 3,
      );

      await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 12, 45),
        durationMinutes: 30,
      );

      expect(visits.lastFrom, DateTime(2026, 9, 14));
      expect(visits.lastTo, DateTime(2026, 9, 17));
    });

    group('doctor IANA zone (opt-in)', () {
      test('keeps legacy callers unchanged until the presentation switches', () async {
        final visits = _FakeVisitQueryRepository(const []);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(timeZoneId: 'Europe/Moscow',
              workingDays: const [DateTime.monday],
              breakStart: null, breakEnd: null),
          ),
          visitQueryRepository: visits,
          now: () => DateTime(2026, 9, 14, 8),
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );
        expect(day.availableIntervals.single.startsAt, DateTime(2026, 9, 14, 9));
        expect(visits.lastFrom, DateTime(2026, 9, 14));
      });

      test('requires an explicitly configured IANA zone when enabled', () async {
        final visits = _FakeVisitQueryRepository(const []);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(_profile(timeZoneId: null)),
          visitQueryRepository: visits,
          useDoctorTimeZone: true,
        );

        await expectLater(
          repository.findDayAvailability(day: DateTime(2026, 9, 14)),
          throwsStateError,
        );
        expect(visits.fetchCalls, 0);
      });

      test('Moscow day queries UTC boundaries and subtracts a UTC Visit', () async {
        final visits = _FakeVisitQueryRepository([
          Visit(
            id: 'visit-utc', patientId: 'patient-1', clinicId: 'clinic-1',
            startsAt: DateTime.utc(2026, 9, 14, 7), durationMinutes: 30,
          ),
        ]);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(timeZoneId: 'Europe/Moscow',
              workingDays: const [DateTime.monday],
              breakStart: null, breakEnd: null),
          ),
          visitQueryRepository: visits,
          now: () => DateTime.utc(2026, 9, 14, 4),
          useDoctorTimeZone: true,
        );

        final day = await repository.findDayAvailability(
          day: DateTime(2026, 9, 14),
        );
        expect(day.day, DateTime(2026, 9, 14));
        expect(visits.lastFrom, DateTime.utc(2026, 9, 13, 21));
        expect(visits.lastTo, DateTime.utc(2026, 9, 14, 21));
        expect(day.availableIntervals, hasLength(2));
        expect(day.availableIntervals.first.startsAt, DateTime.utc(2026, 9, 14, 6));
        expect(day.availableIntervals.first.endsAt, DateTime.utc(2026, 9, 14, 7));
        expect(day.availableIntervals.last.startsAt, DateTime.utc(2026, 9, 14, 7, 30));
        expect(day.availableIntervals.last.endsAt, DateTime.utc(2026, 9, 14, 15));
        expect(day.availableIntervals.every((interval) => interval.startsAt.isUtc), isTrue);
      });

      test('range queries preserve date exceptions but fetch UTC instants', () async {
        final visits = _FakeVisitQueryRepository(const []);
        final exceptions = _FakeScheduleDayExceptionRepository([
          ScheduleDayException(day: DateTime(2026, 9, 15), isWorkingDay: false),
        ]);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(timeZoneId: 'Europe/Moscow',
              workingDays: const [DateTime.monday, DateTime.tuesday]),
          ),
          visitQueryRepository: visits,
          scheduleDayExceptionRepository: exceptions,
          now: () => DateTime.utc(2026, 9, 13, 5),
          useDoctorTimeZone: true,
        );

        final days = await repository.findRangeAvailability(
          from: DateTime(2026, 9, 14), to: DateTime(2026, 9, 16),
        );
        expect(days.map((day) => day.isWorkingDay), [true, false]);
        expect(visits.fetchCalls, 1);
        expect(visits.lastFrom, DateTime.utc(2026, 9, 13, 21));
        expect(visits.lastTo, DateTime.utc(2026, 9, 15, 21));
        expect(exceptions.lastRangeFrom, DateTime(2026, 9, 14));
        expect(exceptions.lastRangeTo, DateTime(2026, 9, 16));
        expect(days.first.availableIntervals.first.startsAt, DateTime.utc(2026, 9, 14, 6));
      });

      test('Amsterdam spring-forward day is 23 hours with real work clock', () async {
        final visits = _FakeVisitQueryRepository(const []);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(timeZoneId: 'Europe/Amsterdam',
              workingDays: const [DateTime.sunday],
              workdayStart: '00:00', workdayEnd: '04:00',
              breakStart: null, breakEnd: null),
          ),
          visitQueryRepository: visits,
          now: () => DateTime.utc(2026, 3, 28, 21),
          useDoctorTimeZone: true,
        );
        final day = await repository.findDayAvailability(
          day: DateTime(2026, 3, 29),
        );
        expect(visits.lastFrom, DateTime.utc(2026, 3, 28, 23));
        expect(visits.lastTo, DateTime.utc(2026, 3, 29, 22));
        expect(day.availableIntervals.single.startsAt, DateTime.utc(2026, 3, 28, 23));
        expect(day.availableIntervals.single.endsAt, DateTime.utc(2026, 3, 29, 2));
        expect(day.availableIntervals.single.duration, const Duration(hours: 3));
      });

      test('Amsterdam fall-back day is 25 hours with real work clock', () async {
        final visits = _FakeVisitQueryRepository(const []);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(timeZoneId: 'Europe/Amsterdam',
              workingDays: const [DateTime.sunday],
              workdayStart: '00:00', workdayEnd: '04:00',
              breakStart: null, breakEnd: null),
          ),
          visitQueryRepository: visits,
          now: () => DateTime.utc(2026, 10, 24, 21),
          useDoctorTimeZone: true,
        );
        final day = await repository.findDayAvailability(
          day: DateTime(2026, 10, 25),
        );
        expect(visits.lastFrom, DateTime.utc(2026, 10, 24, 22));
        expect(visits.lastTo, DateTime.utc(2026, 10, 25, 23));
        expect(day.availableIntervals.single.startsAt, DateTime.utc(2026, 10, 24, 22));
        expect(day.availableIntervals.single.endsAt, DateTime.utc(2026, 10, 25, 3));
        expect(day.availableIntervals.single.duration, const Duration(hours: 5));
      });

      test('Nepal +05:45 aligns suggestion precision to doctor clock', () async {
        final visits = _FakeVisitQueryRepository(const []);
        final repository = ProfileVisitAvailabilityRepository(
          profileRepository: _FakeProfileRepository(
            _profile(timeZoneId: 'Asia/Kathmandu',
              workingDays: const [DateTime.monday],
              breakStart: null, breakEnd: null),
          ),
          visitQueryRepository: visits,
          now: () => DateTime.utc(2026, 9, 14, 2),
          useDoctorTimeZone: true,
        );
        final slots = await repository.findAvailableSlots(
          from: DateTime.utc(2026, 9, 14, 2),
          durationMinutes: 30, limit: 2,
        );
        expect(slots.map((slot) => slot.startsAt), [
          DateTime.utc(2026, 9, 14, 3, 15),
          DateTime.utc(2026, 9, 14, 3, 45),
        ]);
        expect(visits.lastFrom, DateTime.utc(2026, 9, 13, 18, 15));
        expect(visits.lastTo, DateTime.utc(2026, 10, 13, 18, 15));
      });
    });

    test('returns no slots when current Doctor Profile is unavailable', () async {
      final visits = _FakeVisitQueryRepository(const []);
      final repository = ProfileVisitAvailabilityRepository(
        profileRepository: _FakeProfileRepository(null),
        visitQueryRepository: visits,
        now: () => DateTime(2026, 9, 14, 8),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 8),
        durationMinutes: 30,
      );

      expect(slots, isEmpty);
      expect(visits.fetchCalls, 0);
    });
  });
}

DoctorProfile _profile({
  List<int> workingDays = const [1, 2, 3, 4, 5],
  int defaultDurationMinutes = 30,
  String workdayStart = '09:00',
  String workdayEnd = '18:00',
  String? breakStart = '13:00',
  String? breakEnd = '14:00',
  String? timeZoneId,
}) {
  return DoctorProfile(
    userId: 'doctor-1',
    fullName: 'Dr Test',
    specialty: 'Dentist',
    timeZoneId: timeZoneId,
    defaultDurationMinutes: defaultDurationMinutes,
    workingDays: workingDays,
    workdayStart: workdayStart,
    workdayEnd: workdayEnd,
    breakStart: breakStart,
    breakEnd: breakEnd,
  );
}

class _FakeProfileRepository implements DoctorProfileRepository {
  _FakeProfileRepository(this.profile);

  final DoctorProfile? profile;

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

class _FakeVisitQueryRepository implements VisitQueryRepository {
  _FakeVisitQueryRepository(this.visits);

  final List<Visit> visits;
  int fetchCalls = 0;
  DateTime? lastFrom;
  DateTime? lastTo;

  @override
  Future<List<Visit>> fetchVisits({
    required DateTime from,
    required DateTime to,
  }) async {
    fetchCalls += 1;
    lastFrom = from;
    lastTo = to;
    return visits;
  }
}

class _FakeScheduleDayExceptionRepository
    implements ScheduleDayExceptionRepository {
  _FakeScheduleDayExceptionRepository(this.exceptions);

  final List<ScheduleDayException> exceptions;
  int rangeFetchCalls = 0;
  DateTime? lastRangeFrom;
  DateTime? lastRangeTo;

  @override
  Future<ScheduleDayException?> fetchForDay({required DateTime day}) async {
    for (final exception in exceptions) {
      if (_sameDay(exception.day, day)) {
        return exception;
      }
    }
    return null;
  }

  @override
  Future<List<ScheduleDayException>> fetchForRange({
    required DateTime from,
    required DateTime to,
  }) async {
    rangeFetchCalls += 1;
    lastRangeFrom = from;
    lastRangeTo = to;
    return exceptions
        .where((exception) =>
            !exception.day.isBefore(from) && exception.day.isBefore(to))
        .toList(growable: false);
  }

  @override
  Future<ScheduleDayException> setWorkingDay({
    required DateTime day,
    required bool isWorkingDay,
  }) {
    throw UnimplementedError();
  }

  bool _sameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
