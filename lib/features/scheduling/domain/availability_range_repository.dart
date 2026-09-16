import 'availability_day.dart';

abstract interface class AvailabilityRangeRepository {
  /// Returns one [AvailabilityDay], in ascending order, for every local calendar day in [from, to).
  Future<List<AvailabilityDay>> findRangeAvailability({
    required DateTime from,
    required DateTime to,
  });
}
