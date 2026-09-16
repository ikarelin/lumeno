import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/domain/doctor_profile.dart';
import '../../../profile/presentation/providers/doctor_profile_provider.dart';
import '../../../scheduling/domain/availability_repository.dart';
import '../../../scheduling/domain/availability_slot.dart';
import '../../../scheduling/presentation/providers/availability_provider.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/domain/visit_repository.dart';
import '../../../visits/presentation/providers/visit_provider.dart';

final dashboardVisitsProvider =
    FutureProvider.autoDispose<DashboardVisitsData>((ref) {
      return DashboardVisitsController(
        visitQueryRepository: ref.watch(visitQueryRepositoryProvider),
      ).load();
    });

final dashboardAvailabilityProvider =
    FutureProvider.autoDispose<DashboardAvailabilityData>((ref) async {
      final availabilityRepository = ref.watch(availabilityRepositoryProvider);
      final profile = await ref.watch(doctorProfileProvider.future);

      return DashboardAvailabilityController(
        availabilityRepository: availabilityRepository,
      ).load(profile: profile);
    });

class DashboardVisitsData {
  const DashboardVisitsData({
    required this.nextVisit,
    required this.upcomingVisits,
  });

  final Visit? nextVisit;
  final List<Visit> upcomingVisits;
}

class DashboardAvailabilityData {
  const DashboardAvailabilityData._({
    required this.status,
    this.slot,
  });

  const DashboardAvailabilityData.ready(AvailabilitySlot slot)
    : this._(status: DashboardAvailabilityStatus.ready, slot: slot);

  const DashboardAvailabilityData.scheduleNotConfigured()
    : this._(status: DashboardAvailabilityStatus.scheduleNotConfigured);

  const DashboardAvailabilityData.noSlots()
    : this._(status: DashboardAvailabilityStatus.noSlots);

  final DashboardAvailabilityStatus status;
  final AvailabilitySlot? slot;
}

enum DashboardAvailabilityStatus { ready, scheduleNotConfigured, noSlots }

class DashboardVisitsController {
  DashboardVisitsController({
    required this.visitQueryRepository,
    DateTime Function()? now,
    this.futureWindow = const Duration(days: 365),
    this.upcomingVisitLimit = 3,
  }) : _now = now ?? DateTime.now;

  final VisitQueryRepository visitQueryRepository;
  final DateTime Function() _now;
  final Duration futureWindow;
  final int upcomingVisitLimit;

  Future<DashboardVisitsData> load() async {
    final now = _now().toLocal();
    final visits = await visitQueryRepository.fetchVisits(
      from: now,
      to: now.add(futureWindow),
    );

    final futureVisits = visits
        .where((visit) => visit.status == VisitStatus.scheduled)
        .where((visit) => !visit.startsAt.toLocal().isBefore(now))
        .toList(growable: false)
      ..sort(
        (left, right) =>
            left.startsAt.toLocal().compareTo(right.startsAt.toLocal()),
      );

    final nextVisit = futureVisits.isEmpty ? null : futureVisits.first;
    final upcomingVisits = futureVisits.length <= 1
        ? const <Visit>[]
        : futureVisits
              .skip(1)
              .take(upcomingVisitLimit)
              .toList(growable: false);

    return DashboardVisitsData(
      nextVisit: nextVisit,
      upcomingVisits: List<Visit>.unmodifiable(upcomingVisits),
    );
  }
}

class DashboardAvailabilityController {
  DashboardAvailabilityController({
    required this.availabilityRepository,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AvailabilityRepository availabilityRepository;
  final DateTime Function() _now;

  Future<DashboardAvailabilityData> load({
    required DoctorProfile? profile,
  }) async {
    if (profile == null) {
      return const DashboardAvailabilityData.scheduleNotConfigured();
    }

    final slots = await availabilityRepository.findAvailableSlots(
      from: _now().toLocal(),
      durationMinutes: profile.defaultDurationMinutes,
      limit: 1,
    );

    if (slots.isNotEmpty) {
      return DashboardAvailabilityData.ready(slots.first);
    }

    if (profile.workingDays.isEmpty) {
      return const DashboardAvailabilityData.scheduleNotConfigured();
    }

    return const DashboardAvailabilityData.noSlots();
  }
}
