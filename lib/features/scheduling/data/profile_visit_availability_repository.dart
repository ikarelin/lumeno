import '../../profile/domain/doctor_profile.dart';
import '../../profile/domain/doctor_profile_repository.dart';
import '../../visits/domain/visit.dart';
import '../../visits/domain/visit_repository.dart';
import '../domain/availability_engine.dart';
import '../domain/availability_interval.dart';
import '../domain/availability_repository.dart';
import '../domain/availability_slot.dart';

/// Production availability adapter for the current single-doctor MVP.
///
/// The repository resolves recurring Doctor Profile scheduling defaults and
/// persisted Visits into the generic [AvailabilityEngine] input. Calendar
/// exceptions are intentionally not handled here yet; they will become another
/// busy/working-interval source when their persistence is introduced.
class ProfileVisitAvailabilityRepository implements AvailabilityRepository {
  factory ProfileVisitAvailabilityRepository({
    required DoctorProfileRepository profileRepository,
    required VisitQueryRepository visitQueryRepository,
    AvailabilityEngine engine = const AvailabilityEngine(),
    DateTime Function()? now,
    int searchHorizonDays = 30,
  }) {
    if (searchHorizonDays <= 0) {
      throw ArgumentError.value(
        searchHorizonDays,
        'searchHorizonDays',
        'Search horizon must be positive.',
      );
    }

    return ProfileVisitAvailabilityRepository._(
      profileRepository,
      visitQueryRepository,
      engine,
      now ?? DateTime.now,
      searchHorizonDays,
    );
  }

  ProfileVisitAvailabilityRepository._(
    this._profileRepository,
    this._visitQueryRepository,
    this._engine,
    this._now,
    this._searchHorizonDays,
  );

  final DoctorProfileRepository _profileRepository;
  final VisitQueryRepository _visitQueryRepository;
  final AvailabilityEngine _engine;
  final DateTime Function() _now;
  final int _searchHorizonDays;

  @override
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  }) async {
    if (durationMinutes <= 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'Visit duration must be positive.',
      );
    }

    if (limit <= 0) {
      return const [];
    }

    final profile = await _profileRepository.fetchCurrentProfile();

    if (profile == null || profile.workingDays.isEmpty) {
      return const [];
    }

    final effectiveFrom = _laterOf(from, _now()).toLocal();
    final firstDay = _localDay(effectiveFrom);
    final rangeEnd = DateTime(
      firstDay.year,
      firstDay.month,
      firstDay.day + _searchHorizonDays,
    );

    final visits = await _visitQueryRepository.fetchVisits(
      from: firstDay,
      to: rangeEnd,
    );

    final workingIntervals = _buildWorkingIntervals(
      profile: profile,
      firstDay: firstDay,
    );
    final busyIntervals = <AvailabilityInterval>[
      ..._buildRecurringBreakIntervals(
        profile: profile,
        firstDay: firstDay,
      ),
      ..._buildVisitIntervals(visits),
    ];

    final availableIntervals = _engine.findAvailableIntervals(
      workingIntervals: workingIntervals,
      busyIntervals: busyIntervals,
      requestedDurationMinutes: durationMinutes,
      notBefore: effectiveFrom,
    );

    final starts = _engine.findSuggestedStarts(
      availableIntervals: availableIntervals,
      requestedDurationMinutes: durationMinutes,
      startPrecisionMinutes: _startPrecisionMinutes(
        defaultDurationMinutes: profile.defaultDurationMinutes,
        requestedDurationMinutes: durationMinutes,
      ),
      limit: limit,
    );

    return List.unmodifiable(
      starts.map(
        (startsAt) => AvailabilitySlot(
          startsAt: startsAt,
          durationMinutes: durationMinutes,
        ),
      ),
    );
  }

  List<AvailabilityInterval> _buildWorkingIntervals({
    required DoctorProfile profile,
    required DateTime firstDay,
  }) {
    final workdayStart = _parseTime(
      profile.workdayStart,
      fieldName: 'workdayStart',
    );
    final workdayEnd = _parseTime(
      profile.workdayEnd,
      fieldName: 'workdayEnd',
    );
    final workingDays = profile.workingDays.toSet();
    final intervals = <AvailabilityInterval>[];

    for (var offset = 0; offset < _searchHorizonDays; offset++) {
      final day = DateTime(
        firstDay.year,
        firstDay.month,
        firstDay.day + offset,
      );

      if (!workingDays.contains(day.weekday)) {
        continue;
      }

      final startsAt = _atTime(day, workdayStart);
      final endsAt = _atTime(day, workdayEnd);

      if (!startsAt.isBefore(endsAt)) {
        throw StateError('Doctor workday start must be before workday end.');
      }

      intervals.add(
        AvailabilityInterval(startsAt: startsAt, endsAt: endsAt),
      );
    }

    return intervals;
  }

  List<AvailabilityInterval> _buildRecurringBreakIntervals({
    required DoctorProfile profile,
    required DateTime firstDay,
  }) {
    final breakStartValue = profile.breakStart;
    final breakEndValue = profile.breakEnd;

    if (breakStartValue == null || breakEndValue == null) {
      return const [];
    }

    final breakStart = _parseTime(
      breakStartValue,
      fieldName: 'breakStart',
    );
    final breakEnd = _parseTime(
      breakEndValue,
      fieldName: 'breakEnd',
    );
    final workingDays = profile.workingDays.toSet();
    final intervals = <AvailabilityInterval>[];

    for (var offset = 0; offset < _searchHorizonDays; offset++) {
      final day = DateTime(
        firstDay.year,
        firstDay.month,
        firstDay.day + offset,
      );

      if (!workingDays.contains(day.weekday)) {
        continue;
      }

      final startsAt = _atTime(day, breakStart);
      final endsAt = _atTime(day, breakEnd);

      if (!startsAt.isBefore(endsAt)) {
        throw StateError('Doctor break start must be before break end.');
      }

      intervals.add(
        AvailabilityInterval(startsAt: startsAt, endsAt: endsAt),
      );
    }

    return intervals;
  }

  List<AvailabilityInterval> _buildVisitIntervals(List<Visit> visits) {
    return visits
        .where((visit) => visit.occupiesAvailability)
        .where((visit) => visit.startsAt.isBefore(visit.endsAt))
        .map(
          (visit) => AvailabilityInterval(
            startsAt: visit.startsAt.toLocal(),
            endsAt: visit.endsAt.toLocal(),
          ),
        )
        .toList(growable: false);
  }

  int _startPrecisionMinutes({
    required int defaultDurationMinutes,
    required int requestedDurationMinutes,
  }) {
    // The accepted product rule explicitly allows a deliberately selected
    // 15-minute Visit to use 15-minute starts even when the normal practice
    // cadence is coarser.
    if (requestedDurationMinutes == 15) {
      return 15;
    }

    return switch (defaultDurationMinutes) {
      15 => 15,
      30 => 30,
      60 => 60,
      _ => 30,
    };
  }

  _ClockTime _parseTime(String value, {required String fieldName}) {
    final parts = value.trim().split(':');

    if (parts.length < 2 || parts.length > 3) {
      throw StateError('Invalid $fieldName value: $value');
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    final second = parts.length == 3
        ? int.tryParse(parts[2].split('.').first)
        : 0;

    if (hour == null ||
        minute == null ||
        second == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59 ||
        second < 0 ||
        second > 59) {
      throw StateError('Invalid $fieldName value: $value');
    }

    return _ClockTime(hour: hour, minute: minute, second: second);
  }

  DateTime _atTime(DateTime day, _ClockTime time) {
    return DateTime(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
      time.second,
    );
  }

  DateTime _localDay(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  DateTime _laterOf(DateTime first, DateTime second) {
    return first.isAfter(second) ? first : second;
  }
}

class _ClockTime {
  const _ClockTime({
    required this.hour,
    required this.minute,
    required this.second,
  });

  final int hour;
  final int minute;
  final int second;
}
