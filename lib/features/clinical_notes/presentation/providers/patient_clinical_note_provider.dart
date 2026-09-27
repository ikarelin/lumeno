import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase_patient_clinical_note_repository.dart';
import '../../domain/patient_clinical_note.dart';
import '../../domain/patient_clinical_note_repository.dart';

final patientClinicalNoteRepositoryProvider =
    Provider<PatientClinicalNoteRepository>((ref) {
  return SupabasePatientClinicalNoteRepository(Supabase.instance.client);
});

final patientClinicalNotesProvider =
    FutureProvider.family<List<PatientClinicalNote>, String>((ref, patientId) {
  return ref.watch(patientClinicalNoteRepositoryProvider).fetchForPatient(
        patientId: patientId,
      );
});

/// Stable value key for patient clinical-note pagination.
typedef PatientClinicalNotesPageKey = ({String patientId, int offset});

final patientClinicalNotesPageProvider = FutureProvider.autoDispose
    .family<List<PatientClinicalNote>, PatientClinicalNotesPageKey>((ref, key) {
  return ref.watch(patientClinicalNoteRepositoryProvider).fetchForPatient(
        patientId: key.patientId,
        limit: 30,
        offset: key.offset,
      );
});
