import 'auth_session_status.dart';

abstract final class AuthUserMetadata {
  static const String accountRegionKey = 'account_region';
  static const String doctorNameKey = 'doctor_name';
  static const String specialtyKey = 'specialty';
  static const String doctorSetupCompletedKey = 'doctor_setup_completed';
  static const String clinicNameKey = 'clinic_name';

  static AuthSessionStatus resolveStatus({
    required bool isAuthenticated,
    required Map<String, dynamic>? metadata,
  }) {
    if (!isAuthenticated) {
      return AuthSessionStatus.unauthenticated;
    }

    final doctorSetupCompleted = metadata?[doctorSetupCompletedKey] == true;

    if (!doctorSetupCompleted) {
      return AuthSessionStatus.doctorSetupRequired;
    }

    return AuthSessionStatus.ready;
  }
}
