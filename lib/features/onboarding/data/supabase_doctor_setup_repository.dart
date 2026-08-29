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
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          AuthUserMetadata.doctorNameKey: doctorName.trim(),
          AuthUserMetadata.specialtyKey: specialty.trim(),
          AuthUserMetadata.doctorSetupCompletedKey: true,
        },
      ),
    );
  }
}
