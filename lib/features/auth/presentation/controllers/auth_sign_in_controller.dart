import 'package:flutter/foundation.dart';

import '../../domain/auth_sign_in_repository.dart';

class AuthSignInController extends ChangeNotifier {
  AuthSignInController(this._repository);

  final AuthSignInRepository _repository;

  bool _isSubmitting = false;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _disposed = false;

  bool get isSubmitting => _isSubmitting;
  Object? get lastError => _lastError;
  StackTrace? get lastStackTrace => _lastStackTrace;

  Future<bool> signIn({required String email, required String password}) async {
    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _lastError = null;
    _lastStackTrace = null;
    _notifyListenersIfActive();

    try {
      await _repository.signIn(email: email, password: password);

      return true;
    } catch (error, stackTrace) {
      _lastError = error;
      _lastStackTrace = stackTrace;

      return false;
    } finally {
      _isSubmitting = false;
      _notifyListenersIfActive();
    }
  }

  void _notifyListenersIfActive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
