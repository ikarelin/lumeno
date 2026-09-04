import 'package:freezed_annotation/freezed_annotation.dart';

import 'clinic.dart';
import 'patient.dart';
import 'quick_create_intent.dart';
import 'quick_create_source.dart';

part 'quick_create_context.freezed.dart';

@freezed
abstract class QuickCreateContext with _$QuickCreateContext {
  const factory QuickCreateContext({
    required QuickCreateIntent intent,
    required QuickCreateSource source,
    Patient? patient,
    Clinic? clinic,
    DateTime? startsAt,
    int? durationMinutes,
  }) = _QuickCreateContext;
}
