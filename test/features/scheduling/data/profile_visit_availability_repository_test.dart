import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/profile/domain/doctor_profile.dart';
import 'package:lumeno/features/profile/domain/doctor_profile_repository.dart';
import 'package:lumeno/features/scheduling/data/profile_visit_availability_repository.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';

void main() {
  group('ProfileVisitAvailabilityRepository', () {
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
}) {
  return DoctorProfile(
    userId: 'doctor-1',
    fullName: 'Dr Test',
    specialty: 'Dentist',
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
