import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/theme/lumeno_theme.dart';
import 'package:lumeno/features/scheduling/domain/availability_repository.dart';
import 'package:lumeno/features/scheduling/domain/availability_slot.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';
import 'package:lumeno/features/scheduling/presentation/widgets/availability_date_time_picker.dart';

void main() {
  testWidgets('DST repeated slots are distinguishable and preserve UTC instant', (
    tester,
  ) async {
    final first = AvailabilitySlot(
      startsAt: DateTime.utc(2026, 10, 25, 0, 30),
      durationMinutes: 30,
    );
    final second = AvailabilitySlot(
      startsAt: DateTime.utc(2026, 10, 25, 1, 30),
      durationMinutes: 30,
    );
    final outsideHorizon = AvailabilitySlot(
      startsAt: DateTime.utc(2026, 10, 26, 0, 30),
      durationMinutes: 30,
    );
    AvailabilitySlot? selected;
    await tester.pumpWidget(_TestApp(
      slots: [first, second, outsideHorizon],
      from: DateTime.utc(2026, 10, 24, 23),
      time: CalendarCivilTime(
        doctorTime: DoctorCalendarTime('Europe/Amsterdam'),
      ),
      horizonDays: 1,
      onSelected: (slot) => selected = slot,
    ));
    await tester.pumpAndSettle();

    expect(find.text('02:30 UTC+02:00'), findsOneWidget);
    expect(find.text('02:30 UTC+01:00'), findsOneWidget);
    expect(find.byKey(ValueKey(
      'availability-time-${outsideHorizon.startsAt.toIso8601String()}',
    )), findsNothing);
    final secondButton = find.text('02:30 UTC+01:00');
    await tester.ensureVisible(secondButton);
    await tester.tap(secondButton);
    await tester.pump();
    expect(selected, same(second));
    expect(selected!.startsAt, DateTime.utc(2026, 10, 25, 1, 30));
  });

  testWidgets('Tokyo day grouping uses doctor date and rejects next day', (
    tester,
  ) async {
    final localDay = AvailabilitySlot(
      startsAt: DateTime.utc(2026, 9, 13, 23, 30),
      durationMinutes: 30,
    );
    final nextLocalDay = AvailabilitySlot(
      startsAt: DateTime.utc(2026, 9, 14, 15, 30),
      durationMinutes: 30,
    );
    await tester.pumpWidget(_TestApp(
      slots: [localDay, nextLocalDay],
      from: DateTime.utc(2026, 9, 13, 23),
      time: CalendarCivilTime(
        doctorTime: DoctorCalendarTime('Asia/Tokyo'),
      ),
      horizonDays: 1,
      onSelected: (_) {},
    ));
    await tester.pumpAndSettle();
    expect(find.text('08:30'), findsOneWidget);
    expect(find.byKey(ValueKey(
      'availability-time-${localDay.startsAt.toIso8601String()}',
    )), findsOneWidget);
    expect(find.byKey(ValueKey(
      'availability-time-${nextLocalDay.startsAt.toIso8601String()}',
    )), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.slots,
    required this.from,
    required this.time,
    required this.horizonDays,
    required this.onSelected,
  });

  final List<AvailabilitySlot> slots;
  final DateTime from;
  final CalendarCivilTime time;
  final int horizonDays;
  final ValueChanged<AvailabilitySlot> onSelected;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: LumenoTheme.light,
    home: Scaffold(
      body: SizedBox(
        width: 760,
        height: 640,
        child: AvailabilityDateTimePicker(
          availabilityRepository: _Availability(slots),
          durationMinutes: 30,
          from: from,
          calendarTime: time,
          searchHorizonDays: horizonDays,
          title: 'Choose date & time',
          timesLabel: 'Available times',
          onSelected: onSelected,
          onClose: () {},
        ),
      ),
    ),
  );
}

class _Availability implements AvailabilityRepository {
  const _Availability(this.slots);
  final List<AvailabilitySlot> slots;

  @override
  Future<List<AvailabilitySlot>> findAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    int limit = 4,
  }) async => slots.where((slot) => !slot.startsAt.isBefore(from))
      .take(limit).toList(growable: false);
}
