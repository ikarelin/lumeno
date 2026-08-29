import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/supabase_auth_session_repository.dart';
import '../../features/auth/domain/auth_session_status.dart';
import '../../features/auth/presentation/controllers/auth_session_controller.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/files/presentation/files_page.dart';
import '../../features/onboarding/data/supabase_doctor_setup_repository.dart';
import '../../features/onboarding/presentation/pages/clinic_setup_page.dart';
import '../../features/onboarding/presentation/pages/doctor_setup_page.dart';
import '../../features/onboarding/presentation/pages/region_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/patients/presentation/patients_page.dart';
import '../shell/app_shell.dart';
import 'auth_route_policy.dart';

const _doctorSetupNextKey = 'next';
const _doctorSetupNextClinic = 'clinic';

final _authRepository = SupabaseAuthSessionRepository(Supabase.instance.client);

final _doctorSetupRepository = SupabaseDoctorSetupRepository(
  Supabase.instance.client,
);

final _authSessionController = AuthSessionController(_authRepository);

final appRouter = GoRouter(
  initialLocation: AuthRoutePolicy.welcomePath,
  refreshListenable: _authSessionController,
  redirect: (context, state) {
    final status = _authSessionController.status;
    final path = state.uri.path;

    final isDoctorSetupPath = path == AuthRoutePolicy.doctorSetupPath;

    final continuesToClinic =
        isDoctorSetupPath &&
        state.uri.queryParameters[_doctorSetupNextKey] ==
            _doctorSetupNextClinic;

    if (status == AuthSessionStatus.doctorSetupRequired &&
        isDoctorSetupPath &&
        !continuesToClinic) {
      return _doctorSetupTarget(state.uri);
    }

    return AuthRoutePolicy.redirect(
      status: status,
      path: path,
      doctorSetupRequiredRedirectPath: _doctorSetupTarget(state.uri),
      completedDoctorSetupRedirectPath: continuesToClinic
          ? _clinicSetupTarget(state.uri)
          : AuthRoutePolicy.dashboardPath,
    );
  },
  routes: [
    GoRoute(
      path: AuthRoutePolicy.welcomePath,
      builder: (context, state) {
        return const WelcomePage();
      },
    ),

    GoRoute(
      path: AuthRoutePolicy.regionPath,
      builder: (context, state) {
        return const RegionPage();
      },
    ),

    GoRoute(
      path: AuthRoutePolicy.signUpPath,
      builder: (context, state) {
        return SignUpPage(authRepository: _authRepository);
      },
    ),

    GoRoute(
      path: AuthRoutePolicy.doctorSetupPath,
      builder: (context, state) {
        return DoctorSetupPage(repository: _doctorSetupRepository);
      },
    ),

    GoRoute(
      path: AuthRoutePolicy.clinicSetupPath,
      builder: (context, state) {
        return const ClinicSetupPage();
      },
    ),

    GoRoute(
      path: AuthRoutePolicy.signInPath,
      builder: (context, state) {
        return SignInPage(repository: _authRepository);
      },
    ),

    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: AuthRoutePolicy.dashboardPath,
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

String _doctorSetupTarget(Uri uri) {
  final queryParameters = <String, String>{
    _doctorSetupNextKey: _doctorSetupNextClinic,
  };

  final region = uri.queryParameters['region'];

  if (region != null && region.isNotEmpty) {
    queryParameters['region'] = region;
  }

  return Uri(
    path: AuthRoutePolicy.doctorSetupPath,
    queryParameters: queryParameters,
  ).toString();
}

String _clinicSetupTarget(Uri uri) {
  final region = uri.queryParameters['region'];

  if (region == null || region.isEmpty) {
    return AuthRoutePolicy.clinicSetupPath;
  }

  return Uri(
    path: AuthRoutePolicy.clinicSetupPath,
    queryParameters: {'region': region},
  ).toString();
}
