import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/doctor_profile_provider.dart';
import '../../domain/calendar_civil_time.dart';
import '../../domain/doctor_calendar_time.dart';

/// One rollout switch shared by Calendar and production availability.
/// Keep false until Calendar, Quick Create, dashboard, and slot picker all
/// display the doctor's zone, including their Today and date navigation.
const enableDoctorTimeZoneInProduction = false;

final calendarCivilTimeProvider = FutureProvider<CalendarCivilTime>((ref) async {
  if (!enableDoctorTimeZoneInProduction) {
    return const CalendarCivilTime();
  }

  final profile = await ref.watch(doctorProfileProvider.future);
  final zoneId = profile?.timeZoneId;
  if (zoneId == null || zoneId.trim().isEmpty) {
    throw StateError('Doctor IANA time zone must be configured.');
  }
  return CalendarCivilTime(doctorTime: DoctorCalendarTime(zoneId));
});
