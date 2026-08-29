abstract interface class AuthSignInRepository {
  Future<void> signIn({required String email, required String password});
}
