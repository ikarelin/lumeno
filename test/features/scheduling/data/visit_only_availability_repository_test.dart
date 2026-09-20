import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/profile/domain/doctor_profile.dart';
import 'package:lumeno/features/profile/domain/doctor_profile_repository.dart';
import 'package:lumeno/features/scheduling/data/visit_only_availability_repository.dart';
import 'package:lumeno/features/scheduling/domain/availability_interval.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';

void main() {
  group('VisitOnlyAvailabilityRepository', () {
    test('offers starts inside the explicit override interval only', () async {
      final repository = VisitOnlyAvailabilityRepository(
        profileRepository: _FakeProfileRepository(_profile()),
        visitQueryRepository: _FakeVisitQueryRepository(const []),
        allowedInterval: AvailabilityInterval(
          startsAt: DateTime(2026, 9, 14, 13),
          endsAt: DateTime(2026, 9, 14, 14),
        ),
        now: () => DateTime(2026, 9, 14, 12),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 12),
        durationMinutes: 30,
        limit: 8,
      );

      expect(
        slots.map((slot) => slot.startsAt),
        [
          DateTime(2026, 9, 14, 13),
          DateTime(2026, 9, 14, 13, 30),
        ],
      );
    });

    test('uses the doctor profile default cadence during override', () async {
      final repository = VisitOnlyAvailabilityRepository(
        profileRepository: _FakeProfileRepository(
          _profile(defaultDurationMinutes: 60),
        ),
        visitQueryRepository: _FakeVisitQueryRepository(const []),
        allowedInterval: AvailabilityInterval(
          startsAt: DateTime(2026, 9, 14, 9),
          endsAt: DateTime(2026, 9, 14, 13),
        ),
        now: () => DateTime(2026, 9, 14, 8),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 8),
        durationMinutes: 60,
        limit: 8,
      );

      expect(
        slots.map((slot) => slot.startsAt),
        [
          DateTime(2026, 9, 14, 9),
          DateTime(2026, 9, 14, 10),
          DateTime(2026, 9, 14, 11),
          DateTime(2026, 9, 14, 12),
        ],
      );
    });

    test('scheduled Visits remain hard conflicts during override', () async {
      final repository = VisitOnlyAvailabilityRepository(
        profileRepository: _FakeProfileRepository(_profile()),
        visitQueryRepository: _FakeVisitQueryRepository([
          Visit(
            id: 'existing',
            patientId: 'patient-1',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 14, 13, 15),
            durationMinutes: 30,
          ),
        ]),
        allowedInterval: AvailabilityInterval(
          startsAt: DateTime(2026, 9, 14, 13),
          endsAt: DateTime(2026, 9, 14, 14),
        ),
        now: () => DateTime(2026, 9, 14, 12),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 12),
        durationMinutes: 15,
        limit: 8,
      );

      expect(
        slots.map((slot) => slot.startsAt),
        [
          DateTime(2026, 9, 14, 13),
          DateTime(2026, 9, 14, 13, 45),
        ],
      );
    });

    test('cancelled Visits do not block an explicit override', () async {
      final repository = VisitOnlyAvailabilityRepository(
        profileRepository: _FakeProfileRepository(_profile()),
        visitQueryRepository: _FakeVisitQueryRepository([
          Visit(
            id: 'cancelled',
            patientId: 'patient-1',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 14, 13),
            durationMinutes: 30,
            status: VisitStatus.cancelled,
          ),
        ]),
        allowedInterval: AvailabilityInterval(
          startsAt: DateTime(2026, 9, 14, 13),
          endsAt: DateTime(2026, 9, 14, 14),
        ),
        now: () => DateTime(2026, 9, 14, 12),
      );

      final slots = await repository.findAvailableSlots(
        from: DateTime(2026, 9, 14, 12),
        durationMinutes: 30,
        limit: 1,
      );

      expect(slots.single.startsAt, DateTime(2026, 9, 14, 13));
    });
  });
}

DoctorProfile _profile({
  int defaultDurationMinutes = 30,
}) {
  return DoctorProfile(
    userId: 'doctor-1',
    fullName: 'Dr Test',
    specialty: 'Dentist',
    defaultDurationMinutes: defaultDurationMinutes,
    workingDays: const [1, 2, 3, 4, 5],
    workdayStart: '09:00',
    workdayEnd: '18:00',
    breakStart: '13:00',
    breakEnd: '14:00',
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

  @override
  Future<List<Visit>> fetchVisits({
    required DateTime from,
    required DateTime to,
  }) async {
    return visits;
  }
}
