import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_context.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_intent.dart';
import 'package:lumeno/features/quick_create/domain/quick_create_source.dart';
import 'package:lumeno/features/quick_create/presentation/quick_create_presenter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('uses a desktop panel and the same surface in a mobile sheet', (
    tester,
  ) async {
    await _setViewSize(tester, const Size(1280, 900));
    await _pumpLauncher(tester);

    await tester.tap(find.text('Open Quick Create'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick-create-desktop-panel')), findsOneWidget);
    expect(find.text('New patient'), findsOneWidget);
    expect(find.byKey(const Key('quick-create-visit-fields')), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Quick Create'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick-create-mobile-sheet')), findsOneWidget);
    expect(find.text('New patient'), findsOneWidget);
  });
}

Future<void> _pumpLauncher(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      child: const ProviderScope(child: _LauncherApp()),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

Future<void> _setViewSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _LauncherApp extends StatelessWidget {
  const _LauncherApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: LumenoTheme.light,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  unawaited(
                    QuickCreatePresenter.show(
                      context,
                      const QuickCreateContext(
                        intent: QuickCreateIntent.newPatient,
                        source: QuickCreateSource.sidebarQuickAction,
                      ),
                    ),
                  );
                },
                child: const Text('Open Quick Create'),
              ),
            ),
          );
        },
      ),
    );
  }
}
