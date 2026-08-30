import 'package:supabase_flutter/supabase_flutter.dart';

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

    final row = await _client
        .from('doctor_profiles')
        .select('user_id, full_name, specialty')
        .eq('user_id', user.id)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return _mapProfile(row);
  }

  @override
  Future<DoctorProfile> saveCurrentProfile({
    required String fullName,
    required String specialty,
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
        }, onConflict: 'user_id')
        .select('user_id, full_name, specialty')
        .single();

    return _mapProfile(row);
  }

  DoctorProfile _mapProfile(Map<String, dynamic> row) {
    return DoctorProfile(
      userId: row['user_id'] as String,
      fullName: row['full_name'] as String,
      specialty: row['specialty'] as String,
    );
  }
}
