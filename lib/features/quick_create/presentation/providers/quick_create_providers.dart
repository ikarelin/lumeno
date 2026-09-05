import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../patients/domain/patient_repository.dart';
import '../../data/in_memory_quick_create_store.dart';

final quickCreateStoreProvider = Provider<InMemoryQuickCreateStore>((ref) {
  return InMemoryQuickCreateStore.seeded();
});

final quickCreatePatientRepositoryProvider = Provider<PatientRepository>((ref) {
  return ref.watch(quickCreateStoreProvider);
});
