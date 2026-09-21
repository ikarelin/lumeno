import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/visit.dart';
import 'visit_provider.dart';

/// A page request has value equality, so Riverpod can cache each patient/page.
typedef PatientVisitsPageKey = ({String patientId, int offset});

/// Injected for deterministic tests; each request obtains a fresh UTC instant.
final patientVisitNowProvider = Provider<DateTime Function()>((ref) {
  return () => DateTime.now().toUtc();
});

final patientNextVisitProvider =
    FutureProvider.autoDispose.family<Visit?, String>((ref, patientId) {
  final repository = ref.watch(patientVisitQueryRepositoryProvider);
  final from = ref.watch(patientVisitNowProvider)();
  return repository.fetchNextPatientVisit(patientId: patientId, from: from);
});

final patientLastCompletedVisitProvider =
    FutureProvider.autoDispose.family<Visit?, String>((ref, patientId) {
  final repository = ref.watch(patientVisitQueryRepositoryProvider);
  final before = ref.watch(patientVisitNowProvider)();
  return repository.fetchLastCompletedPatientVisit(
    patientId: patientId,
    before: before,
  );
});

/// Page size is fixed for the first UI slice; the repository supports 1..100.
final patientVisitsPageProvider =
    FutureProvider.autoDispose.family<List<Visit>, PatientVisitsPageKey>((
  ref,
  key,
) {
  return ref.watch(patientVisitQueryRepositoryProvider).fetchPatientVisitsPage(
        patientId: key.patientId,
        offset: key.offset,
        pageSize: 30,
      );
});
