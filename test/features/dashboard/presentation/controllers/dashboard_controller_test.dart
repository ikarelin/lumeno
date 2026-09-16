import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:lumeno/features/profile/domain/doctor_profile.dart';
import 'package:lumeno/features/scheduling/domain/availability_repository.dart';
import 'package:lumeno/features/scheduling/domain/availability_slot.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';

void main() {
  group('DashboardVisitsController', () {
    final now = DateTime(2026, 9, 16, 9);

    test('selects next scheduled visit and keeps later visits as upcoming', () async {
      final repository = _FakeVisitQueryRepository([
        _visit('later-3', DateTime(2026, 9, 16, 15)),
        _visit(
          'cancelled',
          DateTime(2026, 9, 16, 9, 30),
          status: VisitStatus.cancelled,
        ),
        _visit('next', DateTime(2026, 9, 16, 10)),
        _visit('later-1', DateTime(2026, 9, 16, 11)),
        _visit('later-2', DateTime(2026, 9, 16, 13)),
        _visit('later-4', DateTime(2026, 9, 17, 9)),
        _visit('past', DateTime(2026, 9, 16, 8, 30)),
      ]);

      final result = await DashboardVisitsController(
        visitQueryRepository: repository,
        now: () => now,
      ).load();

      expect(result.nextVisit?.id, 'next');
      expect(
        result.upcomingVisits.map((visit) => visit.id),
        ['later-1', 'later-2', 'later-3'],
      );
      expect(repository.lastFrom, now);
      expect(repository.lastTo, now.add(const Duration(days: 365)));
    });

    test('returns an empty state when there are no future scheduled visits', () async {
      final repository = _FakeVisitQueryRepository([
        _visit('past', DateTime(2026, 9, 16, 8)),
        _visit(
          'completed',
          DateTime(2026, 9, 16, 10),
          status: VisitStatus.completed,
        ),
      ]);

      final result = await DashboardVisitsController(
        visitQueryRepository: repository,
        now: () => now,
      ).load();

      expect(result.nextVisit, isNull);
      expect(result.upcomingVisits, isEmpty);
    });
  });

  group('DashboardAvailabilityController', () {
    final now = DateTime(2026, 9, 16, 9);
    const profile = DoctorProfile(
      userId: 'doctor-1',
      fullName: 'Doctor',
      specialty: 'Dentist',
      defaultDurationMinutes: 60,
      workingDays: [1, 2, 3, 4, 5],
    );

    test('does not query availability when doctor profile is missing', () async {
      final repository = _FakeAvailabilityRepository([]);

      final result = await DashboardAvailabilityController(
        availabilityRepository: repository,
        now: () => now,
      ).load(profile: null);

      expect(
        result.status,
        DashboardAvailabilityStatus.scheduleNotConfigured,
      );
      expect(repository.callCount, 0);
    });

    test('keeps an exception-created slot even with no recurring workdays', () async {
      final slot = AvailabilitySlot(
        startsAt: DateTime(2026, 9, 16, 12),
        durationMinutes: 30,
      );
      final repository = _FakeAvailabilityRepository([slot]);

      final result = await DashboardAvailabilityController(
        availabilityRepository: repository,
        now: () => now,
      ).load(
        profile: const DoctorProfile(
          userId: 'doctor-1',
          fullName: 'Doctor',
          specialty: 'Dentist',
          workingDays: [],
        ),
      );

      expect(result.status, DashboardAvailabilityStatus.ready);
      expect(result.slot, slot);
      expect(repository.callCount, 1);
    });

    test('treats empty recurring schedule with no slot as not configured', () async {
      final repository = _FakeAvailabilityRepository([]);

      final result = await DashboardAvailabilityController(
        availabilityRepository: repository,
        now: () => now,
      ).load(
        profile: const DoctorProfile(
          userId: 'doctor-1',
          fullName: 'Doctor',
          specialty: 'Dentist',
          workingDays: [],
        ),
      );

      expect(
        result.status,
        DashboardAvailabilityStatus.scheduleNotConfigured,
      );
    });

    test('returns the first production availability slot', () async {
      final slot = AvailabilitySlot(
        startsAt: DateTime(2026, 9, 16, 11),
        durationMinutes: 60,
      );
      final repository = _FakeAvailabilityRepository([slot]);

      final result = await DashboardAvailabilityController(
        availabilityRepository: repository,
        now: () => now,
      ).load(profile: profile);

      expect(result.status, DashboardAvailabilityStatus.ready);
      expect(result.slot, slot);
      expect(repository.lastFrom, now);
      expect(repository.lastDurationMinutes, 60);
      expect(repository.lastLimit, 1);
    });

    test('returns noSlots when shared availability has no suggestion', () async {
      final repository = _FakeAvailabilityRepository([]);

      final result = await DashboardAvailabilityController(
        availabilityRepository: repository,
        now: () => now,
      ).load(profile: profile);

      expect(result.status, DashboardAvailabilityStatus.noSlots);
      expect(result.slot, isNull);
    });
  });
}

Visit _visit(String id, DateTime startsAt, {VisitStatus? status}) {
  return Visit(
    id: id,
    patientId: 'patient-$id',
    clinicId: 'clinic-1',
    startsAt: startsAt,
    durationMinutes: 30,
    patientName: 'Patient $id',
    status: status ?? VisitStatus.scheduled,
  );
}

class _FakeVisitQueryRepository implements VisitQueryRepository {
  _FakeVisitQueryRepository(this.visits);

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

class _FakeAvailabilityRepository implements AvailabilityRepository {
  _FakeAvailabilityRepository(this.slots);

  final List<AvailabilitySlot> slots;
  int callCount = 0;
  DateTime? lastFrom;
  int? lastDurationMinutes;
  int? lastLimit;

  @override
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  }) async {
    callCount += 1;
    lastFrom = from;
    lastDurationMinutes = durationMinutes;
    lastLimit = limit;
    return slots;
  }
}
