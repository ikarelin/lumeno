import 'create_visit_input.dart';
import 'update_visit_input.dart';
import 'visit.dart';

abstract interface class VisitRepository {
  Future<Visit> createVisit(CreateVisitInput input);
}

abstract interface class VisitQueryRepository {
  Future<List<Visit>> fetchVisits({
    required DateTime from,
    required DateTime to,
  });
}

abstract interface class VisitManagementRepository {
  Future<Visit> updateVisit(UpdateVisitInput input);

  Future<void> cancelVisit({required String visitId});

  Future<void> deleteVisit({required String visitId});
}

/// Read-only patient-scoped history. Time comparisons are absolute instants;
/// the doctor's configured IANA time zone is applied only at presentation.
abstract interface class PatientVisitQueryRepository {
  /// Earliest scheduled Visit whose start is not before [from].
  Future<Visit?> fetchNextPatientVisit({
    required String patientId,
    required DateTime from,
  });

  /// Latest explicitly completed Visit whose start precedes [before].
  Future<Visit?> fetchLastCompletedPatientVisit({
    required String patientId,
    required DateTime before,
  });

  /// Descending history, including cancelled Visits. Pages are offset-based;
  /// consumers refresh from page zero after any Visit mutation.
  Future<List<Visit>> fetchPatientVisitsPage({
    required String patientId,
    int offset = 0,
    int pageSize = 30,
  });
}
