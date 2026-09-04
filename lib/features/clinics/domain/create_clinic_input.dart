import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_clinic_input.freezed.dart';

@freezed
abstract class CreateClinicInput with _$CreateClinicInput {
  const CreateClinicInput._();

  const factory CreateClinicInput({
    required String name,
    @Default('') String address,
  }) = _CreateClinicInput;

  bool get isValid => name.trim().isNotEmpty;
}
