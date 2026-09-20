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

  /// Half-open UTC query range for [firstCivilDay, endExclusiveCivilDay).
  /// Arguments are date-only Y/M/D labels, never instants in the device zone.
  DoctorDayUtcRange civilRangeUtc({
    required DateTime firstCivilDay,
    required DateTime endExclusiveCivilDay,
  }) {
    final first = DateTime.utc(
      firstCivilDay.year, firstCivilDay.month, firstCivilDay.day,
    );
    final end = DateTime.utc(
      endExclusiveCivilDay.year,
      endExclusiveCivilDay.month,
      endExclusiveCivilDay.day,
    );
    if (!first.isBefore(end)) {
      throw ArgumentError('The exclusive end day must follow the first day.');
    }
    return DoctorDayUtcRange(
      startUtc: dayRangeUtc(first).startUtc,
      endUtc: dayRangeUtc(end).startUtc,
    );
  }

  /// Resolves a doctor's wall-clock appointment/work time to one UTC instant.
  /// Rejects gaps and repeated clock times rather than silently shifting a
  /// booking or choosing an arbitrary occurrence during a DST transition.
  /// The caller must resolve a repeated time explicitly through the product UX.
  DateTime instantAtCivilTimeUtc(
    DateTime civilDay, {
    required int hour,
    int minute = 0,
    int second = 0,
  }) {
    RangeError.checkValueInInterval(hour, 0, 23, 'hour');
    RangeError.checkValueInInterval(minute, 0, 59, 'minute');
    RangeError.checkValueInInterval(second, 0, 59, 'second');

    final naiveUtc = DateTime.utc(
      civilDay.year, civilDay.month, civilDay.day, hour, minute, second,
    );
    final candidates = <int, DateTime>{};
    // Scan offsets over a broad UTC window; this also covers half-hour DST
    // shifts and date-line changes without assuming a fixed +1 hour jump.
    for (var step = -8; step <= 8; step++) {
      final probeUtc = naiveUtc.add(Duration(hours: step * 6));
      final probeOffset = tz.TZDateTime.from(probeUtc, _location).timeZoneOffset;
      final candidateUtc = naiveUtc.subtract(probeOffset);
      final candidateLocal = tz.TZDateTime.from(candidateUtc, _location);
      if (candidateLocal.year == civilDay.year &&
          candidateLocal.month == civilDay.month &&
          candidateLocal.day == civilDay.day &&
          candidateLocal.hour == hour &&
          candidateLocal.minute == minute &&
          candidateLocal.second == second) {
        candidates[candidateUtc.microsecondsSinceEpoch] = candidateUtc;
      }
    }
    if (candidates.isEmpty) {
      throw StateError('Nonexistent doctor-local time in $timeZoneId.');
    }
    if (candidates.length > 1) {
      throw StateError('Ambiguous doctor-local time in $timeZoneId.');
    }
    return candidates.values.single;
  }
}
