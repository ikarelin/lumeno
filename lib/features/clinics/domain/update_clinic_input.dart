import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_clinic_input.freezed.dart';

@freezed
abstract class UpdateClinicInput with _$UpdateClinicInput {
  const UpdateClinicInput._();

  const factory UpdateClinicInput({
    required String clinicId,
    required String name,
    @Default('') String address,
  }) = _UpdateClinicInput;

  bool get isValid => clinicId.trim().isNotEmpty && name.trim().isNotEmpty;
}
