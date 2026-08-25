import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/files/presentation/files_page.dart';
import '../../features/patients/presentation/patients_page.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',

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
);
