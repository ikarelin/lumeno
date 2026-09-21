import '../../scheduling/domain/calendar_civil_time.dart';

/// Calendar navigation moves date labels, not absolute instants.
/// A civil day can contain 23 or 25 hours across a DST transition.
enum CalendarNavigationUnit { day, week, month }

class CalendarDateNavigation {
  const CalendarDateNavigation(this.calendarTime);

  final CalendarCivilTime calendarTime;

  /// Computes "today" in the doctor's IANA zone (or legacy device zone).
  DateTime today(DateTime now) => calendarTime.civilDayAt(now);

  /// Preserve the selected civil date when opening a Day from Week/Month.
  DateTime selectDay(DateTime date) => calendarTime.dayLabel(date);

  DateTime shift(
    DateTime selectedDate, {
    required CalendarNavigationUnit unit,
    required int direction,
  }) {
    if (direction != -1 && direction != 1) {
      throw ArgumentError.value(direction, 'direction', 'Expected -1 or 1.');
    }

    // Calculate date fields in UTC only to avoid the device's DST rules.
    // UTC values here are temporary calendar labels, never Visit startsAt.
    final nextDay = switch (unit) {
      CalendarNavigationUnit.day => DateTime.utc(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + direction,
        ),
      CalendarNavigationUnit.week => DateTime.utc(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + 7 * direction,
        ),
      CalendarNavigationUnit.month => _shiftMonth(selectedDate, direction),
    };
    return calendarTime.dayLabel(nextDay);
  }

  static DateTime _shiftMonth(DateTime day, int direction) {
    final firstOfTargetMonth = DateTime.utc(day.year, day.month + direction, 1);
    final lastDay = DateTime.utc(
      firstOfTargetMonth.year,
      firstOfTargetMonth.month + 1,
      0,
    ).day;
    return DateTime.utc(
      firstOfTargetMonth.year,
      firstOfTargetMonth.month,
      day.day > lastDay ? lastDay : day.day,
    );
  }
}
