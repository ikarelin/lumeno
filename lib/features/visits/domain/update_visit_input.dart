import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_visit_input.freezed.dart';

@freezed
abstract class UpdateVisitInput with _$UpdateVisitInput {
  const UpdateVisitInput._();

  const factory UpdateVisitInput({
    required String visitId,
    required String patientId,
    required String clinicId,
    required DateTime startsAt,
    required int durationMinutes,
    @Default('') String note,
  }) = _UpdateVisitInput;

  bool get isValid =>
      visitId.trim().isNotEmpty &&
      patientId.trim().isNotEmpty &&
      clinicId.trim().isNotEmpty &&
      durationMinutes > 0;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
}
