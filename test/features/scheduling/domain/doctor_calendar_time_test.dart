import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';

void main() {
  test('Moscow doctor civil day is independent of device local time', () {
    final clock = DoctorCalendarTime('Europe/Moscow');
    final instant = DateTime.utc(2026, 1, 1, 23, 30);

    expect(clock.civilDayAt(instant), DateTime.utc(2026, 1, 2));
    final range = clock.dayRangeUtc(DateTime.utc(2026, 1, 2));
    expect(range.startUtc, DateTime.utc(2026, 1, 1, 21));
    expect(range.endUtc, DateTime.utc(2026, 1, 2, 21));
  });

  test('spring forward uses a 23-hour doctor calendar day', () {
    final clock = DoctorCalendarTime('Europe/Amsterdam');
    final range = clock.dayRangeUtc(DateTime.utc(2026, 3, 29));

    expect(range.startUtc, DateTime.utc(2026, 3, 28, 23));
    expect(range.endUtc, DateTime.utc(2026, 3, 29, 22));
    expect(range.endUtc.difference(range.startUtc), const Duration(hours: 23));
  });

  test('fall back uses a 25-hour doctor calendar day', () {
    final clock = DoctorCalendarTime('Europe/Amsterdam');
    final range = clock.dayRangeUtc(DateTime.utc(2026, 10, 25));

    expect(range.startUtc, DateTime.utc(2026, 10, 24, 22));
    expect(range.endUtc, DateTime.utc(2026, 10, 25, 23));
    expect(range.endUtc.difference(range.startUtc), const Duration(hours: 25));
  });

  test('visits close to UTC midnight belong to the correct doctor day', () {
    final clock = DoctorCalendarTime('America/New_York');
    final instant = DateTime.utc(2026, 9, 20, 2, 15);

    expect(clock.civilDayAt(instant), DateTime.utc(2026, 9, 19));
    final range = clock.dayRangeUtc(DateTime.utc(2026, 9, 19));
    expect(instant.isBefore(range.startUtc), isFalse);
    expect(instant.isBefore(range.endUtc), isTrue);
  });

  test('unknown IANA ID is not silently replaced with device zone', () {
    expect(() => DoctorCalendarTime('Invalid/Zone'), throwsException);
  });
}
