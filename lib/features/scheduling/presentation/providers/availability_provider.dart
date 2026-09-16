import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/doctor_profile_provider.dart';
import '../../../visits/presentation/providers/visit_provider.dart';
import '../../data/profile_visit_availability_repository.dart';
import '../../data/visit_only_availability_repository.dart';
import '../../domain/availability_day_repository.dart';
import '../../domain/availability_engine.dart';
import '../../domain/availability_interval.dart';
import '../../domain/availability_repository.dart';

final availabilityEngineProvider = Provider<AvailabilityEngine>((ref) {
  return const AvailabilityEngine();
});

final profileVisitAvailabilityRepositoryProvider =
    Provider<ProfileVisitAvailabilityRepository>((ref) {
      // Availability is derived from Doctor Profile scheduling defaults.
      // Watching the Future makes profile saves invalidate downstream cached
      // availability (for example an already-mounted Calendar Day) without
      // coupling Profile UI directly to Calendar providers.
      ref.watch(doctorProfileProvider.future);

      return ProfileVisitAvailabilityRepository(
        profileRepository: ref.watch(doctorProfileRepositoryProvider),
        visitQueryRepository: ref.watch(visitQueryRepositoryProvider),
        engine: ref.watch(availabilityEngineProvider),
      );
    });

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return ref.watch(profileVisitAvailabilityRepositoryProvider);
});

final availabilityDayRepositoryProvider =
    Provider<AvailabilityDayRepository>((ref) {
      return ref.watch(profileVisitAvailabilityRepositoryProvider);
    });

final visitOnlyAvailabilityRepositoryProvider =
    Provider.family<AvailabilityRepository, AvailabilityInterval>(
      (ref, allowedInterval) {
        return VisitOnlyAvailabilityRepository(
          profileRepository: ref.watch(doctorProfileRepositoryProvider),
          visitQueryRepository: ref.watch(visitQueryRepositoryProvider),
          allowedInterval: allowedInterval,
          engine: ref.watch(availabilityEngineProvider),
        );
      },
    );
