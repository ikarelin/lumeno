import 'availability_day.dart';

abstract interface class AvailabilityDayRepository {
  Future<AvailabilityDay> findDayAvailability({
    required DateTime day,
  });
}
