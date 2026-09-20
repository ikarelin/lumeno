import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scheduling/presentation/providers/availability_provider.dart';
import '../../../scheduling/presentation/providers/doctor_time_mode.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/presentation/providers/visit_provider.dart';

final calendarMonthDataProvider = FutureProvider.autoDispose
    .family<CalendarMonthData, DateTime>((ref, selectedDate) async {
      final calendarTime = await ref.watch(calendarCivilTimeProvider.future);
      final visitRepository = ref.watch(visitQueryRepositoryProvider);
      final availabilityRepository = ref.watch(
        availabilityRangeRepositoryProvider,
      );
      final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
      final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
      final daysInMonth = DateTime(firstDay.year, firstDay.month + 1, 0).day;

      final queryRange = calendarTime.visitQueryRange(
        firstCivilDay: firstDay,
        endExclusiveCivilDay: nextMonth,
      );
      final visitsFuture = visitRepository.fetchVisits(
        from: queryRange.startUtc,
        to: queryRange.endUtc,
      );
      final availabilityFuture = availabilityRepository.findRangeAvailability(
        from: firstDay,
        to: nextMonth,
      );

      final visits = await visitsFuture;
      final availabilityDays = await availabilityFuture;
      if (availabilityDays.length != daysInMonth) {
        throw StateError('Month availability must contain one entry per day.');
      }
      final scheduledVisits = visits
          .where((visit) => visit.status == VisitStatus.scheduled)
          .toList(growable: false);

      final days = List.generate(daysInMonth, (index) {
        final date = DateTime(firstDay.year, firstDay.month, index + 1);
        final availability = availabilityDays[index];
        final visitCount = scheduledVisits.where((visit) {
          return calendarTime.isOnCivilDay(visit.startsAt, date);
        }).length;

        return CalendarMonthDayData(
          date: date,
          visitCount: visitCount,
          isWorkingDay: availability.isWorkingDay,
        );
      });

      return CalendarMonthData(
        firstDay: firstDay,
        days: days,
        visitCount: days.fold(0, (total, day) => total + day.visitCount),
        busyDayCount: days.where((day) => day.visitCount > 0).length,
        workingDayCount: days.where((day) => day.isWorkingDay).length,
      );
    });

class CalendarMonthData {
  CalendarMonthData({
    required this.firstDay,
    required List<CalendarMonthDayData> days,
    required this.visitCount,
    required this.busyDayCount,
    required this.workingDayCount,
  }) : days = List<CalendarMonthDayData>.unmodifiable(days);

  final DateTime firstDay;
  final List<CalendarMonthDayData> days;
  final int visitCount;
  final int busyDayCount;
  final int workingDayCount;
}

class CalendarMonthDayData {
  const CalendarMonthDayData({
    required this.date,
    required this.visitCount,
    required this.isWorkingDay,
  });

  final DateTime date;
  final int visitCount;
  final bool isWorkingDay;
}
