import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/clinical_notes/domain/create_patient_clinical_note_input.dart';
import 'package:lumeno/features/clinical_notes/domain/patient_clinical_note.dart';
import 'package:lumeno/features/clinical_notes/domain/patient_clinical_note_repository.dart';
import 'package:lumeno/features/clinical_notes/presentation/providers/patient_clinical_note_provider.dart';
import 'package:lumeno/features/patients/presentation/widgets/patient_clinical_notes_section.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';
import 'package:lumeno/features/scheduling/presentation/providers/doctor_time_mode.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';
import 'package:lumeno/features/visits/presentation/providers/visit_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  // Keep EasyLocalization mounted while swapping only ProviderScope scenarios.
  // Reconstructing the localization root in consecutive testWidgets can finish
  // settling before its asset-loading future rebuilds the localized subtree.
  testWidgets(
    'clinical notes: doctor time, linked-Visit retry, and patient cache reset',
    (tester) async {
      final calendarTime = Completer<CalendarCivilTime>();
      final timeNotes = _FakeClinicalNoteRepository();
      final timeVisits = _FakePatientVisitRepository(
        visits: [
          _visit(
            id: 'visit-a',
            patientId: 'patient-a',
            startsAt: DateTime.utc(2026, 9, 22),
          ),
        ],
      );

      await _pumpSection(
        tester,
        scenario: 'doctor-time',
        patientId: 'patient-a',
        notes: timeNotes,
        visits: timeVisits,
        calendarTimeLoader: () => calendarTime.future,
      );

      await tester.tap(find.text('New note').first);
      await tester.pump();

      expect(timeVisits.requestedPatientIds, isEmpty);
      expect(find.text('General note'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      calendarTime.complete(
        CalendarCivilTime(
          doctorTime: DoctorCalendarTime('Asia/Tokyo'),
        ),
      );
      await tester.pumpAndSettle();

      expect(timeVisits.requestedPatientIds, ['patient-a']);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.textContaining('09:00'), findsOneWidget);

      final retryNotes = _FakeClinicalNoteRepository(
        notesByPatient: {
          'patient-a': [
            _note(patientId: 'patient-a', visitId: 'visit-a'),
          ],
        },
      );
      final retryVisits = _FakePatientVisitRepository(
        visits: [
          _visit(
            id: 'visit-a',
            patientId: 'patient-a',
            startsAt: DateTime.utc(2026, 9, 22),
          ),
        ],
        failFirstForPatients: {'patient-a'},
      );

      await _pumpSection(
        tester,
        scenario: 'linked-visit-retry',
        patientId: 'patient-a',
        notes: retryNotes,
        visits: retryVisits,
        calendarTimeLoader: _tokyoTime,
      );

      expect(retryVisits.requestedPatientIds, ['patient-a']);
      final retry = find.text('Could not load visits. Retry');
      expect(retry, findsOneWidget);

      await tester.tap(retry);
      await tester.pumpAndSettle();

      expect(retryVisits.requestedPatientIds, ['patient-a', 'patient-a']);
      expect(find.textContaining('Linked visit ·'), findsOneWidget);

      final patientNotes = _FakeClinicalNoteRepository(
        notesByPatient: {
          'patient-a': [
            _note(patientId: 'patient-a', visitId: 'shared-visit'),
          ],
          'patient-b': [
            _note(patientId: 'patient-b', visitId: 'shared-visit'),
          ],
        },
      );
      final patientVisits = _FakePatientVisitRepository(
        visits: [
          _visit(
            id: 'shared-visit',
            patientId: 'patient-b',
            startsAt: DateTime.utc(2026, 9, 23),
          ),
        ],
        failFirstForPatients: {'patient-a'},
      );

      await _pumpSection(
        tester,
        scenario: 'patient-change',
        patientId: 'patient-a',
        notes: patientNotes,
        visits: patientVisits,
        calendarTimeLoader: _tokyoTime,
      );
      expect(find.text('Could not load visits. Retry'), findsOneWidget);

      await _pumpSection(
        tester,
        scenario: 'patient-change',
        patientId: 'patient-b',
        notes: patientNotes,
        visits: patientVisits,
        calendarTimeLoader: _tokyoTime,
      );

      expect(patientVisits.requestedPatientIds, ['patient-a', 'patient-b']);
      expect(find.text('Could not load visits. Retry'), findsNothing);
      expect(find.textContaining('Linked visit ·'), findsOneWidget);
    },
  );
}

Future<CalendarCivilTime> _tokyoTime() async => CalendarCivilTime(
      doctorTime: DoctorCalendarTime('Asia/Tokyo'),
    );

PatientClinicalNote _note({
  required String patientId,
  required String visitId,
}) =>
    PatientClinicalNote(
      id: 'note-$patientId',
      patientId: patientId,
      visitId: visitId,
      authorUserId: 'doctor-a',
      body: 'Clinical note',
      createdAt: DateTime.utc(2026, 9, 22, 12),
    );

Visit _visit({
  required String id,
  required String patientId,
  required DateTime startsAt,
}) =>
    Visit(
      id: id,
      patientId: patientId,
      clinicId: 'clinic-a',
      startsAt: startsAt,
      durationMinutes: 30,
      status: VisitStatus.completed,
      note: '',
    );

Future<void> _pumpSection(
  WidgetTester tester, {
  required String scenario,
  required String patientId,
  required _FakeClinicalNoteRepository notes,
  required _FakePatientVisitRepository visits,
  required Future<CalendarCivilTime> Function() calendarTimeLoader,
}) async {
  tester.view.physicalSize = const Size(1440, 1050);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      child: ProviderScope(
        key: ValueKey(scenario),
        retry: (retryCount, error) => null,
        overrides: [
          patientClinicalNoteRepositoryProvider.overrideWithValue(notes),
          patientVisitQueryRepositoryProvider.overrideWithValue(visits),
          calendarCivilTimeProvider.overrideWith(
            (ref) => calendarTimeLoader(),
          ),
        ],
        child: _TestApp(patientId: patientId),
      ),
    ),
  );

  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) => MaterialApp(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        home: Scaffold(
          body: PatientClinicalNotesSection(
            key: const ValueKey('clinical-notes-section'),
            patientId: patientId,
            enabled: true,
          ),
        ),
      );
}

class _FakeClinicalNoteRepository implements PatientClinicalNoteRepository {
  _FakeClinicalNoteRepository({
    this.notesByPatient = const <String, List<PatientClinicalNote>>{},
  });

  final Map<String, List<PatientClinicalNote>> notesByPatient;

  @override
  Future<List<PatientClinicalNote>> fetchForPatient({
    required String patientId,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = notesByPatient[patientId] ?? const <PatientClinicalNote>[];
    return rows.skip(offset).take(limit).toList(growable: false);
  }

  @override
  Future<List<PatientClinicalNote>> fetchForVisit({
    required String patientId,
    required String visitId,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = notesByPatient[patientId] ?? const <PatientClinicalNote>[];
    return rows
        .where((note) => note.visitId == visitId)
        .skip(offset)
        .take(limit)
        .toList(growable: false);
  }

  @override
  Future<PatientClinicalNote> create(
    CreatePatientClinicalNoteInput input,
  ) {
    throw UnimplementedError();
  }
}

class _FakePatientVisitRepository implements PatientVisitQueryRepository {
  _FakePatientVisitRepository({
    required this.visits,
    this.failFirstForPatients = const <String>{},
  });

  final List<Visit> visits;
  final Set<String> failFirstForPatients;
  final Set<String> _failedPatients = <String>{};
  final List<String> requestedPatientIds = <String>[];

  @override
  Future<List<Visit>> fetchPatientVisitsPage({
    required String patientId,
    int offset = 0,
    int pageSize = 30,
  }) async {
    requestedPatientIds.add(patientId);
    if (failFirstForPatients.contains(patientId) &&
        _failedPatients.add(patientId)) {
      throw StateError('synthetic linked-Visit failure');
    }

    final rows = visits.where((visit) => visit.patientId == patientId).toList();
    return rows.skip(offset).take(pageSize).toList(growable: false);
  }

  @override
  Future<Visit?> fetchNextPatientVisit({
    required String patientId,
    required DateTime from,
  }) async =>
      null;

  @override
  Future<Visit?> fetchLastCompletedPatientVisit({
    required String patientId,
    required DateTime before,
  }) async =>
      null;
}
