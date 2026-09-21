import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/visits/domain/visit.dart';
import 'package:lumeno/features/visits/domain/visit_repository.dart';
import 'package:lumeno/features/visits/presentation/providers/patient_visits_provider.dart';
import 'package:lumeno/features/visits/presentation/providers/visit_provider.dart';

void main() {
  final instant = DateTime.utc(2026, 9, 21, 11, 30);

  test('next and last queries use the selected patient and UTC instant', () async {
    final fake = _FakePatientVisitQueryRepository();
    final container = ProviderContainer(overrides: [
      patientVisitQueryRepositoryProvider.overrideWithValue(fake),
      patientVisitNowProvider.overrideWithValue(() => instant),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(patientNextVisitProvider('patient-a').future),
        isNull);
    expect(await container.read(
        patientLastCompletedVisitProvider('patient-a').future), isNull);
    expect(fake.nextPatientId, 'patient-a');
    expect(fake.lastPatientId, 'patient-a');
    expect(fake.nextFrom, instant);
    expect(fake.lastBefore, instant);
    expect(fake.nextFrom!.isUtc, isTrue);
  });

  test('page provider scopes to patient and forwards its offset', () async {
    final fake = _FakePatientVisitQueryRepository();
    final container = ProviderContainer(overrides: [
      patientVisitQueryRepositoryProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    final key = (patientId: 'patient-b', offset: 60);
    expect(await container.read(patientVisitsPageProvider(key).future),
        isEmpty);
    expect(fake.pagePatientId, 'patient-b');
    expect(fake.pageOffset, 60);
    expect(fake.pageSize, 30);
  });

  test('page keys have stable value equality', () {
    const a = (patientId: 'patient-a', offset: 30);
    const b = (patientId: 'patient-a', offset: 30);
    const c = (patientId: 'patient-b', offset: 30);
    expect(a, b);
    expect(a, isNot(c));
  });
}

class _FakePatientVisitQueryRepository implements PatientVisitQueryRepository {
  String? nextPatientId;
  String? lastPatientId;
  String? pagePatientId;
  DateTime? nextFrom;
  DateTime? lastBefore;
  int? pageOffset;
  int? pageSize;

  @override
  Future<Visit?> fetchNextPatientVisit({
    required String patientId,
    required DateTime from,
  }) async {
    nextPatientId = patientId;
    nextFrom = from;
    return null;
  }

  @override
  Future<Visit?> fetchLastCompletedPatientVisit({
    required String patientId,
    required DateTime before,
  }) async {
    lastPatientId = patientId;
    lastBefore = before;
    return null;
  }

  @override
  Future<List<Visit>> fetchPatientVisitsPage({
    required String patientId,
    int offset = 0,
    int pageSize = 30,
  }) async {
    pagePatientId = patientId;
    pageOffset = offset;
    this.pageSize = pageSize;
    return const <Visit>[];
  }
}
