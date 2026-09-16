import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/schedule_day_exception.dart';
import '../domain/schedule_day_exception_repository.dart';

class SupabaseScheduleDayExceptionRepository
    implements ScheduleDayExceptionRepository {
  SupabaseScheduleDayExceptionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<ScheduleDayException?> fetchForDay({
    required DateTime day,
  }) async {
    final row = await _client
        .from('schedule_day_exceptions')
        .select('day, is_working_day')
        .eq('day', _formatDay(day))
        .maybeSingle();

    return row == null ? null : _mapException(row);
  }

  @override
  Future<List<ScheduleDayException>> fetchForRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _client
        .from('schedule_day_exceptions')
        .select('day, is_working_day')
        .gte('day', _formatDay(from))
        .lt('day', _formatDay(to))
        .order('day');

    return rows.map(_mapException).toList(growable: false);
  }

  @override
  Future<ScheduleDayException> setWorkingDay({
    required DateTime day,
    required bool isWorkingDay,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError(
        'Cannot change a schedule day without an authenticated user.',
      );
    }

    final row = await _client
        .from('schedule_day_exceptions')
        .upsert({
          'doctor_user_id': user.id,
          'day': _formatDay(day),
          'is_working_day': isWorkingDay,
        }, onConflict: 'doctor_user_id,day')
        .select('day, is_working_day')
        .single();

    return _mapException(row);
  }

  ScheduleDayException _mapException(Map<String, dynamic> row) {
    return ScheduleDayException(
      day: _parseDay(row['day'] as String),
      isWorkingDay: row['is_working_day'] as bool,
    );
  }

  String _formatDay(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime _parseDay(String value) {
    final parts = value.split('-');

    if (parts.length != 3) {
      throw StateError('Invalid schedule exception day: $value');
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) {
      throw StateError('Invalid schedule exception day: $value');
    }

    return DateTime(year, month, day);
  }
}
