import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase_doctor_profile_repository.dart';
import '../../domain/doctor_profile.dart';
import '../../domain/doctor_profile_repository.dart';

final doctorProfileRepositoryProvider = Provider<DoctorProfileRepository>((
  ref,
) {
  return SupabaseDoctorProfileRepository(Supabase.instance.client);
});

final doctorProfileProvider = FutureProvider<DoctorProfile?>((ref) {
  final repository = ref.watch(doctorProfileRepositoryProvider);

  return repository.fetchCurrentProfile();
});
