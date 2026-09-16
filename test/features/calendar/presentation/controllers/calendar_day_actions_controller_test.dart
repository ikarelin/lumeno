import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/calendar/presentation/controllers/calendar_day_actions_controller.dart';
import 'package:lumeno/features/visits/domain/update_visit_input.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';

void main() {
  group('CalendarDayActionsController', () {
    test('updates only visit note while preserving scheduling fields', () async {
      final repository = _FakeVisitManagementRepository();
      final controller = CalendarDayActionsController(repository: repository);
      final visit = _visit();

      final updated = await controller.updateVisitNote(
        visit: visit,
        note: 'Updated context',
      );

      final input = repository.lastUpdateInput;
      expect(input, isNotNull);
      expect(input!.visitId, visit.id);
      expect(input.patientId, visit.patientId);
      expect(input.clinicId, visit.clinicId);
      expect(input.startsAt, visit.startsAt);
      expect(input.durationMinutes, visit.durationMinutes);
      expect(input.note, 'Updated context');
      expect(updated.note, 'Updated context');
    });

    test('reschedules visit while preserving non-time fields', () async {
      final repository = _FakeVisitManagementRepository();
      final controller = CalendarDayActionsController(repository: repository);
      final visit = _visit();
      final startsAt = DateTime(2026, 9, 15, 14, 30);

      final updated = await controller.rescheduleVisit(
        visit: visit,
        startsAt: startsAt,
      );

      final input = repository.lastUpdateInput;
      expect(input, isNotNull);
      expect(input!.visitId, visit.id);
      expect(input.patientId, visit.patientId);
      expect(input.clinicId, visit.clinicId);
      expect(input.startsAt, startsAt);
      expect(input.durationMinutes, visit.durationMinutes);
      expect(input.note, visit.note);
      expect(updated.startsAt, startsAt);
      expect(updated.durationMinutes, visit.durationMinutes);
      expect(updated.note, visit.note);
    });

    test('cancels the selected visit', () async {
      final repository = _FakeVisitManagementRepository();
      final controller = CalendarDayActionsController(repository: repository);
      final visit = _visit();

      await controller.cancelVisit(visit);

      expect(repository.cancelledVisitId, visit.id);
    });

    test('deletes the selected visit', () async {
      final repository = _FakeVisitManagementRepository();
      final controller = CalendarDayActionsController(repository: repository);
      final visit = _visit();

      await controller.deleteVisit(visit);

      expect(repository.deletedVisitId, visit.id);
    });
  });
}

Visit _visit() {
  return Visit(
    id: 'visit-1',
    patientId: 'patient-1',
    clinicId: 'clinic-1',
    startsAt: DateTime(2026, 9, 14, 10),
    durationMinutes: 45,
    patientName: 'Alex Patient',
    note: 'Initial context',
  );
}

class _FakeVisitManagementRepository implements VisitManagementRepository {
  UpdateVisitInput? lastUpdateInput;
  String? cancelledVisitId;
  String? deletedVisitId;

  @override
  Future<Visit> updateVisit(UpdateVisitInput input) async {
    lastUpdateInput = input;
    return Visit(
      id: input.visitId,
      patientId: input.patientId,
      clinicId: input.clinicId,
      startsAt: input.startsAt,
      durationMinutes: input.durationMinutes,
      patientName: 'Alex Patient',
      note: input.note,
    );
  }

  @override
  Future<void> cancelVisit({required String visitId}) async {
    cancelledVisitId = visitId;
  }

  @override
  Future<void> deleteVisit({required String visitId}) async {
    deletedVisitId = visitId;
  }
}
