import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lumeno/features/quick_create/presentation/quick_create_time_labels.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('selected date and suggested slot use the doctor day, not UTC day', () {
    final labels = QuickCreateTimeLabels(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Asia/Tokyo')),
    );
    final instant = DateTime.utc(2026, 9, 13, 23, 30);

    expect(labels.selectedDate(instant, 'en'), 'Mon, 14 Sep');
    expect(labels.slotChip(instant, 'en'), 'Mon 08:30');
    expect(labels.selectedRange(instant, 30), '08:30 - 09:00');
    // Formatting is read-only; the controller still selects this exact instant.
    expect(instant, DateTime.utc(2026, 9, 13, 23, 30));
  });

  test('Quick Create distinguishes the repeated DST hour on both surfaces', () {
    final labels = QuickCreateTimeLabels(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam')),
    );
    final first = DateTime.utc(2026, 10, 25, 0, 30);
    final second = DateTime.utc(2026, 10, 25, 1, 30);

    expect(labels.slotChip(first, 'en'), 'Sun 02:30 UTC+02:00');
    expect(labels.slotChip(second, 'en'), 'Sun 02:30 UTC+01:00');
    expect(labels.selectedRange(first, 30), '02:30 UTC+02:00 - 02:00 UTC+01:00');
    expect(labels.selectedRange(second, 30), '02:30 UTC+01:00 - 03:00');
  });

  test('legacy mode still formats the device-local selected instant', () {
    const labels = QuickCreateTimeLabels(CalendarCivilTime());
    final instant = DateTime.utc(2026, 9, 14, 9);
    final deviceTime = instant.toLocal();
    final clock = '${deviceTime.hour.toString().padLeft(2, '0')}:'
        '${deviceTime.minute.toString().padLeft(2, '0')}';

    expect(labels.selectedRange(instant, 30).startsWith('$clock - '), isTrue);
    expect(labels.selectedDate(instant, 'en'), isNotEmpty);
  });
}
