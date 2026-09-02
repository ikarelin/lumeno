import 'clinic.dart';
import 'patient.dart';
import 'quick_create_intent.dart';
import 'quick_create_source.dart';

class QuickCreateContext {
  const QuickCreateContext({
    required this.intent,
    required this.source,
    this.patient,
    this.clinic,
    this.startsAt,
    this.durationMinutes,
  });

  final QuickCreateIntent intent;
  final QuickCreateSource source;
  final Patient? patient;
  final Clinic? clinic;
  final DateTime? startsAt;
  final int? durationMinutes;
}
