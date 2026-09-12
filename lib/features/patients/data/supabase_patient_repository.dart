import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/create_patient_input.dart';
import '../domain/patient.dart';
import '../domain/patient_contact_channel.dart';
import '../domain/patient_management_repository.dart';
import '../domain/patient_repository.dart';
import '../domain/update_patient_input.dart';

class SupabasePatientRepository
    implements PatientRepository, PatientManagementRepository {
  SupabasePatientRepository(this._client);

  static const _patientColumns =
      'id, name, phone, email, telegram, whatsapp_available, '
      'preferred_contact_channels, note';
  static const _searchLimit = 20;

  final SupabaseClient _client;

  @override
  Future<List<Patient>> fetchPatients() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return const <Patient>[];
    }

    final rows = await _client
        .from('patients')
        .select(_patientColumns)
        .eq('doctor_user_id', user.id)
        .isFilter('archived_at', null)
        .order('name');

    return rows.map(_mapPatient).toList(growable: false);
  }

  @override
  Future<Patient?> fetchPatientById({required String patientId}) async {
    final normalizedPatientId = patientId.trim();

    if (normalizedPatientId.isEmpty) {
      throw ArgumentError('Patient id is required.');
    }

    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final row = await _client
        .from('patients')
        .select(_patientColumns)
        .eq('id', normalizedPatientId)
        .eq('doctor_user_id', user.id)
        .isFilter('archived_at', null)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return _mapPatient(row);
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return const <Patient>[];
    }

    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return const <Patient>[];
    }

    final nameRows = await _client
        .from('patients')
        .select(_patientColumns)
        .eq('doctor_user_id', user.id)
        .isFilter('archived_at', null)
        .ilike('name', '%$normalizedQuery%')
        .order('name')
        .limit(_searchLimit);

    final phoneRows = await _client
        .from('patients')
        .select(_patientColumns)
        .eq('doctor_user_id', user.id)
        .isFilter('archived_at', null)
        .ilike('phone', '%$normalizedQuery%')
        .order('name')
        .limit(_searchLimit);

    final patientsById = <String, Patient>{};

    for (final row in nameRows) {
      final patient = _mapPatient(row);
      patientsById[patient.id] = patient;
    }

    for (final row in phoneRows) {
      final patient = _mapPatient(row);
      patientsById[patient.id] = patient;
    }

    final patients = patientsById.values.toList()
      ..sort((left, right) {
        final byName = left.name.toLowerCase().compareTo(
          right.name.toLowerCase(),
        );

        if (byName != 0) {
          return byName;
        }

        return left.id.compareTo(right.id);
      });

    return List<Patient>.unmodifiable(patients.take(_searchLimit));
  }

  @override
  Future<Patient> createPatient(CreatePatientInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Patient name and phone are required.');
    }

    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot create a patient without an authenticated user.',
      );
    }

    final row = await _client
        .from('patients')
        .insert({
          'doctor_user_id': user.id,
          'name': input.name.trim(),
          'phone': input.phone.trim(),
          'note': input.note.trim(),
        })
        .select(_patientColumns)
        .single();

    return _mapPatient(row);
  }

  @override
  Future<Patient> updatePatient(UpdatePatientInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Patient update data is invalid.');
    }

    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot update a patient without an authenticated user.',
      );
    }

    final row = await _client
        .from('patients')
        .update({
          'name': input.name.trim(),
          'phone': input.phone.trim(),
          'email': input.email.trim(),
          'telegram': input.telegram.trim(),
          'whatsapp_available': input.whatsappAvailable,
          'preferred_contact_channels': _preferredContactChannelsForStorage(
            input.preferredContactChannels,
          ),
          'note': input.note.trim(),
        })
        .eq('id', input.patientId.trim())
        .eq('doctor_user_id', user.id)
        .isFilter('archived_at', null)
        .select(_patientColumns)
        .maybeSingle();

    if (row == null) {
      throw StateError(
        'Cannot update a patient that does not exist or is archived.',
      );
    }

    return _mapPatient(row);
  }

  @override
  Future<void> archivePatient({required String patientId}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot archive a patient without an authenticated user.',
      );
    }

    final normalizedPatientId = patientId.trim();

    if (normalizedPatientId.isEmpty) {
      throw ArgumentError('Patient id is required.');
    }

    final row = await _client
        .from('patients')
        .update({'archived_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', normalizedPatientId)
        .eq('doctor_user_id', user.id)
        .isFilter('archived_at', null)
        .select('id')
        .maybeSingle();

    if (row == null) {
      throw StateError(
        'Cannot archive a patient that does not exist or is already archived.',
      );
    }
  }

  Patient _mapPatient(Map<String, dynamic> row) {
    return Patient(
      id: row['id'] as String,
      name: row['name'] as String,
      phone: row['phone'] as String? ?? '',
      email: row['email'] as String? ?? '',
      telegram: row['telegram'] as String? ?? '',
      whatsappAvailable: row['whatsapp_available'] as bool? ?? false,
      preferredContactChannels: _mapPreferredContactChannels(
        row['preferred_contact_channels'],
      ),
      note: row['note'] as String? ?? '',
    );
  }

  Set<PatientContactChannel> _mapPreferredContactChannels(dynamic rawChannels) {
    if (rawChannels is! List) {
      return const <PatientContactChannel>{};
    }

    final channels = <PatientContactChannel>{};

    for (final rawChannel in rawChannels) {
      if (rawChannel is! String) {
        continue;
      }

      final channel = PatientContactChannel.tryParse(rawChannel);

      if (channel != null) {
        channels.add(channel);
      }
    }

    return Set<PatientContactChannel>.unmodifiable(channels);
  }

  List<String> _preferredContactChannelsForStorage(
    Set<PatientContactChannel> channels,
  ) {
    return PatientContactChannel.values
        .where(channels.contains)
        .map((channel) => channel.storageValue)
        .toList(growable: false);
  }
}
