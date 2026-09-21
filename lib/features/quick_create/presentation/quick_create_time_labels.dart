import 'package:intl/intl.dart';

import '../../scheduling/domain/calendar_civil_time.dart';

/// A single presentation context for Quick Create's suggested slots, selected
/// time, and availability date/time picker. Inputs remain absolute instants;
/// only labels are converted to the doctor's wall-clock zone when enabled.
class QuickCreateTimeLabels {
  const QuickCreateTimeLabels(this.calendarTime);

  final CalendarCivilTime calendarTime;

  String selectedDate(DateTime startsAt, String locale) =>
      DateFormat('EEE, d MMM', locale).format(
        calendarTime.displayInstant(startsAt),
      );

  String selectedRange(DateTime startsAt, int durationMinutes) =>
      '${calendarTime.clockLabel(startsAt)} - '
      '${calendarTime.clockLabel(startsAt.add(Duration(minutes: durationMinutes)))}';

  String slotChip(DateTime startsAt, String locale) =>
      '${DateFormat('EEE', locale).format(calendarTime.displayInstant(startsAt))} '
      '${calendarTime.clockLabel(startsAt)}';
}
