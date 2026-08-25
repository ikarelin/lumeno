import 'package:flutter_test/flutter_test.dart';

import 'package:lumeno/app/app.dart';

void main() {
  testWidgets('Lumeno app renders', (tester) async {
    await tester.pumpWidget(const LumenoApp());

    expect(find.text('Lumeno'), findsOneWidget);
  });
}
