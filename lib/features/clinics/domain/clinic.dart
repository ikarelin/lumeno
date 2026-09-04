import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinic.freezed.dart';

@freezed
abstract class Clinic with _$Clinic {
  const factory Clinic({required String id, required String name}) = _Clinic;
}
