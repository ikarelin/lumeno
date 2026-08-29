import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/onboarding/domain/doctor_setup_repository.dart';
import 'package:lumeno/features/onboarding/presentation/controllers/doctor_setup_controller.dart';

void main() {
  group('DoctorSetupController', () {
    test('completes doctor setup successfully', () async {
      final repository = _FakeDoctorSetupRepository();
      final controller = DoctorSetupController(repository);

      addTearDown(controller.dispose);

      final result = await controller.completeDoctorSetup(
        doctorName: 'Dr. Jane Doe',
        specialty: 'Cardiology',
      );

      expect(result, isTrue);
      expect(controller.isSubmitting, isFalse);
      expect(controller.lastError, isNull);
      expect(controller.lastStackTrace, isNull);

      expect(repository.completeCalls, 1);
      expect(repository.lastDoctorName, 'Dr. Jane Doe');
      expect(repository.lastSpecialty, 'Cardiology');
    });

    test('stores repository error and returns false', () async {
      final error = StateError('Doctor setup failed');

      final repository = _FakeDoctorSetupRepository()..error = error;

      final controller = DoctorSetupController(repository);

      addTearDown(controller.dispose);

      final result = await controller.completeDoctorSetup(
        doctorName: 'Dr. Jane Doe',
        specialty: 'Cardiology',
      );

      expect(result, isFalse);
      expect(controller.isSubmitting, isFalse);
      expect(controller.lastError, same(error));
      expect(controller.lastStackTrace, isNotNull);
    });

    test('ignores a second submit while doctor setup is in progress', () async {
      final completer = Completer<void>();

      final repository = _FakeDoctorSetupRepository()
        ..pendingResult = completer;

      final controller = DoctorSetupController(repository);

      addTearDown(controller.dispose);

      final firstRequest = controller.completeDoctorSetup(
        doctorName: 'Dr. Jane Doe',
        specialty: 'Cardiology',
      );

      expect(controller.isSubmitting, isTrue);

      final secondResult = await controller.completeDoctorSetup(
        doctorName: 'Dr. John Smith',
        specialty: 'Neurology',
      );

      expect(secondResult, isFalse);
      expect(repository.completeCalls, 1);
      expect(controller.isSubmitting, isTrue);

      completer.complete();

      expect(await firstRequest, isTrue);

      expect(controller.isSubmitting, isFalse);
      expect(repository.completeCalls, 1);
    });
  });
}

class _FakeDoctorSetupRepository implements DoctorSetupRepository {
  Object? error;
  Completer<void>? pendingResult;

  int completeCalls = 0;

  String? lastDoctorName;
  String? lastSpecialty;

  @override
  Future<void> completeDoctorSetup({
    required String doctorName,
    required String specialty,
  }) {
    completeCalls += 1;

    lastDoctorName = doctorName;
    lastSpecialty = specialty;

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
