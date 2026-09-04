import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_patient_input.freezed.dart';

@freezed
abstract class CreatePatientInput with _$CreatePatientInput {
  const CreatePatientInput._();

  const factory CreatePatientInput({
    required String name,
    @Default('') String phone,
    @Default('') String note,
  }) = _CreatePatientInput;

  bool get isValid => name.trim().isNotEmpty && phone.trim().isNotEmpty;
}
