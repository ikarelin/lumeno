import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/auth/domain/auth_sign_in_repository.dart';
import 'package:lumeno/features/auth/presentation/controllers/auth_sign_in_controller.dart';

void main() {
  group('AuthSignInController', () {
    test('returns true after successful sign in', () async {
      final repository = _FakeAuthSignInRepository();
      final controller = AuthSignInController(repository);

      addTearDown(controller.dispose);

      final result = await controller.signIn(
        email: 'doctor@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(controller.isSubmitting, isFalse);
      expect(controller.lastError, isNull);
      expect(controller.lastStackTrace, isNull);

      expect(repository.signInCalls, 1);
      expect(repository.lastEmail, 'doctor@example.com');
      expect(repository.lastPassword, 'password123');
    });

    test('stores repository error and returns false', () async {
      final error = StateError('Sign in failed');

      final repository = _FakeAuthSignInRepository()..error = error;

      final controller = AuthSignInController(repository);

      addTearDown(controller.dispose);

      final result = await controller.signIn(
        email: 'doctor@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(controller.isSubmitting, isFalse);
      expect(controller.lastError, same(error));
      expect(controller.lastStackTrace, isNotNull);
    });

    test('ignores a second submit while sign in is in progress', () async {
      final completer = Completer<void>();

      final repository = _FakeAuthSignInRepository()..pendingResult = completer;

      final controller = AuthSignInController(repository);

      addTearDown(controller.dispose);

      final firstRequest = controller.signIn(
        email: 'doctor@example.com',
        password: 'password123',
      );

      expect(controller.isSubmitting, isTrue);

      final secondResult = await controller.signIn(
        email: 'another@example.com',
        password: 'different123',
      );

      expect(secondResult, isFalse);
      expect(repository.signInCalls, 1);
      expect(controller.isSubmitting, isTrue);

      completer.complete();

      expect(await firstRequest, isTrue);
      expect(controller.isSubmitting, isFalse);
      expect(repository.signInCalls, 1);
    });
  });
}

class _FakeAuthSignInRepository implements AuthSignInRepository {
  Object? error;
  Completer<void>? pendingResult;

  int signInCalls = 0;

  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> signIn({required String email, required String password}) {
    signInCalls += 1;

    lastEmail = email;
    lastPassword = password;

    final currentError = error;

    if (currentError != null) {
      throw currentError;
    }

    final pending = pendingResult;

    if (pending != null) {
      return pending.future;
    }

    return Future.value();
  }
}
