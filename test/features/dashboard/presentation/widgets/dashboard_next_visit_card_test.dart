import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/dashboard/presentation/widgets/dashboard_next_visit_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('shows Visit.note as compact context in the next visit card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(620, 700);
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
        child: const _TestApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('Alex Patient'), findsOneWidget);
    expect(find.text('Mon, 28 Sep'), findsOneWidget);
    expect(find.text('Check ear irritation before the visit'), findsOneWidget);
    expect(find.text('Visit note'), findsNothing);
    expect(tester.takeException(), isNull);

    final note = tester.widget<Text>(
      find.text('Check ear irritation before the visit'),
    );
    expect(note.maxLines, 2);
    expect(note.overflow, TextOverflow.ellipsis);
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
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: DashboardNextVisitCard(
            time: '09:00',
            patientName: 'Alex Patient',
            detail: 'Mon, 28 Sep',
            note: 'Check ear irritation before the visit',
          ),
        ),
      ),
    );
  }
}
