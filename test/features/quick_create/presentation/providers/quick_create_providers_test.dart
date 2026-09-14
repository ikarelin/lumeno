import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/quick_create/presentation/providers/quick_create_providers.dart';

void main() {
  test(
    'Quick Create repository providers share the in-memory store by default',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final store = container.read(quickCreateStoreProvider);

      expect(
        identical(container.read(quickCreatePatientRepositoryProvider), store),
        isTrue,
      );
      expect(
        identical(container.read(quickCreateVisitRepositoryProvider), store),
        isTrue,
      );
      expect(
        identical(
          container.read(quickCreateAvailabilityRepositoryProvider),
          store,
        ),
        isTrue,
      );
    },
  );
}
