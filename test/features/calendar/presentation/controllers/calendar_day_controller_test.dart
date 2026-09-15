import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/calendar/presentation/controllers/calendar_day_controller.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';
import 'package:lumeno/features/visits/presentation/providers/visit_provider.dart';

void main() {
  test('Calendar Day returns Visits in chronological order', () async {
    final repository = _FakeVisitQueryRepository(
      visits: [
        _visit(id: 'visit-3', hour: 15),
        _visit(id: 'visit-1', hour: 9),
        _visit(id: 'visit-2', hour: 11),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        visitQueryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final selectedDate = DateTime(2026, 9, 15);
    final visits = await container.read(
      calendarDayVisitsProvider(selectedDate).future,
    );

    expect(
      visits.map((visit) => visit.id),
      ['visit-1', 'visit-2', 'visit-3'],
    );
    expect(repository.lastFrom, DateTime(2026, 9, 15));
    expect(repository.lastTo, DateTime(2026, 9, 16));
  });
}

Visit _visit({
  required String id,
  required int hour,
}) {
  return Visit(
    id: id,
    patientId: 'patient-$id',
    clinicId: 'clinic-1',
    startsAt: DateTime(2026, 9, 15, hour),
    durationMinutes: 30,
  );
}

class _FakeVisitQueryRepository implements VisitQueryRepository {
  _FakeVisitQueryRepository({required this.visits});

  final List<Visit> visits;

  DateTime? lastFrom;
  DateTime? lastTo;

  @override
  Future<List<Visit>> fetchVisits({
    required DateTime from,
    required DateTime to,
  }) async {
    lastFrom = from;
    lastTo = to;
    return visits;
  }
}
