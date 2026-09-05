import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase_patient_repository.dart';
import '../../domain/patient.dart';
import '../../domain/patient_management_repository.dart';
import '../../domain/patient_repository.dart';

final _supabasePatientRepositoryProvider = Provider<SupabasePatientRepository>((
  ref,
) {
  return SupabasePatientRepository(Supabase.instance.client);
});

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return ref.watch(_supabasePatientRepositoryProvider);
});

final patientManagementRepositoryProvider =
    Provider<PatientManagementRepository>((ref) {
      return ref.watch(_supabasePatientRepositoryProvider);
    });

final patientsProvider = FutureProvider<List<Patient>>((ref) {
  final repository = ref.watch(patientManagementRepositoryProvider);

  return repository.fetchPatients();
});
