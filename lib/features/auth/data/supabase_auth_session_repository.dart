import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_session_status.dart';
import '../domain/auth_sign_in_repository.dart';
import '../domain/auth_user_metadata.dart';

class SupabaseAuthSessionRepository
    implements AuthRepository, AuthSignInRepository {
  SupabaseAuthSessionRepository(this._client);

  final SupabaseClient _client;

  @override
  AuthSessionStatus get currentStatus {
    return _resolveUser(_client.auth.currentSession?.user);
  }

  @override
  Stream<AuthSessionStatus> watchStatus() {
    return _client.auth.onAuthStateChange
        .map((authState) => _resolveUser(authState.session?.user))
        .distinct();
  }

  @override
  Future<AuthSignUpStatus> signUp({
    required String email,
    required String password,
    required String accountRegion,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        AuthUserMetadata.accountRegionKey: accountRegion,
        AuthUserMetadata.doctorSetupCompletedKey: false,
      },
    );

    if (response.session == null) {
      return AuthSignUpStatus.emailConfirmationRequired;
    }

    return AuthSignUpStatus.authenticated;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  AuthSessionStatus _resolveUser(User? user) {
    return AuthUserMetadata.resolveStatus(
      isAuthenticated: user != null,
      metadata: user?.userMetadata,
    );
  }
}
