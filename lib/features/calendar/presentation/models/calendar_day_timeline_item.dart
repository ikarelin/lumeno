import '../../../scheduling/domain/availability_day.dart';
import '../../../scheduling/domain/availability_interval.dart';
import '../../../visits/domain/visit.dart';

enum CalendarDayTimelineItemKind {
  free,
  visit,
  breakTime,
  dayOff,
}

class CalendarDayTimelineItem {
  const CalendarDayTimelineItem._({
    required this.kind,
    required this.startsAt,
    required this.endsAt,
    this.visit,
  });

  factory CalendarDayTimelineItem.free(AvailabilityInterval interval) {
    return CalendarDayTimelineItem._(
      kind: CalendarDayTimelineItemKind.free,
      startsAt: interval.startsAt,
      endsAt: interval.endsAt,
    );
  }

  factory CalendarDayTimelineItem.visit(Visit visit) {
    return CalendarDayTimelineItem._(
      kind: CalendarDayTimelineItemKind.visit,
      startsAt: visit.startsAt,
      endsAt: visit.endsAt,
      visit: visit,
    );
  }

  factory CalendarDayTimelineItem.breakTime(AvailabilityInterval interval) {
    return CalendarDayTimelineItem._(
      kind: CalendarDayTimelineItemKind.breakTime,
      startsAt: interval.startsAt,
      endsAt: interval.endsAt,
    );
  }


  factory CalendarDayTimelineItem.dayOff(AvailabilityInterval interval) {
    return CalendarDayTimelineItem._(
      kind: CalendarDayTimelineItemKind.dayOff,
      startsAt: interval.startsAt,
      endsAt: interval.endsAt,
    );
  }

  final CalendarDayTimelineItemKind kind;
  final DateTime startsAt;
  final DateTime endsAt;
  final Visit? visit;
}

List<CalendarDayTimelineItem> buildCalendarDayTimeline({
  required List<Visit> visits,
  required AvailabilityDay availability,
}) {
  final items = <CalendarDayTimelineItem>[
    for (final visit in visits)
      if (visit.status == VisitStatus.scheduled)
        CalendarDayTimelineItem.visit(visit),
    for (final interval in availability.availableIntervals)
      CalendarDayTimelineItem.free(interval),
    for (final interval in availability.breakIntervals)
      CalendarDayTimelineItem.breakTime(interval),
    for (final interval in availability.dayOffIntervals)
      CalendarDayTimelineItem.dayOff(interval),
  ];

  items.sort((left, right) {
    final byStart = left.startsAt.compareTo(right.startsAt);
    if (byStart != 0) {
      return byStart;
    }

    final byEnd = left.endsAt.compareTo(right.endsAt);
    if (byEnd != 0) {
      return byEnd;
    }

    return _kindPriority(left.kind).compareTo(_kindPriority(right.kind));
  });

  return List.unmodifiable(items);
}

int _kindPriority(CalendarDayTimelineItemKind kind) {
  return switch (kind) {
    CalendarDayTimelineItemKind.visit => 0,
    CalendarDayTimelineItemKind.breakTime => 1,
    CalendarDayTimelineItemKind.dayOff => 1,
    CalendarDayTimelineItemKind.free => 2,
  };
}
