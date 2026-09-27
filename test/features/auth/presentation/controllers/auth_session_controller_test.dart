import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/auth/domain/auth_repository.dart';
import 'package:lumeno/features/auth/domain/auth_session_status.dart';
import 'package:lumeno/features/auth/presentation/controllers/auth_session_controller.dart';

void main() {
  group('AuthSessionController', () {
    test('notifies listeners when an auth event keeps the same status', () {
      final repository = _FakeAuthRepository(
        currentStatus: AuthSessionStatus.ready,
      );
      final controller = AuthSessionController(repository);

      addTearDown(controller.dispose);
      addTearDown(repository.dispose);

      var notifications = 0;
      controller.addListener(() {
        notifications += 1;
      });

      repository.emit(AuthSessionStatus.ready);

      expect(controller.status, AuthSessionStatus.ready);
      expect(notifications, 1);

      repository.emit(AuthSessionStatus.ready);

      expect(controller.status, AuthSessionStatus.ready);
      expect(notifications, 2);
    });

    test('updates status and clears a previous stream error', () async {
      final repository = _FakeAuthRepository(
        currentStatus: AuthSessionStatus.ready,
      );
      final controller = AuthSessionController(repository);

      addTearDown(controller.dispose);
      addTearDown(repository.dispose);

      final error = StateError('auth stream failed');
      repository.emitError(error);

      await Future<void>.delayed(Duration.zero);

      expect(controller.lastError, same(error));
      expect(controller.lastStackTrace, isNotNull);

      repository.emit(AuthSessionStatus.unauthenticated);

      expect(controller.status, AuthSessionStatus.unauthenticated);
      expect(controller.lastError, isNull);
      expect(controller.lastStackTrace, isNull);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.currentStatus});

  final StreamController<AuthSessionStatus> _statuses =
      StreamController<AuthSessionStatus>.broadcast(sync: true);

  @override
  AuthSessionStatus currentStatus;

  void emit(AuthSessionStatus status) {
    currentStatus = status;
    _statuses.add(status);
  }

  void emitError(Object error) {
    _statuses.addError(error, StackTrace.current);
  }

  void dispose() {
    _statuses.close();
  }

  @override
  Stream<AuthSessionStatus> watchStatus() => _statuses.stream;

  @override
  Future<AuthSignUpStatus> signUp({
    required String email,
    required String password,
    required String accountRegion,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }
}
