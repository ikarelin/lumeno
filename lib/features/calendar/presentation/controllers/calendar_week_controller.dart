import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../scheduling/presentation/providers/availability_provider.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/presentation/providers/visit_provider.dart';

final calendarWeekDataProvider =
    FutureProvider.autoDispose.family<CalendarWeekData, DateTime>(
  (ref, selectedDate) async {
    final visitRepository = ref.watch(visitQueryRepositoryProvider);
    final availabilityRepository = ref.watch(availabilityDayRepositoryProvider);
    final monday = _startOfWeek(selectedDate);
    final nextMonday = monday.add(const Duration(days: 7));

    final visitsFuture = visitRepository.fetchVisits(
      from: monday,
      to: nextMonday,
    );
    final availabilityFuture = Future.wait(
      List.generate(
        7,
        (index) => availabilityRepository.findDayAvailability(
          day: monday.add(Duration(days: index)),
        ),
      ),
    );

    final visits = await visitsFuture;
    final availabilityDays = await availabilityFuture;
    final scheduledVisits = visits
        .where((visit) => visit.status == VisitStatus.scheduled)
        .toList(growable: false);

    final days = List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final availability = availabilityDays[index];
      final visitCount = scheduledVisits.where((visit) {
        return _isSameLocalDay(visit.startsAt, date);
      }).length;

      return CalendarWeekDayData(
        date: date,
        visitCount: visitCount,
        availableWindowCount: availability.availableIntervals.length,
        isWorkingDay: availability.isWorkingDay,
      );
    });

    return CalendarWeekData(
      monday: monday,
      days: days,
      visitCount: days.fold(0, (total, day) => total + day.visitCount),
      availableWindowCount: days.fold(
        0,
        (total, day) => total + day.availableWindowCount,
      ),
      workingDayCount: days.where((day) => day.isWorkingDay).length,
    );
  },
);

class CalendarWeekData {
  CalendarWeekData({
    required this.monday,
    required List<CalendarWeekDayData> days,
    required this.visitCount,
    required this.availableWindowCount,
    required this.workingDayCount,
  }) : days = List<CalendarWeekDayData>.unmodifiable(days);

  final DateTime monday;
  final List<CalendarWeekDayData> days;
  final int visitCount;
  final int availableWindowCount;
  final int workingDayCount;
}

class CalendarWeekDayData {
  const CalendarWeekDayData({
    required this.date,
    required this.visitCount,
    required this.availableWindowCount,
    required this.isWorkingDay,
  });

  final DateTime date;
  final int visitCount;
  final int availableWindowCount;
  final bool isWorkingDay;
}

DateTime _startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

bool _isSameLocalDay(DateTime left, DateTime right) {
  final local = left.toLocal();
  return local.year == right.year &&
      local.month == right.month &&
      local.day == right.day;
}
