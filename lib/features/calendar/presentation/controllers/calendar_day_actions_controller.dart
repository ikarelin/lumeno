import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../visits/domain/update_visit_input.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/domain/visit_repository.dart';
import '../../../visits/presentation/providers/visit_provider.dart';

final calendarDayActionsControllerProvider =
    Provider<CalendarDayActionsController>((ref) {
      return CalendarDayActionsController(
        repository: ref.watch(visitManagementRepositoryProvider),
      );
    });

class CalendarDayActionsController {
  const CalendarDayActionsController({required this.repository});

  final VisitManagementRepository repository;

  Future<Visit> updateVisitNote({
    required Visit visit,
    required String note,
  }) {
    return repository.updateVisit(
      UpdateVisitInput(
        visitId: visit.id,
        patientId: visit.patientId,
        clinicId: visit.clinicId,
        startsAt: visit.startsAt,
        durationMinutes: visit.durationMinutes,
        note: note,
      ),
    );
  }

  Future<void> cancelVisit(Visit visit) {
    return repository.cancelVisit(visitId: visit.id);
  }

  Future<void> deleteVisit(Visit visit) {
    return repository.deleteVisit(visitId: visit.id);
  }
}
