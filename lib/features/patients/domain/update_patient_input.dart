import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_patient_input.freezed.dart';

@freezed
abstract class UpdatePatientInput with _$UpdatePatientInput {
  const UpdatePatientInput._();

  const factory UpdatePatientInput({
    required String patientId,
    required String name,
    required String phone,
    @Default('') String note,
  }) = _UpdatePatientInput;

  bool get isValid =>
      patientId.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      phone.trim().isNotEmpty;
}
