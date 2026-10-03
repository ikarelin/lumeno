import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/auth/presentation/pages/sign_in_page.dart';
import 'package:lumeno/features/auth/presentation/pages/sign_up_page.dart';
import 'package:lumeno/features/onboarding/presentation/pages/clinic_setup_page.dart';
import 'package:lumeno/features/onboarding/presentation/pages/doctor_setup_page.dart';
import 'package:lumeno/features/onboarding/presentation/pages/initial_settings_page.dart';
import 'package:lumeno/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Create account and sign in onboarding flows work', (
    tester,
  ) async {
    final router = _buildTestRouter();

    addTearDown(router.dispose);

    await _pumpTestApp(tester, router: router);

    // -------------------------------------------------------------------
    // Create account flow
    // Welcome -> Initial settings -> Sign Up -> Doctor Setup -> Clinic Setup
    // -------------------------------------------------------------------

    expect(find.byType(WelcomePage), findsOneWidget);

    final createAccountButton = find.byType(FilledButton);

    expect(createAccountButton, findsOneWidget);

    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    // Initial settings
    expect(find.byType(InitialSettingsPage), findsOneWidget);

    final settingsContinueButton = find.byType(FilledButton);

    expect(settingsContinueButton, findsOneWidget);

    // A valid device time zone is enough to continue. The user can still
    // open the selector and override it manually.
    expect(find.text('Europe/Moscow'), findsOneWidget);
    expect(find.text('Use this time zone'), findsNothing);
    expect(find.text('Russia'), findsNothing);
    expect(find.text('Europe'), findsNothing);

    expect(
      tester.widget<FilledButton>(settingsContinueButton).onPressed,
      isNotNull,
    );

    await tester.ensureVisible(settingsContinueButton);
    await tester.pumpAndSettle();

    await tester.tap(settingsContinueButton);
    await tester.pumpAndSettle();

    // Sign Up
    expect(find.byType(SignUpPage), findsOneWidget);

    expect(
      router.routeInformationProvider.value.uri.queryParameters['timeZoneId'],
      'Europe/Moscow',
    );

    final signUpFields = find.byType(TextFormField);

    expect(signUpFields, findsNWidgets(3));

    await tester.enterText(signUpFields.at(0), 'doctor@example.com');

    await tester.enterText(signUpFields.at(1), 'password123');

    await tester.enterText(signUpFields.at(2), 'password123');

    final signUpButton = find.byType(FilledButton);

    await tester.ensureVisible(signUpButton);
    await tester.pumpAndSettle();

    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    // Doctor Setup
    expect(find.byType(DoctorSetupPage), findsOneWidget);

    expect(
      router.routeInformationProvider.value.uri.queryParameters['timeZoneId'],
      'Europe/Moscow',
    );

    final doctorFields = find.byType(TextFormField);

    expect(doctorFields, findsNWidgets(2));

    await tester.enterText(doctorFields.at(0), 'Alex Doctor');

    await tester.enterText(doctorFields.at(1), 'Dentist');

    final doctorContinueButton = find.byType(FilledButton);

    await tester.ensureVisible(doctorContinueButton);
    await tester.pumpAndSettle();

    await tester.tap(doctorContinueButton);
    await tester.pumpAndSettle();

    // Clinic Setup
    expect(find.byType(ClinicSetupPage), findsOneWidget);

    final clinicContinueButton = find.byType(FilledButton);

    expect(clinicContinueButton, findsOneWidget);

    expect(tester.widget<FilledButton>(clinicContinueButton).onPressed, isNull);

    final clinicFields = find.byType(TextFormField);

    expect(clinicFields, findsNWidgets(2));

    await tester.enterText(clinicFields.at(0), 'Some Clinic');

    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(clinicContinueButton).onPressed,
      isNotNull,
    );

    // Clinic is optional: verify Add later path.
    final addLaterButton = find.byType(OutlinedButton);

    expect(addLaterButton, findsOneWidget);

    await tester.ensureVisible(addLaterButton);
    await tester.pumpAndSettle();

    await tester.tap(addLaterButton);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard test marker'), findsOneWidget);

    // -------------------------------------------------------------------
    // Sign in flow
    // Welcome -> Sign In -> Dashboard
    // -------------------------------------------------------------------

    router.go('/welcome');
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);

    final signInEntryButton = find.byType(OutlinedButton);

    expect(signInEntryButton, findsOneWidget);

    await tester.tap(signInEntryButton);
    await tester.pumpAndSettle();

    // Sign In remains independent from Initial Settings.
    expect(find.byType(SignInPage), findsOneWidget);

    final signInFields = find.byType(TextFormField);

    expect(signInFields, findsNWidgets(2));

    await tester.enterText(signInFields.at(0), 'doctor@example.com');

    await tester.enterText(signInFields.at(1), 'password123');

    final signInButton = find.byType(FilledButton);

    expect(signInButton, findsOneWidget);

    await tester.ensureVisible(signInButton);
    await tester.pumpAndSettle();

    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard test marker'), findsOneWidget);
  });
}

GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) {
          return const WelcomePage();
        },
      ),
      GoRoute(
        path: '/initial-settings',
        builder: (context, state) {
          return InitialSettingsPage(
            deviceTimeZoneLoader: () async => 'Europe/Moscow',
          );
        },
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) {
          return const SignUpPage();
        },
      ),
      GoRoute(
        path: '/doctor-setup',
        builder: (context, state) {
          return const DoctorSetupPage();
        },
      ),
      GoRoute(
        path: '/clinic-setup',
        builder: (context, state) {
          return const ClinicSetupPage();
        },
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) {
          return const SignInPage();
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          return const Scaffold(
            body: Center(child: Text('Dashboard test marker')),
          );
        },
      ),
    ],
  );
}

Future<void> _pumpTestApp(
  WidgetTester tester, {
  required GoRouter router,
}) async {
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
