import '../../features/auth/domain/auth_session_status.dart';

abstract final class AuthRoutePolicy {
  static const String welcomePath = '/welcome';
  static const String regionPath = '/region';
  static const String signUpPath = '/sign-up';
  static const String signInPath = '/sign-in';
  static const String doctorSetupPath = '/doctor-setup';
  static const String clinicSetupPath = '/clinic-setup';
  static const String dashboardPath = '/dashboard';

  static String? redirect({
    required AuthSessionStatus status,
    required String path,
    String doctorSetupRequiredRedirectPath = doctorSetupPath,
    String completedDoctorSetupRedirectPath = dashboardPath,
  }) {
    switch (status) {
      case AuthSessionStatus.initializing:
        return null;

      case AuthSessionStatus.unauthenticated:
        if (_isGuestPath(path)) {
          return null;
        }
        return signInPath;

      case AuthSessionStatus.doctorSetupRequired:
        if (path == doctorSetupPath) {
          return null;
        }
        return doctorSetupRequiredRedirectPath;

      case AuthSessionStatus.ready:
        if (_isAccountEntryPath(path)) {
          return dashboardPath;
        }

        if (path == doctorSetupPath) {
          return completedDoctorSetupRedirectPath;
        }

        return null;
    }
  }

  static bool _isGuestPath(String path) {
    return path == welcomePath ||
        path == regionPath ||
        path == signUpPath ||
        path == signInPath;
  }

  static bool _isAccountEntryPath(String path) {
    return path == welcomePath ||
        path == regionPath ||
        path == signUpPath ||
        path == signInPath;
  }
}
