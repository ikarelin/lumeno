import 'availability_slot.dart';
import 'clinic.dart';
import 'patient.dart';
import 'quick_create_context.dart';
import 'quick_create_inputs.dart';
import 'quick_create_intent.dart';
import 'quick_create_source.dart';

const _notProvided = Object();

class QuickCreateState {
  const QuickCreateState({
    required this.intent,
    required this.source,
    required this.durationMinutes,
    required this.isSchedulingPatient,
    this.selectedPatient,
    this.selectedClinic,
    this.selectedStartsAt,
    this.patientDraft = const PatientDraft(),
    this.clinicDraft = const ClinicDraft(),
    this.patientSearchQuery = '',
    this.patientResults = const [],
    this.clinics = const [],
    this.suggestedSlots = const [],
    this.visitNoteDraft = '',
    this.isCreatingPatient = false,
    this.isCreatingClinic = false,
    this.isSearchingPatients = false,
    this.isLoadingClinics = false,
    this.isLoadingSlots = false,
    this.isSavingPatient = false,
    this.isSavingClinic = false,
    this.isSavingVisit = false,
    this.submitError,
  });

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

  final QuickCreateIntent intent;
  final QuickCreateSource source;
  final Patient? selectedPatient;
  final Clinic? selectedClinic;
  final DateTime? selectedStartsAt;
  final int durationMinutes;
  final PatientDraft patientDraft;
  final ClinicDraft clinicDraft;
  final String patientSearchQuery;
  final List<Patient> patientResults;
  final List<Clinic> clinics;
  final List<AvailabilitySlot> suggestedSlots;
  final String visitNoteDraft;
  final bool isSchedulingPatient;
  final bool isCreatingPatient;
  final bool isCreatingClinic;
  final bool isSearchingPatients;
  final bool isLoadingClinics;
  final bool isLoadingSlots;
  final bool isSavingPatient;
  final bool isSavingClinic;
  final bool isSavingVisit;
  final Object? submitError;

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

  QuickCreateState copyWith({
    Object? selectedPatient = _notProvided,
    Object? selectedClinic = _notProvided,
    Object? selectedStartsAt = _notProvided,
    int? durationMinutes,
    PatientDraft? patientDraft,
    ClinicDraft? clinicDraft,
    String? patientSearchQuery,
    List<Patient>? patientResults,
    List<Clinic>? clinics,
    List<AvailabilitySlot>? suggestedSlots,
    String? visitNoteDraft,
    bool? isSchedulingPatient,
    bool? isCreatingPatient,
    bool? isCreatingClinic,
    bool? isSearchingPatients,
    bool? isLoadingClinics,
    bool? isLoadingSlots,
    bool? isSavingPatient,
    bool? isSavingClinic,
    bool? isSavingVisit,
    Object? submitError = _notProvided,
  }) {
    return QuickCreateState(
      intent: intent,
      source: source,
      selectedPatient: identical(selectedPatient, _notProvided)
          ? this.selectedPatient
          : selectedPatient as Patient?,
      selectedClinic: identical(selectedClinic, _notProvided)
          ? this.selectedClinic
          : selectedClinic as Clinic?,
      selectedStartsAt: identical(selectedStartsAt, _notProvided)
          ? this.selectedStartsAt
          : selectedStartsAt as DateTime?,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      patientDraft: patientDraft ?? this.patientDraft,
      clinicDraft: clinicDraft ?? this.clinicDraft,
      patientSearchQuery: patientSearchQuery ?? this.patientSearchQuery,
      patientResults: patientResults ?? this.patientResults,
      clinics: clinics ?? this.clinics,
      suggestedSlots: suggestedSlots ?? this.suggestedSlots,
      visitNoteDraft: visitNoteDraft ?? this.visitNoteDraft,
      isSchedulingPatient: isSchedulingPatient ?? this.isSchedulingPatient,
      isCreatingPatient: isCreatingPatient ?? this.isCreatingPatient,
      isCreatingClinic: isCreatingClinic ?? this.isCreatingClinic,
      isSearchingPatients: isSearchingPatients ?? this.isSearchingPatients,
      isLoadingClinics: isLoadingClinics ?? this.isLoadingClinics,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isSavingPatient: isSavingPatient ?? this.isSavingPatient,
      isSavingClinic: isSavingClinic ?? this.isSavingClinic,
      isSavingVisit: isSavingVisit ?? this.isSavingVisit,
      submitError: identical(submitError, _notProvided)
          ? this.submitError
          : submitError,
    );
  }
}
