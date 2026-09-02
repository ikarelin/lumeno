import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/in_memory_quick_create_store.dart';

final quickCreateStoreProvider = Provider<InMemoryQuickCreateStore>((ref) {
  return InMemoryQuickCreateStore.seeded();
});
