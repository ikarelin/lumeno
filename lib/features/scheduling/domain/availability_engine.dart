import 'availability_interval.dart';

/// Pure scheduling-domain interval fitting.
///
/// The engine deliberately does not know about Flutter, Supabase, doctor
/// profiles, calendar pages, or persisted exception records. Callers resolve
/// those sources into concrete working and busy intervals first.
///
/// This keeps all interval subtraction and duration fitting in one place and
/// prevents presentation layers from calculating availability independently.
class AvailabilityEngine {
  const AvailabilityEngine();

  /// Returns every continuous free interval after subtracting busy time.
  ///
  /// This is the canonical interval-subtraction operation. It deliberately has
  /// no appointment-duration filter so Calendar can render real free windows
  /// rather than reconstructing availability in presentation code.
  ///
  /// [workingIntervals] defines when work is allowed. [busyIntervals] contains
  /// already unavailable time such as scheduled Visits and recurring breaks.
  /// [notBefore] removes past availability while preserving historical Visits
  /// elsewhere in the UI.
  ///
  /// The method performs no fixed 24-hour/day arithmetic. Concrete day and
  /// timezone boundaries must be resolved before calling the engine.
  List<AvailabilityInterval> findFreeIntervals({
    required List<AvailabilityInterval> workingIntervals,
    required List<AvailabilityInterval> busyIntervals,
    DateTime? notBefore,
  }) {
    if (workingIntervals.isEmpty) {
      return const [];
    }

    final working = _mergeIntervals(workingIntervals);
    final busy = _mergeIntervals(busyIntervals);
    final result = <AvailabilityInterval>[];

    for (final sourceWorkingInterval in working) {
      var workingStart = sourceWorkingInterval.startsAt;
      final workingEnd = sourceWorkingInterval.endsAt;

      if (notBefore != null) {
        if (!workingEnd.isAfter(notBefore)) {
          continue;
        }

        if (workingStart.isBefore(notBefore)) {
          workingStart = notBefore;
        }
      }

      var cursor = workingStart;

      for (final busyInterval in busy) {
        if (!busyInterval.endsAt.isAfter(cursor)) {
          continue;
        }

        if (!busyInterval.startsAt.isBefore(workingEnd)) {
          break;
        }

        final gapEnd = _earlierOf(busyInterval.startsAt, workingEnd);
        _addIfPositive(
          result,
          startsAt: cursor,
          endsAt: gapEnd,
        );

        if (busyInterval.endsAt.isAfter(cursor)) {
          cursor = _laterOf(cursor, busyInterval.endsAt);
        }

        if (!cursor.isBefore(workingEnd)) {
          break;
        }
      }

      _addIfPositive(
        result,
        startsAt: cursor,
        endsAt: workingEnd,
      );
    }

    return List.unmodifiable(result);
  }

  /// Returns only continuous free intervals that can fit the requested
  /// appointment duration.
  List<AvailabilityInterval> findAvailableIntervals({
    required List<AvailabilityInterval> workingIntervals,
    required List<AvailabilityInterval> busyIntervals,
    required int requestedDurationMinutes,
    DateTime? notBefore,
  }) {
    if (requestedDurationMinutes <= 0) {
      throw ArgumentError.value(
        requestedDurationMinutes,
        'requestedDurationMinutes',
        'Requested duration must be positive.',
      );
    }

    final requestedDuration = Duration(minutes: requestedDurationMinutes);
    final freeIntervals = findFreeIntervals(
      workingIntervals: workingIntervals,
      busyIntervals: busyIntervals,
      notBefore: notBefore,
    );

    return List.unmodifiable(
      freeIntervals.where(
        (interval) => interval.duration >= requestedDuration,
      ),
    );
  }

  /// Derives concrete booking starts inside already-fitted free intervals.
  ///
  /// Suggested starts are transient choices. They are not stored availability
  /// records and selecting one remains an explicit UI action.
  List<DateTime> findSuggestedStarts({
    required List<AvailabilityInterval> availableIntervals,
    required int requestedDurationMinutes,
    required int startPrecisionMinutes,
    int limit = 4,
  }) {
    if (requestedDurationMinutes <= 0) {
      throw ArgumentError.value(
        requestedDurationMinutes,
        'requestedDurationMinutes',
        'Requested duration must be positive.',
      );
    }

    if (startPrecisionMinutes <= 0) {
      throw ArgumentError.value(
        startPrecisionMinutes,
        'startPrecisionMinutes',
        'Start precision must be positive.',
      );
    }

    if (limit <= 0) {
      return const [];
    }

    final duration = Duration(minutes: requestedDurationMinutes);
    final intervals = [...availableIntervals]
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final starts = <DateTime>[];

    for (final interval in intervals) {
      var candidate = _roundUpToPrecision(
        interval.startsAt,
        startPrecisionMinutes,
      );

      while (!candidate.add(duration).isAfter(interval.endsAt)) {
        starts.add(candidate);

        if (starts.length >= limit) {
          return List.unmodifiable(starts);
        }

        candidate = candidate.add(Duration(minutes: startPrecisionMinutes));
      }
    }

    return List.unmodifiable(starts);
  }

  List<AvailabilityInterval> _mergeIntervals(
    List<AvailabilityInterval> intervals,
  ) {
    if (intervals.isEmpty) {
      return const [];
    }

    final sorted = [...intervals]
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final merged = <AvailabilityInterval>[];

    for (final interval in sorted) {
      if (merged.isEmpty) {
        merged.add(interval);
        continue;
      }

      final previous = merged.last;
      final overlapsOrTouches = !interval.startsAt.isAfter(previous.endsAt);

      if (!overlapsOrTouches) {
        merged.add(interval);
        continue;
      }

      merged[merged.length - 1] = AvailabilityInterval(
        startsAt: previous.startsAt,
        endsAt: _laterOf(previous.endsAt, interval.endsAt),
      );
    }

    return merged;
  }

  void _addIfPositive(
    List<AvailabilityInterval> target, {
    required DateTime startsAt,
    required DateTime endsAt,
  }) {
    if (!startsAt.isBefore(endsAt)) {
      return;
    }

    target.add(AvailabilityInterval(startsAt: startsAt, endsAt: endsAt));
  }

  DateTime _roundUpToPrecision(DateTime value, int precisionMinutes) {
    final minuteOfDay = value.hour * 60 + value.minute;
    final isExactBoundary =
        minuteOfDay % precisionMinutes == 0 &&
        value.second == 0 &&
        value.millisecond == 0 &&
        value.microsecond == 0;

    final roundedMinuteOfDay = isExactBoundary
        ? minuteOfDay
        : ((minuteOfDay ~/ precisionMinutes) + 1) * precisionMinutes;

    const minutesPerHour = 60;
    const minutesPerDay = 24 * minutesPerHour;
    final dayOffset = roundedMinuteOfDay ~/ minutesPerDay;
    final minuteWithinDay = roundedMinuteOfDay % minutesPerDay;
    final hour = minuteWithinDay ~/ minutesPerHour;
    final minute = minuteWithinDay % minutesPerHour;

    if (value.isUtc) {
      return DateTime.utc(
        value.year,
        value.month,
        value.day + dayOffset,
        hour,
        minute,
      );
    }

    return DateTime(
      value.year,
      value.month,
      value.day + dayOffset,
      hour,
      minute,
    );
  }

  DateTime _earlierOf(DateTime first, DateTime second) {
    return first.isBefore(second) ? first : second;
  }

  DateTime _laterOf(DateTime first, DateTime second) {
    return first.isAfter(second) ? first : second;
  }
}
