import '../../profile/domain/doctor_profile_repository.dart';
import '../../visits/domain/visit.dart';
import '../../visits/domain/visit_repository.dart';
import '../domain/availability_engine.dart';
import '../domain/availability_interval.dart';
import '../domain/availability_repository.dart';
import '../domain/availability_slot.dart';
import '../domain/availability_start_precision.dart';

/// Calendar-only availability adapter for an explicit doctor override.
///
/// The supplied [allowedInterval] is already a soft-unavailable interval chosen
/// deliberately by the doctor (for example a Break or recurring Day off).
/// This repository ignores recurring work/break rules inside that one interval,
/// but still treats real scheduled Visits as hard conflicts.
///
/// It is intentionally bounded: normal Quick Create, Dashboard suggestions and
/// patient booking flows continue to use [ProfileVisitAvailabilityRepository].
class VisitOnlyAvailabilityRepository implements AvailabilityRepository {
  factory VisitOnlyAvailabilityRepository({
    required DoctorProfileRepository profileRepository,
    required VisitQueryRepository visitQueryRepository,
    required AvailabilityInterval allowedInterval,
    AvailabilityEngine engine = const AvailabilityEngine(),
    DateTime Function()? now,
  }) {
    return VisitOnlyAvailabilityRepository._(
      profileRepository,
      visitQueryRepository,
      allowedInterval,
      engine,
      now ?? DateTime.now,
    );
  }

  VisitOnlyAvailabilityRepository._(
    this._profileRepository,
    this._visitQueryRepository,
    this._allowedInterval,
    this._engine,
    this._now,
  );

  final DoctorProfileRepository _profileRepository;
  final VisitQueryRepository _visitQueryRepository;
  final AvailabilityInterval _allowedInterval;
  final AvailabilityEngine _engine;
  final DateTime Function() _now;

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

    final allowedInterval = AvailabilityInterval(
      startsAt: _allowedInterval.startsAt.toLocal(),
      endsAt: _allowedInterval.endsAt.toLocal(),
    );
    final effectiveFrom = _laterOf(from.toLocal(), _now().toLocal());

    if (!allowedInterval.endsAt.isAfter(effectiveFrom)) {
      return const [];
    }

    final profile = await _profileRepository.fetchCurrentProfile();
    final startPrecisionMinutes = resolveAvailabilityStartPrecisionMinutes(
      defaultDurationMinutes: profile?.defaultDurationMinutes ?? 30,
      requestedDurationMinutes: durationMinutes,
    );

    final visits = await _visitQueryRepository.fetchVisits(
      from: allowedInterval.startsAt,
      to: allowedInterval.endsAt,
    );
    final visitIntervals = visits
        .where((visit) => visit.occupiesAvailability)
        .where((visit) => visit.startsAt.isBefore(visit.endsAt))
        .map(_toInterval)
        .toList(growable: false);

    final availableIntervals = _engine.findAvailableIntervals(
      workingIntervals: [allowedInterval],
      busyIntervals: visitIntervals,
      requestedDurationMinutes: durationMinutes,
      notBefore: effectiveFrom,
    );
    final starts = _engine.findSuggestedStarts(
      availableIntervals: availableIntervals,
      requestedDurationMinutes: durationMinutes,
      startPrecisionMinutes: startPrecisionMinutes,
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

  AvailabilityInterval _toInterval(Visit visit) {
    return AvailabilityInterval(
      startsAt: visit.startsAt.toLocal(),
      endsAt: visit.endsAt.toLocal(),
    );
  }

  DateTime _laterOf(DateTime first, DateTime second) {
    return first.isAfter(second) ? first : second;
  }
}
