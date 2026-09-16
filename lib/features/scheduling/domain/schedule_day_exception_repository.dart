import 'schedule_day_exception.dart';

abstract interface class ScheduleDayExceptionRepository {
  Future<ScheduleDayException?> fetchForDay({
    required DateTime day,
  });

  Future<List<ScheduleDayException>> fetchForRange({
    required DateTime from,
    required DateTime to,
  });

  Future<ScheduleDayException> setWorkingDay({
    required DateTime day,
    required bool isWorkingDay,
  });
}
