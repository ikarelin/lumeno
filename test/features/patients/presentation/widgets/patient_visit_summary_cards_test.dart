import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/patients/presentation/widgets/patient_visit_summary_cards.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';
import 'package:lumeno/features/scheduling/presentation/providers/doctor_time_mode.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';
import 'package:lumeno/features/visits/presentation/providers/patient_visits_provider.dart';
import 'package:lumeno/features/visits/presentation/providers/visit_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('renders doctor-local visit times, details, comments and states', (tester) async {
    tester.view.physicalSize = const Size(1440, 1050);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pump(tester, _FakePatientVisits(
      next: Visit(
        id: 'visit-next',
        patientId: 'patient-a',
        clinicId: 'clinic-1',
        // 09:00 Asia/Tokyo, 03:00 Europe/Moscow: keep the UTC instant.
        startsAt: DateTime.utc(2026, 9, 22),
        durationMinutes: 30,
        note: 'Check lab results',
      ),
      last: Visit(
        id: 'visit-last',
        patientId: 'patient-a',
        clinicId: 'clinic-1',
        startsAt: DateTime(2026, 9, 12, 11),
        durationMinutes: 30,
        status: VisitStatus.completed,
        note: '  ',
      ),
    ));

    expect(find.text('Next visit'), findsOneWidget);
    expect(find.text('22 September 2026 · 09:00'), findsOneWidget);
    expect(find.text('Last visit'), findsOneWidget);
    expect(find.text('Check lab results'), findsOneWidget);
    expect(find.text('Doctor comment'), findsNothing); // No invented text.
    expect(find.text('Open visit'), findsNWidgets(2));
    await tester.tap(find.text('Open visit').first);
    await tester.pumpAndSettle();
    expect(find.text('09:00 - 09:30'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pumpAndSettle();

    // Keep the initialized EasyLocalization ancestor mounted. A second
    // testWidgets could finish pumpAndSettle before its asset loading had
    // built the app at all (and tester.element would then throw).
    await _pump(tester, _FakePatientVisits(), showErrorState: true);
    expect(find.byType(PatientVisitSummaryCards), findsOneWidget);
    expect(find.text('Could not load this visit.'), findsOneWidget);
    expect(find.text('No completed visits yet'), findsOneWidget);
    expect(find.text('Open visit'), findsNothing);
  });
}

Future<void> _pump(
  WidgetTester tester,
  PatientVisitQueryRepository repository, {
  bool showErrorState = false,
}) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      child: ProviderScope(
        // Re-create the test container when switching scenarios, so Riverpod
        // cannot reuse the prior scenario's cached Visit futures.
        key: ValueKey(showErrorState ? 'error-state' : 'visit-data'),
        // Avoid Riverpod 3's automatic retries masking the error state under test.
        // This setting only applies to this widget-test container.
        retry: (retryCount, error) => null,
        overrides: [
          patientVisitQueryRepositoryProvider.overrideWithValue(repository),
          calendarCivilTimeProvider.overrideWithValue(
            AsyncData<CalendarCivilTime>(
              CalendarCivilTime(
                doctorTime: DoctorCalendarTime('Asia/Tokyo'),
              ),
            ),
          ),
          if (showErrorState) ...[
            // Test the UI states without depending on the timing of an async
            // repository failure; the real providers are tested separately.
            patientNextVisitProvider('patient-a').overrideWithValue(
              AsyncValue<Visit?>.error(
                StateError('synthetic query failure'),
                StackTrace.current,
              ),
            ),
            patientLastCompletedVisitProvider('patient-a').overrideWithValue(
              const AsyncData<Visit?>(null),
            ),
          ],
        ],
        child: const _TestApp(),
      ),
    ),
  );
  // A single zero-duration settle may return while EasyLocalization's asset
  // future still awaits its first frame (especially in concurrent test runs).
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
        home: const Scaffold(
          body: SingleChildScrollView(
            child: PatientVisitSummaryCards(
              patientId: 'patient-a',
              canOpenDetails: true,
            ),
          ),
        ),
      );
}

class _FakePatientVisits implements PatientVisitQueryRepository {
  _FakePatientVisits({this.next, this.last});

  final Visit? next;
  final Visit? last;

  @override
  Future<Visit?> fetchNextPatientVisit({
    required String patientId,
    required DateTime from,
  }) async {
    return next;
  }

  @override
  Future<Visit?> fetchLastCompletedPatientVisit({
    required String patientId,
    required DateTime before,
  }) async => last;

  @override
  Future<List<Visit>> fetchPatientVisitsPage({
    required String patientId,
    int offset = 0,
    int pageSize = 30,
  }) async => const <Visit>[];
}
