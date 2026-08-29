import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/router/auth_route_policy.dart';
import 'package:lumeno/features/auth/domain/auth_session_status.dart';

void main() {
  group('AuthRoutePolicy', () {
    group('initializing', () {
      test('does not redirect', () {
        final paths = [
          AuthRoutePolicy.welcomePath,
          AuthRoutePolicy.signInPath,
          AuthRoutePolicy.dashboardPath,
        ];

        for (final path in paths) {
          expect(
            AuthRoutePolicy.redirect(
              status: AuthSessionStatus.initializing,
              path: path,
            ),
            isNull,
          );
        }
      });
    });

    group('unauthenticated', () {
      test('allows guest routes', () {
        final paths = [
          AuthRoutePolicy.welcomePath,
          AuthRoutePolicy.regionPath,
          AuthRoutePolicy.signUpPath,
          AuthRoutePolicy.signInPath,
        ];

        for (final path in paths) {
          expect(
            AuthRoutePolicy.redirect(
              status: AuthSessionStatus.unauthenticated,
              path: path,
            ),
            isNull,
          );
        }
      });

      test('redirects protected routes to sign in', () {
        final paths = [
          AuthRoutePolicy.doctorSetupPath,
          AuthRoutePolicy.clinicSetupPath,
          AuthRoutePolicy.dashboardPath,
          '/patients',
          '/calendar',
          '/files',
        ];

        for (final path in paths) {
          expect(
            AuthRoutePolicy.redirect(
              status: AuthSessionStatus.unauthenticated,
              path: path,
            ),
            AuthRoutePolicy.signInPath,
          );
        }
      });
    });

    group('doctorSetupRequired', () {
      test('allows doctor setup route', () {
        expect(
          AuthRoutePolicy.redirect(
            status: AuthSessionStatus.doctorSetupRequired,
            path: AuthRoutePolicy.doctorSetupPath,
          ),
          isNull,
        );
      });

      test('redirects every other route to doctor setup', () {
        final paths = [
          AuthRoutePolicy.welcomePath,
          AuthRoutePolicy.regionPath,
          AuthRoutePolicy.signUpPath,
          AuthRoutePolicy.signInPath,
          AuthRoutePolicy.clinicSetupPath,
          AuthRoutePolicy.dashboardPath,
          '/patients',
        ];

        for (final path in paths) {
          expect(
            AuthRoutePolicy.redirect(
              status: AuthSessionStatus.doctorSetupRequired,
              path: path,
            ),
            AuthRoutePolicy.doctorSetupPath,
          );
        }
      });

      test('supports a custom doctor setup redirect target', () {
        const target = '/doctor-setup?next=clinic';

        expect(
          AuthRoutePolicy.redirect(
            status: AuthSessionStatus.doctorSetupRequired,
            path: AuthRoutePolicy.signInPath,
            doctorSetupRequiredRedirectPath: target,
          ),
          target,
        );
      });
    });

    group('ready', () {
      test('redirects account-entry routes to dashboard', () {
        final paths = [
          AuthRoutePolicy.welcomePath,
          AuthRoutePolicy.regionPath,
          AuthRoutePolicy.signUpPath,
          AuthRoutePolicy.signInPath,
          AuthRoutePolicy.doctorSetupPath,
        ];

        for (final path in paths) {
          expect(
            AuthRoutePolicy.redirect(
              status: AuthSessionStatus.ready,
              path: path,
            ),
            AuthRoutePolicy.dashboardPath,
          );
        }
      });

      test('allows application routes', () {
        final paths = [
          AuthRoutePolicy.dashboardPath,
          '/patients',
          '/calendar',
          '/files',
        ];

        for (final path in paths) {
          expect(
            AuthRoutePolicy.redirect(
              status: AuthSessionStatus.ready,
              path: path,
            ),
            isNull,
          );
        }
      });

      test('allows optional clinic setup', () {
        expect(
          AuthRoutePolicy.redirect(
            status: AuthSessionStatus.ready,
            path: AuthRoutePolicy.clinicSetupPath,
          ),
          isNull,
        );
      });

      test('supports a custom completed doctor setup redirect target', () {
        expect(
          AuthRoutePolicy.redirect(
            status: AuthSessionStatus.ready,
            path: AuthRoutePolicy.doctorSetupPath,
            completedDoctorSetupRedirectPath: AuthRoutePolicy.clinicSetupPath,
          ),
          AuthRoutePolicy.clinicSetupPath,
        );
      });
    });
  });
}
