import 'package:intl/intl.dart';

import '../../scheduling/domain/availability_slot.dart';
import '../../scheduling/domain/calendar_civil_time.dart';

/// All dashboard dates and clocks represent absolute instants in one zone.
/// The original Visit/slot DateTimes are passed to actions unchanged.
class DashboardTimeLabels {
  const DashboardTimeLabels(this.calendarTime);

  final CalendarCivilTime calendarTime;

  String date(DateTime instant, String locale) => DateFormat(
        'EEE, d MMM',
        locale,
      ).format(calendarTime.displayInstant(instant));

  String clock(DateTime instant) => calendarTime.clockLabel(instant);

  String slotRange(AvailabilitySlot slot) =>
      '${clock(slot.startsAt)} - ${clock(slot.endsAt)}';

  String headerDate(DateTime now, String locale) => DateFormat(
        'EEEE, d MMMM',
        locale,
      ).format(calendarTime.displayInstant(now));

  String greetingKey(DateTime now) {
    final hour = calendarTime.displayInstant(now).hour;
    return switch (hour) {
      >= 5 && < 12 => 'dashboard.greetingMorning',
      >= 12 && < 18 => 'dashboard.greetingAfternoon',
      >= 18 => 'dashboard.greetingEvening',
      _ => 'dashboard.greetingNight',
    };
  }
}
