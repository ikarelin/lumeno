import 'auth_session_status.dart';

enum AuthSignUpStatus { authenticated, emailConfirmationRequired }

abstract interface class AuthRepository {
  AuthSessionStatus get currentStatus;

  Stream<AuthSessionStatus> watchStatus();

  Future<AuthSignUpStatus> signUp({
    required String email,
    required String password,
    required String accountRegion,
  });
}
