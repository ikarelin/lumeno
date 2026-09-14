import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/doctor_profile_provider.dart';
import '../../../visits/presentation/providers/visit_provider.dart';
import '../../data/profile_visit_availability_repository.dart';
import '../../domain/availability_engine.dart';
import '../../domain/availability_repository.dart';

final availabilityEngineProvider = Provider<AvailabilityEngine>((ref) {
  return const AvailabilityEngine();
});

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return ProfileVisitAvailabilityRepository(
    profileRepository: ref.watch(doctorProfileRepositoryProvider),
    visitQueryRepository: ref.watch(visitQueryRepositoryProvider),
    engine: ref.watch(availabilityEngineProvider),
  );
});
