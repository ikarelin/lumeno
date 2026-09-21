import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lumeno/features/calendar/presentation/calendar_time_labels.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('Calendar Day and Visit details use the doctor day and clock', () {
    final labels = CalendarTimeLabels(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Asia/Tokyo')),
    );
    final startsAt = DateTime.utc(2026, 9, 13, 23, 30);
    final endsAt = startsAt.add(const Duration(minutes: 30));

    expect(labels.date(startsAt, 'en'), 'Monday, 14 September');
    expect(labels.clock(startsAt), '08:30');
    expect(labels.range(startsAt, endsAt), '08:30 - 09:00');
    expect(startsAt, DateTime.utc(2026, 9, 13, 23, 30));
  });

  test('Calendar Day distinguishes the two repeated doctor clock times', () {
    final labels = CalendarTimeLabels(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam')),
    );
    final first = DateTime.utc(2026, 10, 25, 0, 30);
    final second = DateTime.utc(2026, 10, 25, 1, 30);

    expect(labels.clock(first), '02:30 UTC+02:00');
    expect(labels.clock(second), '02:30 UTC+01:00');
  });

  test('staged fallback retains the previous device-local label', () {
    const labels = CalendarTimeLabels(CalendarCivilTime());
    final instant = DateTime.utc(2026, 9, 14, 9);
    final local = instant.toLocal();
    final clock = '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';

    expect(labels.clock(instant), clock);
  });
}
