import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/scheduling/domain/availability_repository.dart';
import 'package:lumeno/features/scheduling/domain/availability_slot.dart';
import 'package:lumeno/features/scheduling/presentation/widgets/availability_date_time_picker.dart';

void main() {
  testWidgets('shows only availability for the selected day', (tester) async {
    final repository = _FakeAvailabilityRepository([
      AvailabilitySlot(
        startsAt: DateTime(2026, 9, 15, 9),
        durationMinutes: 30,
      ),
      AvailabilitySlot(
        startsAt: DateTime(2026, 9, 15, 9, 30),
        durationMinutes: 30,
      ),
      AvailabilitySlot(
        startsAt: DateTime(2026, 9, 16, 10),
        durationMinutes: 30,
      ),
    ]);

    await tester.pumpWidget(
      _PickerTestApp(
        repository: repository,
        from: DateTime(2026, 9, 15, 8),
      ),
    );
    await tester.pumpAndSettle();

    expect(_timeFinder(DateTime(2026, 9, 15, 9)), findsOneWidget);
    expect(_timeFinder(DateTime(2026, 9, 15, 9, 30)), findsOneWidget);
    expect(_timeFinder(DateTime(2026, 9, 16, 10)), findsNothing);

    await tester.tap(find.text('16'));
    await tester.pumpAndSettle();

    expect(_timeFinder(DateTime(2026, 9, 15, 9)), findsNothing);
    expect(_timeFinder(DateTime(2026, 9, 15, 9, 30)), findsNothing);
    expect(_timeFinder(DateTime(2026, 9, 16, 10)), findsOneWidget);

    expect(repository.lastDurationMinutes, 30);
    expect(repository.lastLimit, greaterThan(1000));
  });

  testWidgets('returns the exact repository slot when a time is selected', (
    tester,
  ) async {
    final expected = AvailabilitySlot(
      startsAt: DateTime(2026, 9, 15, 9, 30),
      durationMinutes: 30,
    );
    final repository = _FakeAvailabilityRepository([expected]);
    AvailabilitySlot? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: LumenoTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 760,
            height: 640,
            child: AvailabilityDateTimePicker(
              availabilityRepository: repository,
              durationMinutes: 30,
              from: DateTime(2026, 9, 15, 8),
              title: 'Choose date & time',
              timesLabel: 'Available times',
              onSelected: (slot) => selected = slot,
              onClose: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final time = _timeFinder(DateTime(2026, 9, 15, 9, 30));
    expect(time, findsOneWidget);
    await tester.ensureVisible(time);
    await tester.pumpAndSettle();
    await tester.tap(time);
    await tester.pump();

    expect(selected, same(expected));
  });

  testWidgets('does not expose slots outside the picker horizon', (
    tester,
  ) async {
    final repository = _FakeAvailabilityRepository([
      AvailabilitySlot(
        startsAt: DateTime(2026, 9, 15, 9),
        durationMinutes: 30,
      ),
      AvailabilitySlot(
        startsAt: DateTime(2026, 10, 20, 11, 45),
        durationMinutes: 30,
      ),
    ]);

    await tester.pumpWidget(
      _PickerTestApp(
        repository: repository,
        from: DateTime(2026, 9, 15, 8),
      ),
    );
    await tester.pumpAndSettle();

    expect(_timeFinder(DateTime(2026, 9, 15, 9)), findsOneWidget);
    expect(_timeFinder(DateTime(2026, 10, 20, 11, 45)), findsNothing);
  });
}

Finder _timeFinder(DateTime startsAt) {
  return find.byKey(
    ValueKey<String>('availability-time-${startsAt.toIso8601String()}'),
    skipOffstage: false,
  );
}

class _PickerTestApp extends StatelessWidget {
  const _PickerTestApp({required this.repository, required this.from});

  final AvailabilityRepository repository;
  final DateTime from;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: LumenoTheme.light,
      home: Scaffold(
        body: SizedBox(
          width: 760,
          height: 640,
          child: AvailabilityDateTimePicker(
            availabilityRepository: repository,
            durationMinutes: 30,
            from: from,
            title: 'Choose date & time',
            timesLabel: 'Available times',
            onSelected: (_) {},
            onClose: () {},
          ),
        ),
      ),
    );
  }
}

class _FakeAvailabilityRepository implements AvailabilityRepository {
  _FakeAvailabilityRepository(this.slots);

  final List<AvailabilitySlot> slots;
  int? lastDurationMinutes;
  int? lastLimit;

  @override
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  }) async {
    lastDurationMinutes = durationMinutes;
    lastLimit = limit;

    return slots
        .where((slot) => !slot.startsAt.isBefore(from))
        .take(limit)
        .toList(growable: false);
  }
}
