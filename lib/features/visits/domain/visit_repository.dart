import 'create_visit_input.dart';
import 'visit.dart';

abstract interface class VisitRepository {
  Future<Visit> createVisit(CreateVisitInput input);
}
