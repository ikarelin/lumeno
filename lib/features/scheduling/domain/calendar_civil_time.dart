import 'doctor_calendar_time.dart';

/// Calendar dates are Y/M/D labels; Visit and slot DateTimes are instants.
///
/// This adapter keeps the existing device-zone presentation when [doctorTime]
/// is null. The doctor-zone path is activated only with the coordinated UI
/// rollout, never by inferring a doctor's zone from the device.
class CalendarCivilTime {
  const CalendarCivilTime({this.doctorTime});

  final DoctorCalendarTime? doctorTime;

  /// Preserve date components without interpreting a label as an instant.
  DateTime dayLabel(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Interpret an absolute Visit/slot instant in the presentation zone.
  DateTime displayInstant(DateTime instant) =>
      doctorTime?.timeAt(instant) ?? instant.toLocal();

  /// Never call toLocal() on a civil-date label supplied by a date picker.
  DateTime civilDayAt(DateTime instant) =>
      dayLabel(displayInstant(instant));

  /// Half-open interval for all Visits intersecting a civil-date range.
  DoctorDayUtcRange visitQueryRange({
    required DateTime firstCivilDay,
    required DateTime endExclusiveCivilDay,
  }) {
    final first = dayLabel(firstCivilDay);
    final end = dayLabel(endExclusiveCivilDay);
    if (!first.isBefore(end)) {
      throw ArgumentError('The exclusive end day must follow the first day.');
    }
    final doctor = doctorTime;
    if (doctor != null) {
      return doctor.civilRangeUtc(
        firstCivilDay: first,
        endExclusiveCivilDay: end,
      );
    }
    return DoctorDayUtcRange(startUtc: first, endUtc: end);
  }

  bool isOnCivilDay(DateTime instant, DateTime civilDay) {
    final actual = civilDayAt(instant);
    return actual.year == civilDay.year &&
        actual.month == civilDay.month &&
        actual.day == civilDay.day;
  }
}
