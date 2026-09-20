import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// UTC query interval for one doctor's civil calendar day: [startUtc, endUtc).
/// It may be 23, 24, or 25 hours long when the zone observes DST.
class DoctorDayUtcRange {
  const DoctorDayUtcRange({required this.startUtc, required this.endUtc});

  final DateTime startUtc;
  final DateTime endUtc;
}

/// Converts absolute instants and civil days using an explicit IANA zone.
/// Never relies on DateTime.local, the OS zone or a fixed UTC offset.
class DoctorCalendarTime {
  DoctorCalendarTime(String timeZoneId)
    : _location = _findLocation(timeZoneId),
      timeZoneId = timeZoneId;

  final String timeZoneId;
  final tz.Location _location;

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  static tz.Location _findLocation(String id) {
    _ensureInitialized();
    return tz.getLocation(id); // Reject unknown IDs, never silently fall back.
  }

  static List<String> get availableTimeZoneIds {
    _ensureInitialized();
    return tz.timeZoneDatabase.locations.keys.toList()..sort();
  }

  /// A UTC-constructed DateTime is used only as a date-only (Y/M/D) label.
  /// Do not treat it as the instant at midnight in the doctor's zone.
  DateTime civilDayAt(DateTime instant) {
    final local = tz.TZDateTime.from(instant.toUtc(), _location);
    return DateTime.utc(local.year, local.month, local.day);
  }

  tz.TZDateTime timeAt(DateTime instant) =>
      tz.TZDateTime.from(instant.toUtc(), _location);

  DoctorDayUtcRange dayRangeUtc(DateTime civilDay) {
    final start = tz.TZDateTime(
      _location, civilDay.year, civilDay.month, civilDay.day,
    );
    // Construct the next civil midnight in the named zone. Adding 24 hours
    // would silently miss / double-count visits on DST transition days.
    final end = tz.TZDateTime(
      _location, civilDay.year, civilDay.month, civilDay.day + 1,
    );
    return DoctorDayUtcRange(startUtc: start.toUtc(), endUtc: end.toUtc());
  }
}
