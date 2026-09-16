import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/calendar/presentation/controllers/calendar_week_controller.dart';
import 'package:lumeno/features/scheduling/domain/availability_day.dart';
import 'package:lumeno/features/scheduling/domain/availability_day_repository.dart';
import 'package:lumeno/features/scheduling/domain/availability_interval.dart';
import 'package:lumeno/features/scheduling/presentation/providers/availability_provider.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';
import 'package:lumeno/features/visits/presentation/providers/visit_provider.dart';

void main() {
  test('Calendar Week loads real visits and availability for Monday to Sunday', () async {
    final visits = _FakeVisitQueryRepository(
      visits: [
        _visit(id: 'monday-visit', day: 14, hour: 9),
        _visit(id: 'wednesday-visit', day: 16, hour: 14),
        _visit(
          id: 'cancelled-visit',
          day: 16,
          hour: 16,
          status: VisitStatus.cancelled,
        ),
      ],
    );
    final availability = _FakeAvailabilityDayRepository();
    final container = ProviderContainer(
      overrides: [
        visitQueryRepositoryProvider.overrideWithValue(visits),
        availabilityDayRepositoryProvider.overrideWithValue(availability),
      ],
    );
    addTearDown(container.dispose);

    final data = await container.read(
      calendarWeekDataProvider(DateTime(2026, 9, 16, 12, 30)).future,
    );

    expect(data.monday, DateTime(2026, 9, 14));
    expect(data.days.length, 7);
    expect(data.days.first.date, DateTime(2026, 9, 14));
    expect(data.days.last.date, DateTime(2026, 9, 20));
    expect(data.days[0].visitCount, 1);
    expect(data.days[2].visitCount, 1);
    expect(data.visitCount, 2);
    expect(data.availableWindowCount, 5);
    expect(data.workingDayCount, 5);
    expect(visits.lastFrom, DateTime(2026, 9, 14));
    expect(visits.lastTo, DateTime(2026, 9, 21));
    expect(
      availability.requestedDays,
      List.generate(7, (index) => DateTime(2026, 9, 14 + index)),
    );
  });
}

Visit _visit({
  required String id,
  required int day,
  required int hour,
  VisitStatus status = VisitStatus.scheduled,
}) {
  return Visit(
    id: id,
    patientId: 'patient-$id',
    clinicId: 'clinic-1',
    startsAt: DateTime(2026, 9, day, hour),
    durationMinutes: 60,
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

class _FakeAvailabilityDayRepository implements AvailabilityDayRepository {
  final List<DateTime> requestedDays = [];

  @override
  Future<AvailabilityDay> findDayAvailability({
    required DateTime day,
  }) async {
    requestedDays.add(day);
    final isWorkingDay = day.weekday <= DateTime.friday;
    final windowCount = switch (day.weekday) {
      DateTime.monday => 2,
      DateTime.tuesday => 1,
      DateTime.wednesday => 1,
      DateTime.thursday => 0,
      DateTime.friday => 1,
      _ => 0,
    };

    return AvailabilityDay(
      day: day,
      isWorkingDay: isWorkingDay,
      availableIntervals: List.generate(
        windowCount,
        (index) => AvailabilityInterval(
          startsAt: DateTime(day.year, day.month, day.day, 9 + index * 2),
          endsAt: DateTime(day.year, day.month, day.day, 10 + index * 2),
        ),
      ),
    );
  }
}
