import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit.freezed.dart';

@freezed
abstract class Visit with _$Visit {
  const Visit._();

  const factory Visit({
    required String id,
    required String patientId,
    required String clinicId,
    required DateTime startsAt,
    required int durationMinutes,
    @Default(VisitStatus.scheduled) VisitStatus status,
    @Default('') String note,
  }) = _Visit;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));

  bool get occupiesAvailability => status == VisitStatus.scheduled;
}

enum VisitStatus {
  scheduled,
  cancelled,
  completed,
}
