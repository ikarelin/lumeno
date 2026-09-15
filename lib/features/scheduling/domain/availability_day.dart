import 'availability_interval.dart';

class AvailabilityDay {
  AvailabilityDay({
    required this.day,
    required this.isWorkingDay,
    List<AvailabilityInterval> availableIntervals = const [],
    List<AvailabilityInterval> breakIntervals = const [],
  }) : availableIntervals = List.unmodifiable(availableIntervals),
       breakIntervals = List.unmodifiable(breakIntervals);

  final DateTime day;
  final bool isWorkingDay;
  final List<AvailabilityInterval> availableIntervals;
  final List<AvailabilityInterval> breakIntervals;
}
