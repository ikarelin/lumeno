import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';

void main() {
  group('CalendarCivilTime', () {
    test('date labels keep their Y/M/D regardless of UTC or device zone', () {
      final calendar = CalendarCivilTime(doctorTime: DoctorCalendarTime('Asia/Tokyo'));
      expect(calendar.dayLabel(DateTime.utc(2026, 9, 14, 23)), DateTime(2026, 9, 14));
    });

    test('Tokyo day query includes UTC visits from the previous day', () {
      final calendar = CalendarCivilTime(doctorTime: DoctorCalendarTime('Asia/Tokyo'));
      final day = DateTime(2026, 9, 14);
      final range = calendar.visitQueryRange(
        firstCivilDay: day,
        endExclusiveCivilDay: DateTime(2026, 9, 15),
      );
      expect(range.startUtc, DateTime.utc(2026, 9, 13, 15));
      expect(range.endUtc, DateTime.utc(2026, 9, 14, 15));
      expect(calendar.isOnCivilDay(DateTime.utc(2026, 9, 13, 23, 30), day), isTrue);
      expect(calendar.isOnCivilDay(DateTime.utc(2026, 9, 14, 16), day), isFalse);
    });

    test('Amsterdam spring-forward Sunday has 23 real hours', () {
      final calendar = CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam'));
      final range = calendar.visitQueryRange(
        firstCivilDay: DateTime(2026, 3, 29),
        endExclusiveCivilDay: DateTime(2026, 3, 30),
      );
      expect(range.startUtc, DateTime.utc(2026, 3, 28, 23));
      expect(range.endUtc, DateTime.utc(2026, 3, 29, 22));
      expect(range.endUtc.difference(range.startUtc), const Duration(hours: 23));
    });

    test('Amsterdam autumn Sunday has 25 real hours and both 02:30 visits', () {
      final calendar = CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam'));
      final day = DateTime(2026, 10, 25);
      final range = calendar.visitQueryRange(
        firstCivilDay: day,
        endExclusiveCivilDay: DateTime(2026, 10, 26),
      );
      expect(range.startUtc, DateTime.utc(2026, 10, 24, 22));
      expect(range.endUtc, DateTime.utc(2026, 10, 25, 23));
      expect(range.endUtc.difference(range.startUtc), const Duration(hours: 25));
      expect(calendar.isOnCivilDay(DateTime.utc(2026, 10, 25, 0, 30), day), isTrue);
      expect(calendar.isOnCivilDay(DateTime.utc(2026, 10, 25, 1, 30), day), isTrue);
    });

    test('civil month counts cross the device-zone midnight correctly', () {
      final calendar = CalendarCivilTime(doctorTime: DoctorCalendarTime('America/New_York'));
      final april = DateTime(2026, 4, 1);
      expect(calendar.isOnCivilDay(DateTime.utc(2026, 4, 1, 2), april), isFalse);
      expect(calendar.isOnCivilDay(DateTime.utc(2026, 4, 1, 5), april), isTrue);
    });

    test('rejects an empty civil query range', () {
      final calendar = CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam'));
      expect(
        () => calendar.visitQueryRange(
          firstCivilDay: DateTime(2026, 9, 14),
          endExclusiveCivilDay: DateTime(2026, 9, 14),
        ),
        throwsArgumentError,
      );
    });

    test('device-zone fallback preserves the existing local query dates', () {
      const calendar = CalendarCivilTime();
      final day = DateTime(2026, 9, 14);
      final range = calendar.visitQueryRange(
        firstCivilDay: day,
        endExclusiveCivilDay: DateTime(2026, 9, 15),
      );
      expect(range.startUtc, DateTime(2026, 9, 14));
      expect(range.endUtc, DateTime(2026, 9, 15));
      expect(calendar.civilDayAt(DateTime(2026, 9, 14, 13)), day);
    });
  });
}
