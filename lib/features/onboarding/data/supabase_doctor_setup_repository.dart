import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/domain/auth_user_metadata.dart';
import '../domain/doctor_setup_repository.dart';

class SupabaseDoctorSetupRepository implements DoctorSetupRepository {
  SupabaseDoctorSetupRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> completeDoctorSetup({
    required String doctorName,
    required String specialty,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot complete doctor setup without an authenticated user.',
      );
    }

    final trimmedDoctorName = doctorName.trim();
    final trimmedSpecialty = specialty.trim();

    // doctor_profiles is the canonical source of truth for
    // the doctor's profile data.
    //
    // Save it before marking Doctor Setup as completed in Auth metadata.
    // If profile persistence fails, routing must continue to consider
    // Doctor Setup incomplete.
    await _client.from('doctor_profiles').upsert({
      'user_id': user.id,
      'full_name': trimmedDoctorName,
      'specialty': trimmedSpecialty,
    }, onConflict: 'user_id');

    // Auth metadata is temporarily retained because the current
    // session-routing logic still uses doctor_setup_completed.
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          AuthUserMetadata.doctorNameKey: trimmedDoctorName,
          AuthUserMetadata.specialtyKey: trimmedSpecialty,
          AuthUserMetadata.doctorSetupCompletedKey: true,
        },
      ),
    );
  }
}
