import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/auth_repository.dart';
import '../../domain/auth_session_status.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController(this._repository) {
    _status = _repository.currentStatus;
    _subscription = _repository.watchStatus().listen(
      _handleStatus,
      onError: _handleError,
    );
  }

  final AuthRepository _repository;

  late final StreamSubscription<AuthSessionStatus> _subscription;

  AuthSessionStatus _status = AuthSessionStatus.initializing;
  Object? _lastError;
  StackTrace? _lastStackTrace;

  AuthSessionStatus get status => _status;
  Object? get lastError => _lastError;
  StackTrace? get lastStackTrace => _lastStackTrace;

  void _handleStatus(AuthSessionStatus nextStatus) {
    _status = nextStatus;
    _lastError = null;
    _lastStackTrace = null;

    // GoRouter must refresh for every Supabase auth event, not only when the
    // coarse AuthSessionStatus changes. A direct account switch can be
    // ready(A) -> ready(B); AuthUserScope resets user-scoped Riverpod caches,
    // while this notification makes the router re-evaluate the new session.
    notifyListeners();
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _lastError = error;
    _lastStackTrace = stackTrace;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
