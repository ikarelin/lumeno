import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase_visit_repository.dart';
import '../../domain/visit_repository.dart';

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  return SupabaseVisitRepository(Supabase.instance.client);
});

final visitQueryRepositoryProvider = Provider<VisitQueryRepository>((ref) {
  return SupabaseVisitRepository(Supabase.instance.client);
});

final visitManagementRepositoryProvider = Provider<VisitManagementRepository>((
  ref,
) {
  return SupabaseVisitRepository(Supabase.instance.client);
});

/// The same Supabase Visit repository, with patient-specific read operations.
final patientVisitQueryRepositoryProvider =
    Provider<PatientVisitQueryRepository>((ref) {
  return SupabaseVisitRepository(Supabase.instance.client);
});
