import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase_clinic_repository.dart';
import '../../domain/clinic.dart';
import '../../domain/clinic_management_repository.dart';
import '../../domain/clinic_membership.dart';
import '../../domain/clinic_membership_repository.dart';
import '../../domain/clinic_repository.dart';

final _supabaseClinicRepositoryProvider = Provider<SupabaseClinicRepository>((
  ref,
) {
  return SupabaseClinicRepository(Supabase.instance.client);
});

final clinicRepositoryProvider = Provider<ClinicRepository>((ref) {
  return ref.watch(_supabaseClinicRepositoryProvider);
});

final clinicMembershipRepositoryProvider = Provider<ClinicMembershipRepository>(
  (ref) {
    return ref.watch(_supabaseClinicRepositoryProvider);
  },
);

final clinicManagementRepositoryProvider = Provider<ClinicManagementRepository>(
  (ref) {
    return ref.watch(_supabaseClinicRepositoryProvider);
  },
);

final clinicsProvider = FutureProvider<List<Clinic>>((ref) {
  final repository = ref.watch(clinicRepositoryProvider);

  return repository.fetchClinics();
});

final clinicMembershipsProvider = FutureProvider<List<ClinicMembership>>((ref) {
  final repository = ref.watch(clinicMembershipRepositoryProvider);

  return repository.fetchActiveClinicMemberships();
});
