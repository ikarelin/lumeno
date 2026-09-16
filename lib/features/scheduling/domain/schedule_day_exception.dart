class ScheduleDayException {
  const ScheduleDayException({
    required this.day,
    required this.isWorkingDay,
  });

  final DateTime day;
  final bool isWorkingDay;
}
