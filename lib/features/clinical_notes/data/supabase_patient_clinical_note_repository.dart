import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/create_patient_clinical_note_input.dart';
import '../domain/patient_clinical_note.dart';
import '../domain/patient_clinical_note_repository.dart';

class SupabasePatientClinicalNoteRepository
    implements PatientClinicalNoteRepository {
  SupabasePatientClinicalNoteRepository(this._client);

  static const _columns =
      'id, patient_id, visit_id, doctor_user_id, body, created_at';

  final SupabaseClient _client;

  @override
  Future<List<PatientClinicalNote>> fetchForPatient({
    required String patientId,
    int limit = 50,
  }) async {
    final user = _requireUser();
    final normalizedPatientId = patientId.trim();
    if (normalizedPatientId.isEmpty) {
      throw ArgumentError.value(patientId, 'patientId', 'Must not be empty');
    }
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }

    final rows = await _client
        .from('patient_clinical_notes')
        .select(_columns)
        .eq('doctor_user_id', user.id)
        .eq('patient_id', normalizedPatientId)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .limit(limit);

    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<List<PatientClinicalNote>> fetchForVisit({
    required String patientId,
    required String visitId,
    int limit = 50,
  }) async {
    final user = _requireUser();
    final normalizedPatientId = patientId.trim();
    final normalizedVisitId = visitId.trim();
    if (normalizedPatientId.isEmpty || normalizedVisitId.isEmpty) {
      throw ArgumentError('Patient and Visit IDs must not be empty.');
    }
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }

    final rows = await _client
        .from('patient_clinical_notes')
        .select(_columns)
        .eq('doctor_user_id', user.id)
        .eq('patient_id', normalizedPatientId)
        .eq('visit_id', normalizedVisitId)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .limit(limit);
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<PatientClinicalNote> create(
    CreatePatientClinicalNoteInput input,
  ) async {
    final user = _requireUser();
    if (!input.isValid) {
      throw ArgumentError('Patient and a nonempty clinical note are required.');
    }

    final row = await _client.from('patient_clinical_notes').insert({
      'doctor_user_id': user.id,
      'patient_id': input.patientId.trim(),
      'visit_id': input.visitId?.trim(),
      'body': input.body.trim(),
    }).select(_columns).single();

    return _fromRow(row);
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('An authenticated doctor is required.');
    }
    return user;
  }

  static PatientClinicalNote _fromRow(Map<String, dynamic> row) {
    return PatientClinicalNote(
      id: row['id'] as String,
      patientId: row['patient_id'] as String,
      visitId: row['visit_id'] as String?,
      authorUserId: row['doctor_user_id'] as String,
      body: row['body'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
    );
  }
}
