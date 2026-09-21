import 'package:intl/intl.dart';

import '../../scheduling/domain/calendar_civil_time.dart';

/// Calendar Day and Visit details use one civil-time context for displaying
/// absolute instants. No label is ever converted back into a booking instant.
class CalendarTimeLabels {
  const CalendarTimeLabels(this.calendarTime);

  final CalendarCivilTime calendarTime;

  String date(DateTime instant, String locale) =>
      DateFormat('EEEE, d MMMM', locale).format(
        calendarTime.displayInstant(instant),
      );

  String clock(DateTime instant) => calendarTime.clockLabel(instant);

  String range(DateTime startsAt, DateTime endsAt) =>
      '${clock(startsAt)} - ${clock(endsAt)}';
}
