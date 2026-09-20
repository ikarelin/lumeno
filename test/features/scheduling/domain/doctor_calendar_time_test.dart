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

  test('civil date range uses zone midnights, not 24-hour additions', () {
    final clock = DoctorCalendarTime('Europe/Amsterdam');
    final range = clock.civilRangeUtc(
      firstCivilDay: DateTime.utc(2026, 3, 28),
      endExclusiveCivilDay: DateTime.utc(2026, 3, 31),
    );
    expect(range.startUtc, DateTime.utc(2026, 3, 27, 23));
    expect(range.endUtc, DateTime.utc(2026, 3, 30, 22));
    expect(range.endUtc.difference(range.startUtc), const Duration(hours: 71));
  });

  test('civil date range requires a later exclusive end date', () {
    final clock = DoctorCalendarTime('Europe/Moscow');
    expect(
      () => clock.civilRangeUtc(
        firstCivilDay: DateTime.utc(2026, 1, 2),
        endExclusiveCivilDay: DateTime.utc(2026, 1, 2),
      ),
      throwsArgumentError,
    );
  });

  test('explicit doctor wall-clock time is independent of device zone', () {
    final clock = DoctorCalendarTime('Europe/Moscow');
    expect(
      clock.instantAtCivilTimeUtc(DateTime.utc(2026, 1, 2), hour: 9),
      DateTime.utc(2026, 1, 2, 6),
    );
  });

  test('wall-clock work hours use different UTC offsets across DST', () {
    final clock = DoctorCalendarTime('Europe/Amsterdam');
    expect(
      clock.instantAtCivilTimeUtc(DateTime.utc(2026, 3, 28), hour: 9),
      DateTime.utc(2026, 3, 28, 8),
    );
    expect(
      clock.instantAtCivilTimeUtc(DateTime.utc(2026, 3, 29), hour: 9),
      DateTime.utc(2026, 3, 29, 7),
    );
    expect(
      clock.instantAtCivilTimeUtc(DateTime.utc(2026, 10, 24), hour: 9),
      DateTime.utc(2026, 10, 24, 7),
    );
    expect(
      clock.instantAtCivilTimeUtc(DateTime.utc(2026, 10, 25), hour: 9),
      DateTime.utc(2026, 10, 25, 8),
    );
  });

  test('nonexistent spring-forward time is rejected', () {
    final clock = DoctorCalendarTime('Europe/Amsterdam');
    expect(
      () => clock.instantAtCivilTimeUtc(
        DateTime.utc(2026, 3, 29), hour: 2, minute: 30,
      ),
      throwsStateError,
    );
  });

  test('repeated fall-back time is rejected as ambiguous', () {
    final clock = DoctorCalendarTime('Europe/Amsterdam');
    expect(
      () => clock.instantAtCivilTimeUtc(
        DateTime.utc(2026, 10, 25), hour: 2, minute: 30,
      ),
      throwsStateError,
    );
  });

  test('half-hour DST gap and overlap are not silently normalized', () {
    final clock = DoctorCalendarTime('Australia/Lord_Howe');
    expect(
      () => clock.instantAtCivilTimeUtc(
        DateTime.utc(2026, 10, 4), hour: 2, minute: 15,
      ),
      throwsStateError,
    );
    expect(
      () => clock.instantAtCivilTimeUtc(
        DateTime.utc(2026, 4, 5), hour: 1, minute: 45,
      ),
      throwsStateError,
    );
  });
}
