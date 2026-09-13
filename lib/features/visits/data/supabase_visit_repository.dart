import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/create_visit_input.dart';
import '../domain/update_visit_input.dart';
import '../domain/visit.dart';
import '../domain/visit_repository.dart';

class SupabaseVisitRepository
    implements VisitRepository, VisitQueryRepository, VisitManagementRepository {
  SupabaseVisitRepository(this._client);

  static const _visitColumns =
      'id, patient_id, clinic_id, starts_at, duration_minutes, status, note';

  final SupabaseClient _client;

  @override
  Future<List<Visit>> fetchVisits({
    required DateTime from,
    required DateTime to,
  }) async {
    _ensureAuthenticated();

    if (!from.isBefore(to)) {
      throw ArgumentError('Visit range must have a start before its end.');
    }

    final rows = await _client
        .from('visits')
        .select(_visitColumns)
        .lt('starts_at', to.toUtc().toIso8601String())
        .gt('ends_at', from.toUtc().toIso8601String())
        .order('starts_at');

    return rows.map(_mapVisit).toList(growable: false);
  }

  @override
  Future<Visit> createVisit(CreateVisitInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Patient, clinic, time and duration are required.');
    }

    final user = _ensureAuthenticated();

    final row = await _client
        .from('visits')
        .insert({
          'doctor_user_id': user.id,
          'patient_id': input.patientId.trim(),
          'clinic_id': input.clinicId.trim(),
          'starts_at': input.startsAt.toUtc().toIso8601String(),
          'duration_minutes': input.durationMinutes,
          'note': input.note.trim(),
        })
        .select(_visitColumns)
        .single();

    return _mapVisit(row);
  }

  @override
  Future<Visit> updateVisit(UpdateVisitInput input) async {
    if (!input.isValid) {
      throw ArgumentError('Visit data is invalid.');
    }

    _ensureAuthenticated();

    final row = await _client
        .from('visits')
        .update({
          'patient_id': input.patientId.trim(),
          'clinic_id': input.clinicId.trim(),
          'starts_at': input.startsAt.toUtc().toIso8601String(),
          'duration_minutes': input.durationMinutes,
          'note': input.note.trim(),
        })
        .eq('id', input.visitId.trim())
        .select(_visitColumns)
        .maybeSingle();

    if (row == null) {
      throw StateError('Visit does not exist or is not accessible.');
    }

    return _mapVisit(row);
  }

  @override
  Future<void> cancelVisit({required String visitId}) async {
    _ensureAuthenticated();

    final row = await _client
        .from('visits')
        .update({'status': VisitStatus.cancelled.name})
        .eq('id', visitId.trim())
        .select('id')
        .maybeSingle();

    if (row == null) {
      throw StateError('Visit does not exist or is not accessible.');
    }
  }

  @override
  Future<void> deleteVisit({required String visitId}) async {
    _ensureAuthenticated();

    final row = await _client
        .from('visits')
        .delete()
        .eq('id', visitId.trim())
        .select('id')
        .maybeSingle();

    if (row == null) {
      throw StateError('Visit does not exist or is not accessible.');
    }
  }

  User _ensureAuthenticated() {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('An authenticated user is required for Visits.');
    }

    return user;
  }

  Visit _mapVisit(Map<String, dynamic> row) {
    return Visit(
      id: row['id'] as String,
      patientId: row['patient_id'] as String,
      clinicId: row['clinic_id'] as String,
      startsAt: DateTime.parse(row['starts_at'] as String).toLocal(),
      durationMinutes: row['duration_minutes'] as int,
      status: VisitStatus.values.byName(row['status'] as String),
      note: row['note'] as String? ?? '',
    );
  }
}
