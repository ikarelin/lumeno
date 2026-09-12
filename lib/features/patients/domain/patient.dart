import 'package:freezed_annotation/freezed_annotation.dart';

import 'patient_contact_channel.dart';

part 'patient.freezed.dart';

@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String name,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String telegram,
    @Default(false) bool whatsappAvailable,
    @Default(<PatientContactChannel>{})
    Set<PatientContactChannel> preferredContactChannels,
    @Default('') String note,
  }) = _Patient;
}
