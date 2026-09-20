import '../../profile/domain/doctor_profile.dart';
import '../../profile/domain/doctor_profile_repository.dart';
import '../../visits/domain/visit.dart';
import '../../visits/domain/visit_repository.dart';
import '../domain/availability_day.dart';
import '../domain/doctor_calendar_time.dart';
import '../domain/availability_day_repository.dart';
import '../domain/availability_engine.dart';
import '../domain/availability_interval.dart';
import '../domain/availability_repository.dart';
import '../domain/availability_range_repository.dart';
import '../domain/availability_slot.dart';
import '../domain/availability_start_precision.dart';
import '../domain/schedule_day_exception.dart';
import '../domain/schedule_day_exception_repository.dart';

/// Production availability adapter for the current single-doctor MVP.
///
/// The repository resolves recurring Doctor Profile scheduling defaults and
/// persisted Visits and one-date schedule exceptions into the generic
/// [AvailabilityEngine] input. Recurring Doctor Profile settings remain the
/// baseline; a persisted exception overrides only its concrete local date.
class ProfileVisitAvailabilityRepository
    implements
        AvailabilityRepository,
        AvailabilityDayRepository,
        AvailabilityRangeRepository {
  factory ProfileVisitAvailabilityRepository({
    required DoctorProfileRepository profileRepository,
    required VisitQueryRepository visitQueryRepository,
    AvailabilityEngine engine = const AvailabilityEngine(),
    DateTime Function()? now,
    int searchHorizonDays = 30,
    String? excludedVisitId,
    ScheduleDayExceptionRepository? scheduleDayExceptionRepository,
    // Keep the production callers on their existing contract until Calendar,
    // Quick Create and Dashboard switch to doctor-zone presentation together.
    bool useDoctorTimeZone = false,
  }) {
    if (searchHorizonDays <= 0) {
      throw ArgumentError.value(
        searchHorizonDays,
        'searchHorizonDays',
        'Search horizon must be positive.',
      );
    }

    final normalizedExcludedVisitId = excludedVisitId?.trim();

    return ProfileVisitAvailabilityRepository._(
      profileRepository,
      visitQueryRepository,
      engine,
      now ?? DateTime.now,
      searchHorizonDays,
      normalizedExcludedVisitId == null || normalizedExcludedVisitId.isEmpty
          ? null
          : normalizedExcludedVisitId,
      scheduleDayExceptionRepository,
      useDoctorTimeZone,
    );
  }

  ProfileVisitAvailabilityRepository._(
    this._profileRepository,
    this._visitQueryRepository,
    this._engine,
    this._now,
    this._searchHorizonDays,
    this._excludedVisitId,
    this._scheduleDayExceptionRepository,
    this._useDoctorTimeZone,
  );

  final DoctorProfileRepository _profileRepository;
  final VisitQueryRepository _visitQueryRepository;
  final AvailabilityEngine _engine;
  final DateTime Function() _now;
  final int _searchHorizonDays;
  final String? _excludedVisitId;
  final ScheduleDayExceptionRepository? _scheduleDayExceptionRepository;
  final bool _useDoctorTimeZone;

  DoctorCalendarTime? _calendarTime(DoctorProfile profile) {
    if (!_useDoctorTimeZone) return null;
    final zoneId = profile.timeZoneId;
    if (zoneId == null || zoneId.trim().isEmpty) {
      throw StateError('Doctor IANA time zone must be configured.');
    }
    return DoctorCalendarTime(zoneId);
  }

  // The repository Day and Range arguments are civil-date labels, not instants.
  // Preserve Y/M/D without converting them through the device time zone.
  DateTime _dayLabel(DateTime day) => DateTime(day.year, day.month, day.day);

  DateTime _doctorDayAt(DoctorCalendarTime calendarTime, DateTime instant) {
    final label = calendarTime.civilDayAt(instant);
    return _dayLabel(label);
  }

  @override
  Future<AvailabilityDay> findDayAvailability({
    required DateTime day,
  }) async {
    final profile = await _profileRepository.fetchCurrentProfile();
    final calendarTime = profile == null ? null : _calendarTime(profile);
    final localDay = calendarTime == null ? _localDay(day) : _dayLabel(day);

    if (profile == null) {
      return AvailabilityDay(
        day: localDay,
        isWorkingDay: false,
      );
    }

    final rangeEnd = DateTime(
      localDay.year,
      localDay.month,
      localDay.day + 1,
    );
    final exception = await _scheduleDayExceptionRepository?.fetchForDay(
      day: localDay,
    );
    final queryRange = calendarTime?.civilRangeUtc(
      firstCivilDay: localDay,
      endExclusiveCivilDay: rangeEnd,
    );
    final visits = await _visitQueryRepository.fetchVisits(
      from: queryRange?.startUtc ?? localDay,
      to: queryRange?.endUtc ?? rangeEnd,
    );

    return _buildAvailabilityDay(
      profile: profile,
      day: localDay,
      isWorkingDay:
          exception?.isWorkingDay ?? profile.workingDays.contains(localDay.weekday),
      visitIntervals: _buildVisitIntervals(visits, calendarTime: calendarTime),
      now: calendarTime == null ? _now().toLocal() : _now().toUtc(),
      calendarTime: calendarTime,
    );
  }

  @override
  Future<List<AvailabilityDay>> findRangeAvailability({
    required DateTime from,
    required DateTime to,
  }) async {
    // from / to are calendar-date labels, never real instants.
    final firstDay = _useDoctorTimeZone ? _dayLabel(from) : _localDay(from);
    final rangeEnd = _useDoctorTimeZone ? _dayLabel(to) : _localDay(to);

    if (!firstDay.isBefore(rangeEnd)) {
      return const [];
    }

    final days = <DateTime>[];
    for (
      var day = firstDay;
      day.isBefore(rangeEnd);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      days.add(day);
    }

    final profile = await _profileRepository.fetchCurrentProfile();
    if (profile == null) {
      return List.unmodifiable(
        days.map(
          (day) => AvailabilityDay(
            day: day,
            isWorkingDay: false,
          ),
        ),
      );
    }

    final calendarTime = _calendarTime(profile);
    final queryRange = calendarTime?.civilRangeUtc(
      firstCivilDay: firstDay,
      endExclusiveCivilDay: rangeEnd,
    );
    final visitsFuture = _visitQueryRepository.fetchVisits(
      from: queryRange?.startUtc ?? firstDay,
      to: queryRange?.endUtc ?? rangeEnd,
    );
    final exceptionsFuture = _scheduleDayExceptionRepository?.fetchForRange(
          from: firstDay,
          to: rangeEnd,
        ) ??
        Future.value(const <ScheduleDayException>[]);

    final visits = await visitsFuture;
    final exceptions = await exceptionsFuture;
    final workingOverrides = _workingOverrides(exceptions);
    final visitIntervals = _buildVisitIntervals(
      visits, calendarTime: calendarTime,
    );
    final now = calendarTime == null ? _now().toLocal() : _now().toUtc();

    return List.unmodifiable(
      days.map(
        (day) => _buildAvailabilityDay(
          profile: profile,
          day: day,
          isWorkingDay: _isWorkingDay(
            profile: profile,
            day: day,
            workingOverrides: workingOverrides,
          ),
          visitIntervals: visitIntervals,
          now: now,
          calendarTime: calendarTime,
        ),
      ),
    );
  }

  AvailabilityDay _buildAvailabilityDay({
    required DoctorProfile profile,
    required DateTime day,
    required bool isWorkingDay,
    required List<AvailabilityInterval> visitIntervals,
    required DateTime now,
    required DoctorCalendarTime? calendarTime,
  }) {
    final defaultWorkdayInterval = _buildDefaultWorkdayIntervalForDay(
      profile: profile,
      day: day,
      calendarTime: calendarTime,
    );

    if (!isWorkingDay) {
      final dayOffIntervals = _engine.findFreeIntervals(
        workingIntervals: [defaultWorkdayInterval],
        busyIntervals: visitIntervals,
        notBefore: now,
      );

      return AvailabilityDay(
        day: day,
        isWorkingDay: false,
        dayOffIntervals: dayOffIntervals,
      );
    }

    final recurringBreak = _buildRecurringBreakIntervalForDay(
      profile: profile,
      day: day,
      isWorkingDay: true,
      calendarTime: calendarTime,
    );
    final clippedBreakIntervals = recurringBreak == null
        ? const <AvailabilityInterval>[]
        : _clipToWorkingInterval(
            interval: recurringBreak,
            workingInterval: defaultWorkdayInterval,
          );
    final breakIntervals = _engine.findFreeIntervals(
      workingIntervals: clippedBreakIntervals,
      busyIntervals: visitIntervals,
      notBefore: now,
    );
    final busyIntervals = <AvailabilityInterval>[
      ...clippedBreakIntervals,
      ...visitIntervals,
    ];
    final availableIntervals = _engine.findFreeIntervals(
      workingIntervals: [defaultWorkdayInterval],
      busyIntervals: busyIntervals,
      notBefore: now,
    );

    return AvailabilityDay(
      day: day,
      isWorkingDay: true,
      availableIntervals: availableIntervals,
      breakIntervals: breakIntervals,
    );
  }

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

    if (profile == null) {
      return const [];
    }

    final calendarTime = _calendarTime(profile);
    final effectiveFrom = _laterOf(from, _now());
    final firstDay = calendarTime == null
        ? _localDay(effectiveFrom)
        : _doctorDayAt(calendarTime, effectiveFrom);
    final rangeEnd = DateTime(
      firstDay.year,
      firstDay.month,
      firstDay.day + _searchHorizonDays,
    );

    final queryRange = calendarTime?.civilRangeUtc(
      firstCivilDay: firstDay,
      endExclusiveCivilDay: rangeEnd,
    );
    final visits = await _visitQueryRepository.fetchVisits(
      from: queryRange?.startUtc ?? firstDay,
      to: queryRange?.endUtc ?? rangeEnd,
    );
    final exceptions = await _scheduleDayExceptionRepository?.fetchForRange(
          from: firstDay,
          to: rangeEnd,
        ) ??
        const <ScheduleDayException>[];
    final workingOverrides = _workingOverrides(exceptions);

    final workingIntervals = _buildWorkingIntervals(
      profile: profile,
      firstDay: firstDay,
      workingOverrides: workingOverrides,
      calendarTime: calendarTime,
    );
    final busyIntervals = <AvailabilityInterval>[
      ..._buildRecurringBreakIntervals(
        profile: profile,
        firstDay: firstDay,
        workingOverrides: workingOverrides,
        calendarTime: calendarTime,
      ),
      ..._buildVisitIntervals(visits, calendarTime: calendarTime),
    ];

    final availableIntervals = _engine.findAvailableIntervals(
      workingIntervals: workingIntervals,
      busyIntervals: busyIntervals,
      requestedDurationMinutes: durationMinutes,
      notBefore: calendarTime == null
          ? effectiveFrom.toLocal()
          : effectiveFrom.toUtc(),
    );

    final starts = _engine.findSuggestedStarts(
      availableIntervals: availableIntervals,
      requestedDurationMinutes: durationMinutes,
      startPrecisionMinutes: resolveAvailabilityStartPrecisionMinutes(
        defaultDurationMinutes: profile.defaultDurationMinutes,
        requestedDurationMinutes: durationMinutes,
      ),
      limit: limit,
      roundUpStart: calendarTime == null
          ? null
          : (instant, precision) => _roundUpDoctorStart(
                calendarTime, instant, precision,
              ),
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
    required Map<String, bool> workingOverrides,
    required DoctorCalendarTime? calendarTime,
  }) {
    final intervals = <AvailabilityInterval>[];

    for (var offset = 0; offset < _searchHorizonDays; offset++) {
      final day = DateTime(
        firstDay.year,
        firstDay.month,
        firstDay.day + offset,
      );
      final interval = _buildWorkingIntervalForDay(
        profile: profile,
        day: day,
        workingOverrides: workingOverrides,
        calendarTime: calendarTime,
      );

      if (interval != null) {
        intervals.add(interval);
      }
    }

    return intervals;
  }

  AvailabilityInterval? _buildWorkingIntervalForDay({
    required DoctorProfile profile,
    required DateTime day,
    required Map<String, bool> workingOverrides,
    required DoctorCalendarTime? calendarTime,
  }) {
    if (!_isWorkingDay(
      profile: profile,
      day: day,
      workingOverrides: workingOverrides,
    )) {
      return null;
    }

    return _buildDefaultWorkdayIntervalForDay(
      profile: profile,
      day: day,
      calendarTime: calendarTime,
    );
  }

  AvailabilityInterval _buildDefaultWorkdayIntervalForDay({
    required DoctorProfile profile,
    required DateTime day,
    required DoctorCalendarTime? calendarTime,
  }) {
    final workdayStart = _parseTime(
      profile.workdayStart,
      fieldName: 'workdayStart',
    );
    final workdayEnd = _parseTime(
      profile.workdayEnd,
      fieldName: 'workdayEnd',
    );
    final startsAt = _atTime(day, workdayStart, calendarTime);
    final endsAt = _atTime(day, workdayEnd, calendarTime);

    if (!startsAt.isBefore(endsAt)) {
      throw StateError('Doctor workday start must be before workday end.');
    }

    return AvailabilityInterval(startsAt: startsAt, endsAt: endsAt);
  }

  List<AvailabilityInterval> _buildRecurringBreakIntervals({
    required DoctorProfile profile,
    required DateTime firstDay,
    required Map<String, bool> workingOverrides,
    required DoctorCalendarTime? calendarTime,
  }) {
    final intervals = <AvailabilityInterval>[];

    for (var offset = 0; offset < _searchHorizonDays; offset++) {
      final day = DateTime(
        firstDay.year,
        firstDay.month,
        firstDay.day + offset,
      );
      final interval = _buildRecurringBreakIntervalForDay(
        profile: profile,
        day: day,
        isWorkingDay: _isWorkingDay(
          profile: profile,
          day: day,
          workingOverrides: workingOverrides,
        ),
        calendarTime: calendarTime,
      );

      if (interval != null) {
        intervals.add(interval);
      }
    }

    return intervals;
  }

  AvailabilityInterval? _buildRecurringBreakIntervalForDay({
    required DoctorProfile profile,
    required DateTime day,
    required bool isWorkingDay,
    required DoctorCalendarTime? calendarTime,
  }) {
    if (!isWorkingDay) {
      return null;
    }

    final breakStartValue = profile.breakStart;
    final breakEndValue = profile.breakEnd;

    if (breakStartValue == null || breakEndValue == null) {
      return null;
    }

    final breakStart = _parseTime(
      breakStartValue,
      fieldName: 'breakStart',
    );
    final breakEnd = _parseTime(
      breakEndValue,
      fieldName: 'breakEnd',
    );
    final startsAt = _atTime(day, breakStart, calendarTime);
    final endsAt = _atTime(day, breakEnd, calendarTime);

    if (!startsAt.isBefore(endsAt)) {
      throw StateError('Doctor break start must be before break end.');
    }

    return AvailabilityInterval(startsAt: startsAt, endsAt: endsAt);
  }

  List<AvailabilityInterval> _clipToWorkingInterval({
    required AvailabilityInterval interval,
    required AvailabilityInterval workingInterval,
  }) {
    final startsAt = interval.startsAt.isAfter(workingInterval.startsAt)
        ? interval.startsAt
        : workingInterval.startsAt;
    final endsAt = interval.endsAt.isBefore(workingInterval.endsAt)
        ? interval.endsAt
        : workingInterval.endsAt;

    if (!startsAt.isBefore(endsAt)) {
      return const [];
    }

    return [
      AvailabilityInterval(startsAt: startsAt, endsAt: endsAt),
    ];
  }

  Map<String, bool> _workingOverrides(
    List<ScheduleDayException> exceptions,
  ) {
    return {
      for (final exception in exceptions)
        _dayKey(exception.day): exception.isWorkingDay,
    };
  }

  bool _isWorkingDay({
    required DoctorProfile profile,
    required DateTime day,
    required Map<String, bool> workingOverrides,
  }) {
    return workingOverrides[_dayKey(day)] ??
        profile.workingDays.contains(day.weekday);
  }

  String _dayKey(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  List<AvailabilityInterval> _buildVisitIntervals(
    List<Visit> visits, {
    required DoctorCalendarTime? calendarTime,
  }) {
    return visits
        .where(
          (visit) =>
              _excludedVisitId == null || visit.id != _excludedVisitId,
        )
        .where((visit) => visit.occupiesAvailability)
        .where((visit) => visit.startsAt.isBefore(visit.endsAt))
        .map(
          (visit) => AvailabilityInterval(
            startsAt: calendarTime == null
                ? visit.startsAt.toLocal()
                : visit.startsAt.toUtc(),
            endsAt: calendarTime == null
                ? visit.endsAt.toLocal()
                : visit.endsAt.toUtc(),
          ),
        )
        .toList(growable: false);
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

  DateTime _atTime(
    DateTime day, _ClockTime time, DoctorCalendarTime? calendarTime,
  ) {
    if (calendarTime != null) {
      return calendarTime.instantAtCivilTimeUtc(
        day, hour: time.hour, minute: time.minute, second: time.second,
      );
    }
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

  // Align starts to the doctor's clock rather than UTC's minute-of-day.
  // A +05:45 zone must offer 09:00 and 09:30, not 09:15 and 09:45.
  DateTime _roundUpDoctorStart(
    DoctorCalendarTime calendarTime, DateTime instant, int precisionMinutes,
  ) {
    var candidate = instant.toUtc();
    if (candidate.second != 0 ||
        candidate.millisecond != 0 || candidate.microsecond != 0) {
      candidate = DateTime.utc(
        candidate.year, candidate.month, candidate.day,
        candidate.hour, candidate.minute + 1,
      );
    }
    for (var minute = 0; minute < 3 * 24 * 60; minute++) {
      final clock = calendarTime.timeAt(candidate);
      if ((clock.hour * 60 + clock.minute) % precisionMinutes == 0) {
        return candidate;
      }
      candidate = candidate.add(const Duration(minutes: 1));
    }
    throw StateError('Could not align doctor-local visit start.');
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
