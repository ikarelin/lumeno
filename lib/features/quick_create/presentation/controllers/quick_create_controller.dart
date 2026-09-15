import 'package:flutter/foundation.dart';

import '../../../clinics/domain/clinic_membership_repository.dart';
import '../../domain/availability_slot.dart';
import '../../domain/clinic.dart';
import '../../domain/patient.dart';
import '../../domain/quick_create_context.dart';
import '../../domain/quick_create_inputs.dart';
import '../../domain/quick_create_repositories.dart';
import '../../domain/quick_create_state.dart';
import '../../domain/visit.dart';

sealed class QuickCreateResult {
  const QuickCreateResult();
}

class PatientCreatedResult extends QuickCreateResult {
  const PatientCreatedResult({
    required this.patient,
    required this.continueToSchedule,
  });

  final Patient patient;
  final bool continueToSchedule;
}

class VisitCreatedResult extends QuickCreateResult {
  const VisitCreatedResult(this.visit);

  final Visit visit;
}

class QuickCreateController extends ChangeNotifier {
  QuickCreateController({
    required QuickCreateContext context,
    required this.patientRepository,
    required this.clinicRepository,
    required this.visitRepository,
    required this.availabilityRepository,
    int defaultDurationMinutes = 30,
    this.clinicMembershipRepository,
  }) : defaultDurationMinutes = defaultDurationMinutes,
       durationPresetAnchorMinutes =
           context.durationMinutes ?? defaultDurationMinutes,
       _state = QuickCreateState.fromContext(
         context.copyWith(
           durationMinutes: context.durationMinutes ?? defaultDurationMinutes,
         ),
       );

  final PatientRepository patientRepository;
  final ClinicRepository clinicRepository;
  final ClinicMembershipRepository? clinicMembershipRepository;
  final VisitRepository visitRepository;
  final AvailabilityRepository availabilityRepository;
  final int defaultDurationMinutes;
  final int durationPresetAnchorMinutes;

  QuickCreateState _state;
  bool _disposed = false;

  QuickCreateState get state => _state;

  List<int> get durationPresets =>
      _buildDurationPresets(durationPresetAnchorMinutes);

  Future<void> load() async {
    await Future.wait([
      loadClinics(),
      searchPatients(''),
      loadSuggestedSlots(),
    ]);
  }

  Future<void> searchPatients(String query) async {
    _setState(
      _state.copyWith(
        patientSearchQuery: query,
        isSearchingPatients: true,
        submitError: null,
      ),
    );

    try {
      final results = await patientRepository.searchPatients(query);

      _setState(
        _state.copyWith(patientResults: results, isSearchingPatients: false),
      );
    } catch (error) {
      _setState(
        _state.copyWith(isSearchingPatients: false, submitError: error),
      );
    }
  }

  Future<void> loadClinics() async {
    _setState(_state.copyWith(isLoadingClinics: true, submitError: null));

    try {
      final membershipRepository = clinicMembershipRepository;

      if (membershipRepository == null) {
        final clinics = await clinicRepository.fetchClinics();

        _setState(_state.copyWith(clinics: clinics, isLoadingClinics: false));

        return;
      }

      final memberships = await membershipRepository
          .fetchActiveClinicMemberships();

      final clinics = memberships
          .map((membership) => membership.clinic)
          .toList(growable: false);

      var selectedClinic = _state.selectedClinic;

      final selectedClinicIsActive =
          selectedClinic != null &&
          clinics.any((clinic) => clinic.id == selectedClinic!.id);

      if (!selectedClinicIsActive) {
        selectedClinic = null;

        if (clinics.length == 1) {
          selectedClinic = clinics.single;
        } else if (clinics.length > 1) {
          for (final membership in memberships) {
            if (membership.isDefault) {
              selectedClinic = membership.clinic;
              break;
            }
          }
        }
      }

      _setState(
        _state.copyWith(
          clinics: clinics,
          selectedClinic: selectedClinic,
          isLoadingClinics: false,
        ),
      );
    } catch (error) {
      _setState(_state.copyWith(isLoadingClinics: false, submitError: error));
    }
  }

  Future<void> loadSuggestedSlots() async {
    final requestedDurationMinutes = _state.durationMinutes;

    _setState(_state.copyWith(isLoadingSlots: true, submitError: null));

    try {
      final slots = await availabilityRepository.findAvailableSlots(
        from: DateTime.now(),
        durationMinutes: requestedDurationMinutes,
      );

      if (_state.durationMinutes != requestedDurationMinutes) {
        return;
      }

      _setState(_state.copyWith(suggestedSlots: slots, isLoadingSlots: false));
    } catch (error) {
      if (_state.durationMinutes != requestedDurationMinutes) {
        return;
      }

      _setState(_state.copyWith(isLoadingSlots: false, submitError: error));
    }
  }

  void updatePatientDraft({String? name, String? phone, String? note}) {
    _setState(
      _state.copyWith(
        patientDraft: _state.patientDraft.copyWith(
          name: name ?? state.patientDraft.name,
          phone: phone ?? state.patientDraft.phone,
          note: note ?? state.patientDraft.note,
        ),
        submitError: null,
      ),
    );
  }

  void updateClinicDraft(String name) {
    _setState(
      _state.copyWith(
        clinicDraft: _state.clinicDraft.copyWith(name: name),
        submitError: null,
      ),
    );
  }

  void updateVisitNote(String note) {
    _setState(_state.copyWith(visitNoteDraft: note, submitError: null));
  }

  void showPatientCreation() {
    _setState(_state.copyWith(isCreatingPatient: true));
  }

  void cancelPatientCreation() {
    _setState(
      _state.copyWith(
        isCreatingPatient: false,
        patientDraft: _state.patientDraft.copyWith(
          name: '',
          phone: '',
          note: '',
        ),
        submitError: null,
      ),
    );
  }

  void showClinicCreation() {
    if (_state.clinics.isNotEmpty ||
        _state.selectedClinic != null ||
        _state.isSavingClinic) {
      return;
    }

    _setState(_state.copyWith(isCreatingClinic: true, submitError: null));
  }

  void hideClinicCreation() {
    if (_state.isSavingClinic) {
      return;
    }

    _setState(
      _state.copyWith(
        isCreatingClinic: false,
        clinicDraft: _state.clinicDraft.copyWith(name: ''),
        submitError: null,
      ),
    );
  }

  void selectPatient(Patient patient) {
    _setState(
      _state.copyWith(
        selectedPatient: patient,
        isCreatingPatient: false,
        submitError: null,
      ),
    );
  }

  void clearSelectedPatient() {
    _setState(_state.copyWith(selectedPatient: null));
  }

  void selectClinic(Clinic clinic) {
    _setState(
      _state.copyWith(
        selectedClinic: clinic,
        isCreatingClinic: false,
        submitError: null,
      ),
    );
  }

  void selectStartsAt(DateTime startsAt) {
    _setState(_state.copyWith(selectedStartsAt: startsAt, submitError: null));
  }

  void selectSlot(AvailabilitySlot slot) {
    _setState(
      _state.copyWith(
        selectedStartsAt: slot.startsAt,
        durationMinutes: slot.durationMinutes,
        submitError: null,
      ),
    );
  }

  Future<void> setDurationMinutes(int durationMinutes) async {
    if (_state.durationMinutes == durationMinutes) {
      return;
    }

    _setState(
      _state.copyWith(
        durationMinutes: durationMinutes,
        selectedStartsAt: null,
        suggestedSlots: const [],
        submitError: null,
      ),
    );

    await loadSuggestedSlots();
  }

  Future<QuickCreateResult?> savePatient({
    required bool continueToSchedule,
  }) async {
    if (_state.isSavingPatient || !_state.canSavePatient) {
      return null;
    }

    _setState(_state.copyWith(isSavingPatient: true, submitError: null));

    try {
      final draft = _state.patientDraft;

      final patient = await patientRepository.createPatient(
        CreatePatientInput(
          name: draft.name,
          phone: draft.phone,
          note: draft.note,
        ),
      );

      _setState(
        _state.copyWith(
          selectedPatient: patient,
          isSchedulingPatient: continueToSchedule,
          isCreatingPatient: false,
          isSavingPatient: false,
        ),
      );

      return PatientCreatedResult(
        patient: patient,
        continueToSchedule: continueToSchedule,
      );
    } catch (error) {
      _setState(_state.copyWith(isSavingPatient: false, submitError: error));

      return null;
    }
  }

  Future<Clinic?> saveClinic({String address = ''}) async {
    if (_state.isSavingClinic ||
        !_state.canSaveClinic ||
        _state.clinics.isNotEmpty ||
        _state.selectedClinic != null) {
      return null;
    }

    _setState(_state.copyWith(isSavingClinic: true, submitError: null));

    try {
      final draft = _state.clinicDraft;

      final clinic = await clinicRepository.createClinic(
        CreateClinicInput(name: draft.name, address: address),
      );

      _setState(
        _state.copyWith(
          selectedClinic: clinic,
          clinics: [clinic],
          isCreatingClinic: false,
          isSavingClinic: false,
          clinicDraft: draft.copyWith(name: ''),
        ),
      );

      return clinic;
    } catch (error) {
      _setState(_state.copyWith(isSavingClinic: false, submitError: error));

      return null;
    }
  }

  Future<QuickCreateResult?> saveVisit() async {
    if (_state.isSavingVisit || !_state.canCreateVisit) {
      return null;
    }

    _setState(_state.copyWith(isSavingVisit: true, submitError: null));

    try {
      final visit = await visitRepository.createVisit(
        CreateVisitInput(
          patientId: _state.selectedPatient!.id,
          clinicId: _state.selectedClinic!.id,
          startsAt: _state.selectedStartsAt!,
          durationMinutes: _state.durationMinutes,
          note: _state.visitNoteDraft,
        ),
      );

      _setState(_state.copyWith(isSavingVisit: false));

      return VisitCreatedResult(visit);
    } catch (error) {
      _setState(_state.copyWith(isSavingVisit: false, submitError: error));

      return null;
    }
  }

  void _setState(QuickCreateState value) {
    _state = value;

    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

const _standardVisitDurations = <int>[15, 30, 45, 60, 90, 120, 180, 240];

List<int> _buildDurationPresets(int anchorMinutes) {
  final normalizedAnchor = anchorMinutes > 0 ? anchorMinutes : 30;
  final candidates = <int>{
    ..._standardVisitDurations,
    normalizedAnchor,
  }.toList()
    ..sort();

  final anchorIndex = candidates.indexOf(normalizedAnchor);
  var startIndex = anchorIndex > 0 ? anchorIndex - 1 : 0;

  if (startIndex + 4 > candidates.length) {
    startIndex = candidates.length - 4;
  }

  if (startIndex < 0) {
    startIndex = 0;
  }

  return List<int>.unmodifiable(
    candidates.skip(startIndex).take(4),
  );
}
