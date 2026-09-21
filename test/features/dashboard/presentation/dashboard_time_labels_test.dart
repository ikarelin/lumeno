import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lumeno/features/dashboard/presentation/dashboard_time_labels.dart';
import 'package:lumeno/features/scheduling/domain/calendar_civil_time.dart';
import 'package:lumeno/features/scheduling/domain/doctor_calendar_time.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('Dashboard dates, clocks and greeting use the doctor civil zone', () {
    final labels = DashboardTimeLabels(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Asia/Tokyo')),
    );
    final instant = DateTime.utc(2026, 9, 13, 23, 30);

    expect(labels.date(instant, 'en'), 'Mon, 14 Sep');
    expect(labels.clock(instant), '08:30');
    expect(labels.headerDate(instant, 'en'), 'Monday, 14 September');
    expect(labels.greetingKey(instant), 'dashboard.greetingMorning');
    expect(labels.calendarTime.civilDayAt(instant).day, 14);
    expect(instant, DateTime.utc(2026, 9, 13, 23, 30));
  });

  test('Dashboard preserves two real instants in the DST repeated hour', () {
    final labels = DashboardTimeLabels(
      CalendarCivilTime(doctorTime: DoctorCalendarTime('Europe/Amsterdam')),
    );
    final first = DateTime.utc(2026, 10, 25, 0, 30);
    final second = DateTime.utc(2026, 10, 25, 1, 30);

    expect(labels.clock(first), '02:30 UTC+02:00');
    expect(labels.clock(second), '02:30 UTC+01:00');
    expect(first.isBefore(second), isTrue);
  });

  test('Legacy label uses the device local hour without changing instant', () {
    const labels = DashboardTimeLabels(CalendarCivilTime());
    final instant = DateTime.utc(2026, 9, 14, 9);
    final expected = instant.toLocal();
    expect(
      labels.clock(instant),
      '${expected.hour.toString().padLeft(2, '0')}:'
      '${expected.minute.toString().padLeft(2, '0')}',
    );
    expect(instant, DateTime.utc(2026, 9, 14, 9));
  });
}
