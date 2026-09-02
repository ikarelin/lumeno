import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_context.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_intent.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_models.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_source.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_state.dart';

void main() {
  group('QuickCreateState', () {
    test('derives visit end and readiness from context', () {
      final startsAt = DateTime(2026, 9, 2, 11);

      final state = QuickCreateState.fromContext(
        QuickCreateContext(
          intent: QuickCreateIntent.nextAvailableSlot,
          source: QuickCreateSource.dashboardAvailableSlot,
          patient: const Patient(
            id: 'patient-1',
            name: 'Anna Brown',
            phone: '+1 555 0100',
          ),
          clinic: const Clinic(id: 'clinic-1', name: 'Lumeno Clinic'),
          startsAt: startsAt,
          durationMinutes: 45,
        ),
      );

      expect(state.canCreateVisit, isTrue);
      expect(state.endsAt, DateTime(2026, 9, 2, 11, 45));
      expect(state.isSchedulingPatient, isTrue);
    });

    test('requires a non-empty patient name and phone', () {
      var state = QuickCreateState.fromContext(
        const QuickCreateContext(
          intent: QuickCreateIntent.newPatient,
          source: QuickCreateSource.sidebarQuickAction,
        ),
      );

      expect(state.canSavePatient, isFalse);

      state = state.copyWith(
        patientDraft: const PatientDraft(
          name: 'Maya Stone',
          phone: '+44 7700 900123',
        ),
      );

      expect(state.canSavePatient, isTrue);
      expect(state.canCreateVisit, isFalse);
    });
  });
}
