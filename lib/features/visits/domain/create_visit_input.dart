import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_visit_input.freezed.dart';

@freezed
abstract class CreateVisitInput with _$CreateVisitInput {
  const CreateVisitInput._();

  const factory CreateVisitInput({
    required String patientId,
    required String clinicId,
    required DateTime startsAt,
    required int durationMinutes,
    @Default('') String note,
  }) = _CreateVisitInput;

  bool get isValid =>
      patientId.trim().isNotEmpty &&
      clinicId.trim().isNotEmpty &&
      durationMinutes > 0;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
}
