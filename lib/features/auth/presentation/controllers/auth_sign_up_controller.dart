import 'package:flutter/foundation.dart';

import '../../domain/auth_repository.dart';

class AuthSignUpController extends ChangeNotifier {
  AuthSignUpController(this._repository);

  final AuthRepository _repository;

  bool _isSubmitting = false;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _disposed = false;

  bool get isSubmitting => _isSubmitting;

  Object? get lastError => _lastError;

  StackTrace? get lastStackTrace => _lastStackTrace;

  Future<AuthSignUpStatus?> signUp({
    required String email,
    required String password,
    required String accountRegion,
  }) async {
    if (_isSubmitting) {
      return null;
    }

    _isSubmitting = true;
    _lastError = null;
    _lastStackTrace = null;
    _notifyListenersIfActive();

    try {
      return await _repository.signUp(
        email: email,
        password: password,
        accountRegion: accountRegion,
      );
    } catch (error, stackTrace) {
      _lastError = error;
      _lastStackTrace = stackTrace;

      return null;
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
