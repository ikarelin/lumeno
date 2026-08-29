import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/supabase_auth_session_repository.dart';
import '../../domain/auth_session_status.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController(this._repository) {
    _subscription = _repository.watchStatus().listen(
      _handleStatus,
      onError: _handleError,
    );

    _handleStatus(_repository.currentStatus);
  }

  final SupabaseAuthSessionRepository _repository;

  late final StreamSubscription<AuthSessionStatus> _subscription;

  AuthSessionStatus _status = AuthSessionStatus.initializing;
  Object? _lastError;
  StackTrace? _lastStackTrace;

  AuthSessionStatus get status => _status;

  Object? get lastError => _lastError;

  StackTrace? get lastStackTrace => _lastStackTrace;

  void _handleStatus(AuthSessionStatus nextStatus) {
    final statusChanged = _status != nextStatus;
    final hadError = _lastError != null;

    _status = nextStatus;
    _lastError = null;
    _lastStackTrace = null;

    if (statusChanged || hadError) {
      notifyListeners();
    }
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
