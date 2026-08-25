import 'package:flutter_test/flutter_test.dart';

import 'package:lumeno/app/theme/lumeno_theme.dart';

void main() {
  test('Lumeno themes should be Material 3', () {
    expect(LumenoTheme.light.useMaterial3, true);

    expect(LumenoTheme.dark.useMaterial3, true);
  });
}
