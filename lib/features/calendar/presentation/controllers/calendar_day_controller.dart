import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../visits/domain/visit.dart';
import '../../../visits/presentation/providers/visit_provider.dart';

final calendarDayVisitsProvider =
    FutureProvider.autoDispose.family<List<Visit>, DateTime>((ref, date) {
      final repository = ref.watch(visitQueryRepositoryProvider);
      final from = DateTime(date.year, date.month, date.day);
      final to = from.add(const Duration(days: 1));

      return repository.fetchVisits(from: from, to: to);
    });
