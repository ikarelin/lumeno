import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/auth/presentation/pages/sign_in_page.dart';
import 'package:lumeno/features/auth/presentation/pages/sign_up_page.dart';
import 'package:lumeno/features/onboarding/presentation/pages/region_page.dart';
import 'package:lumeno/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Welcome -> Region -> Sign Up onboarding flow works', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: '/region',
          builder: (context, state) => const RegionPage(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInPage(),
        ),
      ],
    );

    addTearDown(router.dispose);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: ProviderScope(child: _TestApp(router: router)),
      ),
    );

    await tester.pumpAndSettle();

    // Welcome
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    final createAccountButton = find.byType(FilledButton);

    expect(createAccountButton, findsOneWidget);

    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    // Region
    expect(find.byType(RegionPage), findsOneWidget);

    final continueButton = find.byType(FilledButton);

    expect(continueButton, findsOneWidget);

    // Continue must be disabled before region selection.
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    final unselectedRegionIcons = find.byIcon(Icons.circle_outlined);

    expect(unselectedRegionIcons, findsNWidgets(2));

    // Select Russia.
    await tester.tap(unselectedRegionIcons.first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);

    // Region screen can be taller than the default widget-test viewport.
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Sign Up
    expect(find.byType(SignUpPage), findsOneWidget);

    expect(
      router.routeInformationProvider.value.uri.queryParameters['region'],
      'russia',
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumeno Test',
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: LumenoTheme.light,
      darkTheme: LumenoTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
