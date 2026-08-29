import 'package:flutter/foundation.dart';

import '../../domain/doctor_setup_repository.dart';

class DoctorSetupController extends ChangeNotifier {
  DoctorSetupController(this._repository);

  final DoctorSetupRepository _repository;

  bool _isSubmitting = false;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _disposed = false;

  bool get isSubmitting => _isSubmitting;

  Object? get lastError => _lastError;

  StackTrace? get lastStackTrace => _lastStackTrace;

  Future<bool> completeDoctorSetup({
    required String doctorName,
    required String specialty,
  }) async {
    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _lastError = null;
    _lastStackTrace = null;
    _notifyListenersIfActive();

    try {
      await _repository.completeDoctorSetup(
        doctorName: doctorName,
        specialty: specialty,
      );

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
