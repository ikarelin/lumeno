import 'availability_interval.dart';

class AvailabilityDay {
  AvailabilityDay({
    required this.day,
    required this.isWorkingDay,
    List<AvailabilityInterval> availableIntervals = const [],
    List<AvailabilityInterval> breakIntervals = const [],
    List<AvailabilityInterval> dayOffIntervals = const [],
  }) : availableIntervals = List.unmodifiable(availableIntervals),
       breakIntervals = List.unmodifiable(breakIntervals),
       dayOffIntervals = List.unmodifiable(dayOffIntervals);

  final DateTime day;
  final bool isWorkingDay;
  final List<AvailabilityInterval> availableIntervals;
  final List<AvailabilityInterval> breakIntervals;

  /// Soft-unavailable parts of a recurring non-working day.
  ///
  /// These intervals are intentionally kept separate from normal availability:
  /// regular booking flows must not suggest them, while Calendar may expose
  /// them as an explicit doctor override surface.
  final List<AvailabilityInterval> dayOffIntervals;
}
