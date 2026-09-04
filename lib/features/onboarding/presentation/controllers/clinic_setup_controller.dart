import 'package:flutter/foundation.dart';

import '../../../clinics/domain/clinic_repository.dart';
import '../../../clinics/domain/create_clinic_input.dart';

class ClinicSetupController extends ChangeNotifier {
  ClinicSetupController(this._repository);

  final ClinicRepository _repository;

  bool _isSubmitting = false;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _disposed = false;

  bool get isSubmitting => _isSubmitting;

  Object? get lastError => _lastError;

  StackTrace? get lastStackTrace => _lastStackTrace;

  Future<bool> createClinic({required String name, String address = ''}) async {
    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _lastError = null;
    _lastStackTrace = null;
    _notifyListenersIfActive();

    try {
      await _repository.createClinic(
        CreateClinicInput(name: name, address: address),
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
