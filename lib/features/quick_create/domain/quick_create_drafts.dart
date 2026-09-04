import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_create_drafts.freezed.dart';

@freezed
abstract class PatientDraft with _$PatientDraft {
  const factory PatientDraft({
    @Default('') String name,
    @Default('') String phone,
    @Default('') String note,
  }) = _PatientDraft;
}

@freezed
abstract class ClinicDraft with _$ClinicDraft {
  const factory ClinicDraft({@Default('') String name}) = _ClinicDraft;
}
