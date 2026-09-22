import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/patients/domain/patient.dart';
import 'package:lumeno/features/patients/presentation/patient_visits_history_page.dart';
import 'package:lumeno/features/patients/presentation/providers/patient_provider.dart';
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

  // Keep the EasyLocalization ancestor mounted across the four scenarios.
  // Reconstructing it in consecutive testWidgets may finish settling before
  // its asset-loading future builds the localized page on some Flutter runs.
  testWidgets('history: content, pagination, failure and empty state',
      (tester) async {
    final withVisits = _FakeVisitHistoryRepository([
      _visit('scheduled', VisitStatus.scheduled,
          DateTime.utc(2026, 9, 22), 'Check lab results'),
      _visit('completed', VisitStatus.completed,
          DateTime.utc(2026, 9, 20), ''),
      _visit('cancelled', VisitStatus.cancelled,
          DateTime.utc(2026, 9, 19), '  '),
    ]);
    await _pump(tester, withVisits, scenario: 'data');
    expect(withVisits.requestedPatientIds, everyElement('patient-a'));
    expect(find.text('All visits'), findsOneWidget);
    expect(find.text('Test patient'), findsOneWidget);
    expect(find.text('22 September 2026 · 09:00–09:30'), findsOneWidget);
    expect(find.text('Scheduled'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Check lab results'), findsOneWidget);
    expect(find.text('Show more'), findsNothing);
    expect(find.text('Open visit'), findsNWidgets(3));

    final visits = List.generate(
      31,
      (index) => _visit(
        'visit-$index',
        VisitStatus.scheduled,
        DateTime.utc(2026, 9, 22).subtract(Duration(minutes: index)),
        '',
      ),
    );
    final paged = _FakeVisitHistoryRepository(visits);
    await _pump(tester, paged, scenario: 'paging');
    expect(paged.requestedOffsets, [0]);
    final showMore = find.text('Show more');
    expect(showMore, findsOneWidget);
    await tester.ensureVisible(showMore);
    await tester.tap(showMore);
    await tester.pumpAndSettle();
    expect(paged.requestedOffsets, [0, 30]);
    expect(find.text('Show more'), findsNothing);
    expect(find.text('Open visit'), findsNWidgets(31));

    await _pump(
      tester,
      _FakeVisitHistoryRepository(const <Visit>[], failFirstPage: true),
      scenario: 'error',
    );
    expect(find.text('Could not load visit history.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Open visit'), findsNothing);

    await _pump(
      tester,
      _FakeVisitHistoryRepository(const <Visit>[]),
      scenario: 'empty',
    );
    expect(find.text('No visits for this patient yet.'), findsOneWidget);
    expect(find.text('Open visit'), findsNothing);
  });
}

Visit _visit(String id, VisitStatus status, DateTime start, String note) =>
    Visit(
      id: id,
      patientId: 'patient-a',
      clinicId: 'clinic-a',
      startsAt: start,
      durationMinutes: 30,
      status: status,
      note: note,
    );

Future<void> _pump(
  WidgetTester tester,
  PatientVisitQueryRepository repository, {
  required String scenario,
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
        // Each scenario gets a new Riverpod cache but the same initialized
        // EasyLocalization ancestor stays in the widget tree.
        key: ValueKey(scenario),
        retry: (retryCount, error) => null,
        overrides: [
          patientByIdProvider('patient-a').overrideWithValue(
            const AsyncData<Patient?>(
              Patient(id: 'patient-a', name: 'Test patient'),
            ),
          ),
          patientVisitQueryRepositoryProvider.overrideWithValue(repository),
          calendarCivilTimeProvider.overrideWithValue(
            AsyncData<CalendarCivilTime>(
              CalendarCivilTime(doctorTime: DoctorCalendarTime('Asia/Tokyo')),
            ),
          ),
        ],
        child: const _TestApp(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        theme: LumenoTheme.light,
        home: const PatientVisitsHistoryPage(patientId: 'patient-a'),
      );
}

class _FakeVisitHistoryRepository implements PatientVisitQueryRepository {
  _FakeVisitHistoryRepository(this.visits, {this.failFirstPage = false});

  final List<Visit> visits;
  final bool failFirstPage;
  final requestedPatientIds = <String>[];
  final requestedOffsets = <int>[];

  @override
  Future<List<Visit>> fetchPatientVisitsPage({
    required String patientId,
    int offset = 0,
    int pageSize = 30,
  }) async {
    requestedPatientIds.add(patientId);
    requestedOffsets.add(offset);
    if (failFirstPage && offset == 0) {
      throw StateError('synthetic query failure');
    }
    if (offset >= visits.length) return const <Visit>[];
    return visits.skip(offset).take(pageSize).toList();
  }

  @override
  Future<Visit?> fetchNextPatientVisit({
    required String patientId,
    required DateTime from,
  }) async => null;

  @override
  Future<Visit?> fetchLastCompletedPatientVisit({
    required String patientId,
    required DateTime before,
  }) async => null;
}
