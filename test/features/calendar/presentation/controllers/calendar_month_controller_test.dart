import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/calendar/presentation/controllers/calendar_month_controller.dart';
import 'package:lumeno/features/scheduling/domain/availability_day.dart';
import 'package:lumeno/features/scheduling/domain/availability_range_repository.dart';
import 'package:lumeno/features/scheduling/presentation/providers/availability_provider.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';
import 'package:lumeno/features/visits/presentation/providers/visit_provider.dart';

void main() {
  test('Calendar Month loads real visits and shared availability for the month', () async {
    final visits = _FakeVisitQueryRepository(
      visits: [
        _visit(id: 'first', day: 1, hour: 9, durationMinutes: 60),
        _visit(id: 'second', day: 1, hour: 11, durationMinutes: 30),
        _visit(id: 'third', day: 16, hour: 14, durationMinutes: 60),
        _visit(
          id: 'cancelled',
          day: 16,
          hour: 16,
          durationMinutes: 60,
          status: VisitStatus.cancelled,
        ),
        _visit(id: 'day-off-visit', day: 20, hour: 10, durationMinutes: 60),
      ],
    );
    final availability = _FakeAvailabilityRangeRepository();
    final container = ProviderContainer(
      overrides: [
        visitQueryRepositoryProvider.overrideWithValue(visits),
        availabilityRangeRepositoryProvider.overrideWithValue(availability),
      ],
    );
    addTearDown(container.dispose);

    final data = await container.read(
      calendarMonthDataProvider(DateTime(2026, 9, 16, 12, 30)).future,
    );

    expect(data.firstDay, DateTime(2026, 9, 1));
    expect(data.days.length, 30);
    expect(data.days.first.date, DateTime(2026, 9, 1));
    expect(data.days.last.date, DateTime(2026, 9, 30));
    expect(data.days[0].visitCount, 2);
    expect(data.days[15].visitCount, 1);
    expect(data.days[19].visitCount, 1);
    expect(data.days[19].isWorkingDay, isFalse);
    expect(data.visitCount, 4);
    expect(data.busyDayCount, 3);
    expect(data.workingDayCount, 22);
    expect(visits.lastFrom, DateTime(2026, 9, 1));
    expect(visits.lastTo, DateTime(2026, 10, 1));
    expect(availability.fetchCalls, 1);
    expect(availability.lastFrom, DateTime(2026, 9, 1));
    expect(availability.lastTo, DateTime(2026, 10, 1));
  });
}

Visit _visit({
  required String id,
  required int day,
  required int hour,
  required int durationMinutes,
  VisitStatus status = VisitStatus.scheduled,
}) {
  return Visit(
    id: id,
    patientId: 'patient-$id',
    clinicId: 'clinic-1',
    startsAt: DateTime(2026, 9, day, hour),
    durationMinutes: durationMinutes,
    status: status,
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

class _FakeAvailabilityRangeRepository
    implements AvailabilityRangeRepository {
  int fetchCalls = 0;
  DateTime? lastFrom;
  DateTime? lastTo;

  @override
  Future<List<AvailabilityDay>> findRangeAvailability({
    required DateTime from,
    required DateTime to,
  }) async {
    fetchCalls += 1;
    lastFrom = from;
    lastTo = to;

    final days = <AvailabilityDay>[];
    for (
      var day = from;
      day.isBefore(to);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      days.add(
        AvailabilityDay(
          day: day,
          isWorkingDay: day.weekday <= DateTime.friday,
        ),
      );
    }
    return days;
  }
}
