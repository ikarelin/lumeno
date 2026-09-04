import 'availability_slot.dart';

abstract interface class AvailabilityRepository {
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  });
}
