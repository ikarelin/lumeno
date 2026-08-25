import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeno/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumeno/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Lumeno app renders dashboard', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],

        path: 'assets/translations',

        fallbackLocale: const Locale('en'),

        startLocale: const Locale('en'),

        child: const ProviderScope(child: LumenoApp()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsOneWidget);
  });
}
