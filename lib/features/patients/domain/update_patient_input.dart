import 'package:freezed_annotation/freezed_annotation.dart';

import 'patient_contact_channel.dart';

part 'update_patient_input.freezed.dart';

@freezed
abstract class UpdatePatientInput with _$UpdatePatientInput {
  const UpdatePatientInput._();

  const factory UpdatePatientInput({
    required String patientId,
    required String name,
    required String phone,
    @Default('') String email,
    @Default('') String telegram,
    @Default(false) bool whatsappAvailable,
    @Default(<PatientContactChannel>{})
    Set<PatientContactChannel> preferredContactChannels,
    @Default('') String note,
  }) = _UpdatePatientInput;

  bool get isValid {
    if (patientId.trim().isEmpty ||
        name.trim().isEmpty ||
        phone.trim().isEmpty) {
      return false;
    }

    if (preferredContactChannels.contains(PatientContactChannel.email) &&
        email.trim().isEmpty) {
      return false;
    }

    if (preferredContactChannels.contains(PatientContactChannel.telegram) &&
        telegram.trim().isEmpty) {
      return false;
    }

    if (preferredContactChannels.contains(PatientContactChannel.whatsapp) &&
        !whatsappAvailable) {
      return false;
    }

    return true;
  }
}
