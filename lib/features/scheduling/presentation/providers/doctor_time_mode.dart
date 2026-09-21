import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/doctor_profile_provider.dart';
import '../../domain/calendar_civil_time.dart';
import '../../domain/doctor_calendar_time.dart';

/// Single rollout gate shared by Calendar, Quick Create, Dashboard, and
/// profile-derived availability. Doctor-local dates are enabled in every
/// build. Keep the provider overrideable only for isolated legacy tests.
const enableDoctorTimeZoneInProduction = true;

final doctorTimeZoneEnabledProvider = Provider<bool>(
  (ref) => enableDoctorTimeZoneInProduction,
);

/// Scheduling needs an explicitly saved doctor IANA zone; never silently
/// substitute the OS zone when the doctor-zone mode is enabled.
class DoctorTimeZoneNotConfigured extends StateError {
  DoctorTimeZoneNotConfigured()
    : super('Doctor IANA time zone must be configured.');
}

final calendarCivilTimeProvider = FutureProvider<CalendarCivilTime>((ref) async {
  if (!ref.watch(doctorTimeZoneEnabledProvider)) {
    return const CalendarCivilTime();
  }

  final profile = await ref.watch(doctorProfileProvider.future);
  final zoneId = profile?.timeZoneId;
  if (zoneId == null || zoneId.trim().isEmpty) {
    throw DoctorTimeZoneNotConfigured();
  }
  return CalendarCivilTime(doctorTime: DoctorCalendarTime(zoneId));
});
