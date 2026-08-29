import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/auth/domain/auth_repository.dart';
import 'package:lumeno/features/auth/domain/auth_session_status.dart';
import 'package:lumeno/features/auth/presentation/controllers/auth_sign_up_controller.dart';

void main() {
  group('AuthSignUpController', () {
    test('returns authenticated result after successful sign up', () async {
      final repository = _FakeAuthRepository();
      final controller = AuthSignUpController(repository);

      addTearDown(controller.dispose);

      final result = await controller.signUp(
        email: 'doctor@example.com',
        password: 'password123',
        accountRegion: 'russia',
      );

      expect(result, AuthSignUpStatus.authenticated);
      expect(controller.isSubmitting, isFalse);
      expect(controller.lastError, isNull);
      expect(controller.lastStackTrace, isNull);

      expect(repository.signUpCalls, 1);
      expect(repository.lastEmail, 'doctor@example.com');
      expect(repository.lastPassword, 'password123');
      expect(repository.lastAccountRegion, 'russia');
    });

    test('returns email confirmation required result', () async {
      final repository = _FakeAuthRepository()
        ..result = AuthSignUpStatus.emailConfirmationRequired;

      final controller = AuthSignUpController(repository);

      addTearDown(controller.dispose);

      final result = await controller.signUp(
        email: 'doctor@example.com',
        password: 'password123',
        accountRegion: 'europe-international',
      );

      expect(result, AuthSignUpStatus.emailConfirmationRequired);
      expect(controller.isSubmitting, isFalse);
      expect(controller.lastError, isNull);
    });

    test('stores repository error and returns null', () async {
      final error = StateError('Sign up failed');

      final repository = _FakeAuthRepository()..error = error;

      final controller = AuthSignUpController(repository);

      addTearDown(controller.dispose);

      final result = await controller.signUp(
        email: 'doctor@example.com',
        password: 'password123',
        accountRegion: 'russia',
      );

      expect(result, isNull);
      expect(controller.isSubmitting, isFalse);
      expect(controller.lastError, same(error));
      expect(controller.lastStackTrace, isNotNull);
    });

    test('ignores a second submit while sign up is in progress', () async {
      final completer = Completer<AuthSignUpStatus>();

      final repository = _FakeAuthRepository()..pendingResult = completer;

      final controller = AuthSignUpController(repository);

      addTearDown(controller.dispose);

      final firstRequest = controller.signUp(
        email: 'doctor@example.com',
        password: 'password123',
        accountRegion: 'russia',
      );

      expect(controller.isSubmitting, isTrue);

      final secondResult = await controller.signUp(
        email: 'another@example.com',
        password: 'different123',
        accountRegion: 'europe-international',
      );

      expect(secondResult, isNull);
      expect(repository.signUpCalls, 1);
      expect(controller.isSubmitting, isTrue);

      completer.complete(AuthSignUpStatus.authenticated);

      expect(await firstRequest, AuthSignUpStatus.authenticated);

      expect(controller.isSubmitting, isFalse);
      expect(repository.signUpCalls, 1);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  AuthSignUpStatus result = AuthSignUpStatus.authenticated;
  Object? error;
  Completer<AuthSignUpStatus>? pendingResult;

  int signUpCalls = 0;

  String? lastEmail;
  String? lastPassword;
  String? lastAccountRegion;

  @override
  AuthSessionStatus get currentStatus {
    return AuthSessionStatus.unauthenticated;
  }

  @override
  Stream<AuthSessionStatus> watchStatus() {
    return const Stream.empty();
  }

  @override
  Future<AuthSignUpStatus> signUp({
    required String email,
    required String password,
    required String accountRegion,
  }) {
    signUpCalls += 1;

    lastEmail = email;
    lastPassword = password;
    lastAccountRegion = accountRegion;

    final currentError = error;

    if (currentError != null) {
      throw currentError;
    }

    final pending = pendingResult;

    if (pending != null) {
      return pending.future;
    }

    return Future.value(result);
  }
}
