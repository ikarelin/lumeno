import 'package:freezed_annotation/freezed_annotation.dart';

part 'availability_slot.freezed.dart';

@freezed
abstract class AvailabilitySlot with _$AvailabilitySlot {
  const AvailabilitySlot._();

  const factory AvailabilitySlot({
    required DateTime startsAt,
    required int durationMinutes,
  }) = _AvailabilitySlot;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
}
