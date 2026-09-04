import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/clinic.dart';
import '../domain/clinic_membership.dart';
import '../domain/clinic_membership_repository.dart';
import '../domain/clinic_repository.dart';
import '../domain/create_clinic_input.dart';

class SupabaseClinicRepository
    implements ClinicRepository, ClinicMembershipRepository {
  SupabaseClinicRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Clinic>> fetchClinics() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return const <Clinic>[];
    }

    final rows = await _client
        .from('clinics')
        .select('id, name, address')
        .order('name');

    return rows.map(_mapClinic).toList(growable: false);
  }

  @override
  Future<List<ClinicMembership>> fetchActiveClinicMemberships() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return const <ClinicMembership>[];
    }

    final rows = await _client
        .from('doctor_clinics')
        .select('''
          is_default,
          clinic:clinics!inner(
            id,
            name,
            address
          )
          ''')
        .eq('doctor_user_id', user.id)
        .isFilter('archived_at', null);

    final memberships = rows.map((row) {
      final clinicRow = row['clinic'] as Map<String, dynamic>;

      return ClinicMembership(
        clinic: _mapClinic(clinicRow),
        isDefault: row['is_default'] as bool? ?? false,
      );
    }).toList();

    memberships.sort((left, right) {
      if (left.isDefault != right.isDefault) {
        return left.isDefault ? -1 : 1;
      }

      final byName = left.clinic.name.toLowerCase().compareTo(
        right.clinic.name.toLowerCase(),
      );

      if (byName != 0) {
        return byName;
      }

      return left.clinic.id.compareTo(right.clinic.id);
    });

    return List<ClinicMembership>.unmodifiable(memberships);
  }

  @override
  Future<Clinic> createClinic(CreateClinicInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Clinic name is required.');
    }

    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('Cannot create a clinic without an authenticated user.');
    }

    final address = input.address.trim();

    final row = await _client
        .from('clinics')
        .insert({
          'name': input.name.trim(),
          'address': address.isEmpty ? null : address,
          'created_by_user_id': user.id,
        })
        .select('id, name, address')
        .single();

    return _mapClinic(row);
  }

  @override
  Future<void> setDefaultClinic({required String clinicId}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot set a default clinic without an authenticated user.',
      );
    }

    final normalizedClinicId = clinicId.trim();

    if (normalizedClinicId.isEmpty) {
      throw ArgumentError('Clinic id is required.');
    }

    await _client.rpc(
      'set_default_clinic',
      params: {'p_clinic_id': normalizedClinicId},
    );
  }

  Clinic _mapClinic(Map<String, dynamic> row) {
    return Clinic(
      id: row['id'] as String,
      name: row['name'] as String,
      address: row['address'] as String? ?? '',
    );
  }
}
