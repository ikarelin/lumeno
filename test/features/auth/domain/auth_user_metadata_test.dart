import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/auth/domain/auth_session_status.dart';
import 'package:lumeno/features/auth/domain/auth_user_metadata.dart';

void main() {
  group('AuthUserMetadata.resolveStatus', () {
    test('returns unauthenticated when there is no authenticated user', () {
      final status = AuthUserMetadata.resolveStatus(
        isAuthenticated: false,
        metadata: {AuthUserMetadata.doctorSetupCompletedKey: true},
      );

      expect(status, AuthSessionStatus.unauthenticated);
    });

    test('requires doctor setup when metadata is null', () {
      final status = AuthUserMetadata.resolveStatus(
        isAuthenticated: true,
        metadata: null,
      );

      expect(status, AuthSessionStatus.doctorSetupRequired);
    });

    test('requires doctor setup when completion flag is missing', () {
      final status = AuthUserMetadata.resolveStatus(
        isAuthenticated: true,
        metadata: {AuthUserMetadata.accountRegionKey: 'europe-international'},
      );

      expect(status, AuthSessionStatus.doctorSetupRequired);
    });

    test('requires doctor setup when completion flag is false', () {
      final status = AuthUserMetadata.resolveStatus(
        isAuthenticated: true,
        metadata: {AuthUserMetadata.doctorSetupCompletedKey: false},
      );

      expect(status, AuthSessionStatus.doctorSetupRequired);
    });

    test('requires doctor setup when completion flag is not boolean true', () {
      final status = AuthUserMetadata.resolveStatus(
        isAuthenticated: true,
        metadata: {AuthUserMetadata.doctorSetupCompletedKey: 'true'},
      );

      expect(status, AuthSessionStatus.doctorSetupRequired);
    });

    test('returns ready when doctor setup is completed', () {
      final status = AuthUserMetadata.resolveStatus(
        isAuthenticated: true,
        metadata: {
          AuthUserMetadata.accountRegionKey: 'russia',
          AuthUserMetadata.doctorNameKey: 'Doctor',
          AuthUserMetadata.specialtyKey: 'Cardiology',
          AuthUserMetadata.doctorSetupCompletedKey: true,
        },
      );

      expect(status, AuthSessionStatus.ready);
    });

    test('clinic metadata does not affect ready status', () {
      final status = AuthUserMetadata.resolveStatus(
        isAuthenticated: true,
        metadata: {
          AuthUserMetadata.doctorSetupCompletedKey: true,
          AuthUserMetadata.clinicNameKey: null,
        },
      );

      expect(status, AuthSessionStatus.ready);
    });
  });
}
