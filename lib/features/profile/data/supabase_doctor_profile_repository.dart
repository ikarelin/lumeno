import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/domain/auth_user_metadata.dart';
import '../domain/doctor_profile.dart';
import '../domain/doctor_profile_repository.dart';

class SupabaseDoctorProfileRepository implements DoctorProfileRepository {
  SupabaseDoctorProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<DoctorProfile?> fetchCurrentProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    Map<String, dynamic>? row;

    try {
      row = await _client
          .from('doctor_profiles')
          .select(
            'user_id, full_name, specialty, default_duration_minutes, '
            'working_days, workday_start, workday_end, break_start, break_end',
          )
          .eq('user_id', user.id)
          .maybeSingle();
    } on PostgrestException {
      // Keep existing accounts readable until the scheduling migration is
      // applied to the connected Supabase project.
      row = await _client
          .from('doctor_profiles')
          .select('user_id, full_name, specialty')
          .eq('user_id', user.id)
          .maybeSingle();
    }

    if (row == null) {
      final metadata = user.userMetadata;
      final fullName = metadata?[AuthUserMetadata.doctorNameKey] as String?;
      final specialty = metadata?[AuthUserMetadata.specialtyKey] as String?;

      if (fullName == null || specialty == null) {
        return null;
      }

      return DoctorProfile(
        userId: user.id,
        fullName: fullName,
        specialty: specialty,
      );
    }

    return _mapProfile(row);
  }

  @override
  Future<DoctorProfile> saveCurrentProfile({
    required String fullName,
    required String specialty,
    required int defaultDurationMinutes,
    required List<int> workingDays,
    required String workdayStart,
    required String workdayEnd,
    required String? breakStart,
    required String? breakEnd,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot save doctor profile without an authenticated user.',
      );
    }

    final row = await _client
        .from('doctor_profiles')
        .upsert({
          'user_id': user.id,
          'full_name': fullName.trim(),
          'specialty': specialty.trim(),
          'default_duration_minutes': defaultDurationMinutes,
          'working_days': workingDays,
          'workday_start': workdayStart,
          'workday_end': workdayEnd,
          'break_start': breakStart,
          'break_end': breakEnd,
        }, onConflict: 'user_id')
        .select(
          'user_id, full_name, specialty, default_duration_minutes, '
          'working_days, workday_start, workday_end, break_start, break_end',
        )
        .single();

    return _mapProfile(row);
  }

  DoctorProfile _mapProfile(Map<String, dynamic> row) {
    return DoctorProfile(
      userId: row['user_id'] as String,
      fullName: row['full_name'] as String,
      specialty: row['specialty'] as String,
      defaultDurationMinutes:
          (row['default_duration_minutes'] as num?)?.toInt() ?? 30,
      workingDays: _readWorkingDays(row['working_days']),
      workdayStart: row['workday_start'] as String? ?? '09:00',
      workdayEnd: row['workday_end'] as String? ?? '18:00',
      breakStart: row['break_start'] as String? ?? '13:00',
      breakEnd: row['break_end'] as String? ?? '14:00',
    );
  }

  List<int> _readWorkingDays(Object? value) {
    if (value is! List) {
      return const [1, 2, 3, 4, 5];
    }

    return value.whereType<num>().map((day) => day.toInt()).toList();
  }
}
