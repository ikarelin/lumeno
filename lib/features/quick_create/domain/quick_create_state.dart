import 'package:freezed_annotation/freezed_annotation.dart';

import 'availability_slot.dart';
import 'clinic.dart';
import 'patient.dart';
import 'quick_create_context.dart';
import 'quick_create_inputs.dart';
import 'quick_create_intent.dart';
import 'quick_create_source.dart';

part 'quick_create_state.freezed.dart';

@freezed
abstract class QuickCreateState with _$QuickCreateState {
  const QuickCreateState._();

  const factory QuickCreateState({
    required QuickCreateIntent intent,
    required QuickCreateSource source,
    Patient? selectedPatient,
    Clinic? selectedClinic,
    DateTime? selectedStartsAt,
    required int durationMinutes,
    @Default(PatientDraft()) PatientDraft patientDraft,
    @Default(ClinicDraft()) ClinicDraft clinicDraft,
    @Default('') String patientSearchQuery,
    @Default(<Patient>[]) List<Patient> patientResults,
    @Default(<Clinic>[]) List<Clinic> clinics,
    @Default(<AvailabilitySlot>[]) List<AvailabilitySlot> suggestedSlots,
    @Default('') String visitNoteDraft,
    required bool isSchedulingPatient,
    @Default(false) bool isCreatingPatient,
    @Default(false) bool isCreatingClinic,
    @Default(false) bool isSearchingPatients,
    @Default(false) bool isLoadingClinics,
    @Default(false) bool isLoadingSlots,
    @Default(false) bool isSavingPatient,
    @Default(false) bool isSavingClinic,
    @Default(false) bool isSavingVisit,
    Object? submitError,
  }) = _QuickCreateState;

  factory QuickCreateState.fromContext(QuickCreateContext context) {
    return QuickCreateState(
      intent: context.intent,
      source: context.source,
      selectedPatient: context.patient,
      selectedClinic: context.clinic,
      selectedStartsAt: context.startsAt,
      durationMinutes: context.durationMinutes ?? 30,
      isSchedulingPatient: context.intent != QuickCreateIntent.newPatient,
    );
  }

  bool get canSavePatient =>
      patientDraft.name.trim().isNotEmpty &&
      patientDraft.phone.trim().isNotEmpty;

  bool get canSaveClinic => clinicDraft.name.trim().isNotEmpty;

  bool get canCreateVisit =>
      selectedPatient != null &&
      selectedClinic != null &&
      selectedStartsAt != null &&
      durationMinutes > 0;

  bool get isBusy => isSavingPatient || isSavingClinic || isSavingVisit;

  DateTime? get endsAt =>
      selectedStartsAt?.add(Duration(minutes: durationMinutes));
}
