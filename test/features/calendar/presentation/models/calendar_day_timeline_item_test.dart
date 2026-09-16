import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/calendar/presentation/models/calendar_day_timeline_item.dart';
import 'package:lumeno/features/scheduling/domain/availability_day.dart';
import 'package:lumeno/features/scheduling/domain/availability_interval.dart';
import 'package:lumeno/features/visits/domain/visit.dart';

void main() {
  test('builds one chronological Free / Visit / Break timeline', () {
    final availability = AvailabilityDay(
      day: DateTime(2026, 9, 15),
      isWorkingDay: true,
      availableIntervals: [
        _interval(startHour: 9, endHour: 10),
        _interval(startHour: 10, startMinute: 30, endHour: 13),
        _interval(startHour: 14, endHour: 18),
      ],
      breakIntervals: [
        _interval(startHour: 13, endHour: 14),
      ],
    );
    final visits = [
      Visit(
        id: 'visit-scheduled',
        patientId: 'patient-1',
        clinicId: 'clinic-1',
        startsAt: DateTime(2026, 9, 15, 10),
        durationMinutes: 30,
      ),
      Visit(
        id: 'visit-cancelled',
        patientId: 'patient-2',
        clinicId: 'clinic-1',
        startsAt: DateTime(2026, 9, 15, 11),
        durationMinutes: 30,
        status: VisitStatus.cancelled,
      ),
    ];

    final timeline = buildCalendarDayTimeline(
      visits: visits,
      availability: availability,
    );

    expect(
      timeline.map((item) => item.kind),
      [
        CalendarDayTimelineItemKind.free,
        CalendarDayTimelineItemKind.visit,
        CalendarDayTimelineItemKind.free,
        CalendarDayTimelineItemKind.breakTime,
        CalendarDayTimelineItemKind.free,
      ],
    );
    expect(
      timeline.map((item) => item.startsAt),
      [
        DateTime(2026, 9, 15, 9),
        DateTime(2026, 9, 15, 10),
        DateTime(2026, 9, 15, 10, 30),
        DateTime(2026, 9, 15, 13),
        DateTime(2026, 9, 15, 14),
      ],
    );
    expect(
      timeline.where((item) => item.visit != null).single.visit!.id,
      'visit-scheduled',
    );
  });

  test('keeps recurring Day off soft-unavailable around an urgent Visit', () {
    final availability = AvailabilityDay(
      day: DateTime(2026, 9, 19),
      isWorkingDay: false,
      dayOffIntervals: [
        AvailabilityInterval(
          startsAt: DateTime(2026, 9, 19, 9),
          endsAt: DateTime(2026, 9, 19, 10),
        ),
        AvailabilityInterval(
          startsAt: DateTime(2026, 9, 19, 10, 30),
          endsAt: DateTime(2026, 9, 19, 18),
        ),
      ],
    );
    final visits = [
      Visit(
        id: 'urgent',
        patientId: 'patient-1',
        clinicId: 'clinic-1',
        startsAt: DateTime(2026, 9, 19, 10),
        durationMinutes: 30,
      ),
    ];

    final timeline = buildCalendarDayTimeline(
      visits: visits,
      availability: availability,
    );

    expect(
      timeline.map((item) => item.kind),
      [
        CalendarDayTimelineItemKind.dayOff,
        CalendarDayTimelineItemKind.visit,
        CalendarDayTimelineItemKind.dayOff,
      ],
    );
  });
}

AvailabilityInterval _interval({
  required int startHour,
  int startMinute = 0,
  required int endHour,
  int endMinute = 0,
}) {
  return AvailabilityInterval(
    startsAt: DateTime(2026, 9, 15, startHour, startMinute),
    endsAt: DateTime(2026, 9, 15, endHour, endMinute),
  );
}
