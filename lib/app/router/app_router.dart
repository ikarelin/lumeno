import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/files/presentation/files_page.dart';
import '../../features/onboarding/presentation/pages/region_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/patients/presentation/patients_page.dart';
import '../shell/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',

  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) {
        return const WelcomePage();
      },
    ),

    GoRoute(
      path: '/region',
      builder: (context, state) {
        return const RegionPage();
      },
    ),

    GoRoute(
      path: '/sign-up',
      builder: (context, state) {
        return const SignUpPage();
      },
    ),

    GoRoute(
      path: '/sign-in',
      builder: (context, state) {
        return const SignInPage();
      },
    ),

    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            return const DashboardPage();
          },
        ),
        GoRoute(
          path: '/patients',
          builder: (context, state) {
            return const PatientsPage();
          },
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) {
            return const CalendarPage();
          },
        ),
        GoRoute(
          path: '/files',
          builder: (context, state) {
            return const FilesPage();
          },
        ),
      ],
    ),
  ],
);
