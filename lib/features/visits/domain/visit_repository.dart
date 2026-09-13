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
