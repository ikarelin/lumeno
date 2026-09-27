import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/calendar/presentation/widgets/calendar_visit_details_surface.dart';
import 'package:lumeno/features/visits/domain/update_visit_input.dart';
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

  testWidgets('Save changes stays disabled until the edit draft changes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(520, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            visitManagementRepositoryProvider.overrideWithValue(
              _FakeVisitManagementRepository(),
            ),
          ],
          child: const _TestApp(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Edit visit'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    FilledButton saveButton() {
      return tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save changes'),
      );
    }

    expect(saveButton().onPressed, isNull);

    await tester.enterText(find.byType(TextFormField), 'Updated context');
    await tester.pump();

    expect(saveButton().onPressed, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Initial context'), findsOneWidget);
    expect(find.text('Edit visit'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: LumenoTheme.light,
      home: Scaffold(
        body: CalendarVisitDetailsSurface(
          visit: Visit(
            id: 'visit-1',
            patientId: 'patient-1',
            clinicId: 'clinic-1',
            startsAt: DateTime(2026, 9, 28, 10),
            durationMinutes: 60,
            patientName: 'Alex Patient',
            note: 'Initial context',
          ),
          selectedDate: DateTime(2026, 9, 28),
          isDesktop: true,
        ),
      ),
    );
  }
}

class _FakeVisitManagementRepository implements VisitManagementRepository {
  @override
  Future<Visit> updateVisit(UpdateVisitInput input) {
    throw UnsupportedError('Save is not used by this widget test.');
  }

  @override
  Future<void> cancelVisit({required String visitId}) {
    throw UnsupportedError('Cancel Visit is not used by this widget test.');
  }

  @override
  Future<void> deleteVisit({required String visitId}) {
    throw UnsupportedError('Delete is not used by this widget test.');
  }
}
