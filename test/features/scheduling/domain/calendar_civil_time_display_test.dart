import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';

void main() {
  test('doctor zone changes only the display, never the absolute instant', () {
    final presentation = CalendarCivilTime(
      doctorTime: DoctorCalendarTime('Asia/Tokyo'),
    );
    final instant = DateTime.utc(2026, 9, 13, 23, 30);
    expect(presentation.civilDayAt(instant), DateTime(2026, 9, 14));
    expect(presentation.clockLabel(instant), '08:30');
    expect(presentation.displayInstant(instant).toUtc(), instant);
  });

  test('both repeated Amsterdam 02:30 slots have distinct visible labels', () {
    final presentation = CalendarCivilTime(
      doctorTime: DoctorCalendarTime('Europe/Amsterdam'),
    );
    final first = DateTime.utc(2026, 10, 25, 0, 30);
    final second = DateTime.utc(2026, 10, 25, 1, 30);
    expect(presentation.clockLabel(first), '02:30 UTC+02:00');
    expect(presentation.clockLabel(second), '02:30 UTC+01:00');
    expect(presentation.displayInstant(first).toUtc(), first);
    expect(presentation.displayInstant(second).toUtc(), second);
  });

  test('non-repeated doctor clock does not show an unnecessary offset', () {
    final presentation = CalendarCivilTime(
      doctorTime: DoctorCalendarTime('Europe/Amsterdam'),
    );
    expect(presentation.clockLabel(DateTime.utc(2026, 10, 25, 10)), '11:00');
  });

  test('fallback clock retains the previous device-zone formatting', () {
    const presentation = CalendarCivilTime();
    final instant = DateTime.utc(2026, 9, 14, 9);
    final deviceLocal = instant.toLocal();
    expect(
      presentation.clockLabel(instant),
      '${deviceLocal.hour.toString().padLeft(2, '0')}:'
      '${deviceLocal.minute.toString().padLeft(2, '0')}',
    );
  });
}
