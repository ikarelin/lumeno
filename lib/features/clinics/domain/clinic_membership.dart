import 'package:freezed_annotation/freezed_annotation.dart';

import 'clinic.dart';

part 'clinic_membership.freezed.dart';

@freezed
abstract class ClinicMembership with _$ClinicMembership {
  const factory ClinicMembership({
    required Clinic clinic,
    @Default(false) bool isDefault,
  }) = _ClinicMembership;
}
