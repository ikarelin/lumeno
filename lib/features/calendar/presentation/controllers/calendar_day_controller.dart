import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scheduling/domain/availability_day.dart';
import '../../../scheduling/presentation/providers/availability_provider.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/presentation/providers/visit_provider.dart';

final calendarDayVisitsProvider =
    FutureProvider.autoDispose.family<List<Visit>, DateTime>((ref, date) async {
      final repository = ref.watch(visitQueryRepositoryProvider);
      final from = DateTime(date.year, date.month, date.day);
      final to = from.add(const Duration(days: 1));

      final visits = await repository.fetchVisits(from: from, to: to);

      return [...visits]
        ..sort((left, right) => left.startsAt.compareTo(right.startsAt));
    });


final calendarDayAvailabilityProvider =
    FutureProvider.autoDispose.family<AvailabilityDay, DateTime>((ref, date) {
      final repository = ref.watch(availabilityDayRepositoryProvider);
      final day = DateTime(date.year, date.month, date.day);

      return repository.findDayAvailability(day: day);
    });
