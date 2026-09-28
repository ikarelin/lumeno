import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/app_radius.dart';
import 'package:lumeno/app/theme/app_spacing.dart';
import 'package:lumeno/shared/widgets/app_popup_menu.dart';

void main() {
  testWidgets('uses Lumeno popup styling and returns selected value', (
    tester,
  ) async {
    int? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppPopupMenu<int>(
              onSelected: (value) => selected = value,
              itemBuilder: (context) => [
                AppPopupMenuItem<int>(
                  value: 1,
                  label: 'First item',
                ),
              ],
              child: const SizedBox(
                key: ValueKey('popup-trigger'),
                width: 48,
                height: 48,
                child: Icon(Icons.more_vert_rounded),
              ),
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<PopupMenuButton<int>>(
      find.byType(PopupMenuButton<int>),
    );
    final shape = button.shape! as RoundedRectangleBorder;

    expect(shape.borderRadius, BorderRadius.circular(AppRadius.md));
    expect(button.position, PopupMenuPosition.under);

    await tester.tap(find.byKey(const ValueKey('popup-trigger')));
    await tester.pumpAndSettle();

    final item = tester.widget<AppPopupMenuItem<int>>(
      find.byType(AppPopupMenuItem<int>),
    );

    expect(
      item.padding,
      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );

    await tester.tap(find.text('First item'));
    await tester.pumpAndSettle();

    expect(selected, 1);
  });
}
