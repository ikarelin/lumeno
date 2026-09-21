import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/calendar/presentation/calendar_date_navigation.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';

void main() {
  test('today comes from doctor zone, not UTC or device civil date', () {
    final nav = CalendarDateNavigation(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Asia/Tokyo')),
    );
    expect(nav.today(DateTime.utc(2026, 9, 13, 23, 30)), DateTime(2026, 9, 14));
    expect(nav.selectDay(DateTime.utc(2026, 9, 14, 19)), DateTime(2026, 9, 14));
  });

  test('day navigation never adds 24h across spring DST transition', () {
    final nav = CalendarDateNavigation(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam')),
    );
    final day = DateTime(2026, 3, 28);
    final next = nav.shift(day, unit: CalendarNavigationUnit.day, direction: 1);
    expect(next, DateTime(2026, 3, 29));
    expect(nav.shift(next, unit: CalendarNavigationUnit.day, direction: 1), DateTime(2026, 3, 30));
    expect(nav.shift(next, unit: CalendarNavigationUnit.day, direction: -1), day);
    final utcRange = nav.calendarTime.visitQueryRange(
      firstCivilDay: next,
      endExclusiveCivilDay: DateTime(2026, 3, 30),
    );
    expect(utcRange.endUtc.difference(utcRange.startUtc), const Duration(hours: 23));
  });

  test('week navigation moves seven calendar labels across autumn DST', () {
    final nav = CalendarDateNavigation(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam')),
    );
    final first = DateTime(2026, 10, 22);
    expect(nav.shift(first, unit: CalendarNavigationUnit.week, direction: 1), DateTime(2026, 10, 29));
    expect(nav.shift(first, unit: CalendarNavigationUnit.week, direction: -1), DateTime(2026, 10, 15));
  });

  test('month navigation clamps end-of-month, keeps date-only components', () {
    const nav = CalendarDateNavigation(CalendarCivilTime());
    expect(nav.shift(DateTime(2026, 1, 31), unit: CalendarNavigationUnit.month, direction: 1), DateTime(2026, 2, 28));
    expect(nav.shift(DateTime(2028, 1, 31), unit: CalendarNavigationUnit.month, direction: 1), DateTime(2028, 2, 29));
    expect(nav.shift(DateTime(2026, 3, 31), unit: CalendarNavigationUnit.month, direction: -1), DateTime(2026, 2, 28));
  });

  test('legacy today follows the device local date and direction validates', () {
    const nav = CalendarDateNavigation(CalendarCivilTime());
    final now = DateTime.utc(2026, 9, 14, 1);
    expect(nav.today(now), DateTime(now.toLocal().year, now.toLocal().month, now.toLocal().day));
    expect(() => nav.shift(DateTime(2026, 9, 14), unit: CalendarNavigationUnit.day, direction: 0), throwsArgumentError);
  });
}
