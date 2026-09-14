import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/features/scheduling/domain/availability_engine.dart';
import 'package:lumeno/features/scheduling/domain/availability_interval.dart';
import 'package:lumeno/features/visits/domain/visit.dart';

void main() {
  const engine = AvailabilityEngine();

  group('AvailabilityEngine.findAvailableIntervals', () {
    test('returns a future working interval when nothing is busy', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 18)],
        busyIntervals: const [],
        requestedDurationMinutes: 30,
        notBefore: DateTime(2026, 9, 14, 8),
      );

      expect(result, hasLength(1));
      expect(result.single.startsAt, DateTime(2026, 9, 14, 9));
      expect(result.single.endsAt, DateTime(2026, 9, 14, 18));
    });

    test('subtracts a break and scheduled visit from the working day', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 18)],
        busyIntervals: [
          _interval(13, 14),
          _interval(10, 10, endMinute: 30),
        ],
        requestedDurationMinutes: 30,
        notBefore: DateTime(2026, 9, 14, 8),
      );

      expect(result, hasLength(3));
      _expectInterval(result[0], startHour: 9, endHour: 10);
      _expectInterval(
        result[1],
        startHour: 10,
        startMinute: 30,
        endHour: 13,
      );
      _expectInterval(result[2], startHour: 14, endHour: 18);
    });

    test('clips today availability at now instead of exposing past time', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 18)],
        busyIntervals: const [],
        requestedDurationMinutes: 30,
        notBefore: DateTime(2026, 9, 14, 10, 20),
      );

      expect(result, hasLength(1));
      expect(result.single.startsAt, DateTime(2026, 9, 14, 10, 20));
      expect(result.single.endsAt, DateTime(2026, 9, 14, 18));
    });

    test('returns no availability when the whole working day is in the past', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 18)],
        busyIntervals: const [],
        requestedDurationMinutes: 30,
        notBefore: DateTime(2026, 9, 14, 20),
      );

      expect(result, isEmpty);
    });

    test('returns no availability for a day off', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: const [],
        busyIntervals: const [],
        requestedDurationMinutes: 30,
        notBefore: DateTime(2026, 9, 14, 8),
      );

      expect(result, isEmpty);
    });

    test('drops free fragments that cannot fit the requested duration', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 12)],
        busyIntervals: [
          AvailabilityInterval(
            startsAt: DateTime(2026, 9, 14, 9, 15),
            endsAt: DateTime(2026, 9, 14, 11),
          ),
        ],
        requestedDurationMinutes: 60,
        notBefore: DateTime(2026, 9, 14, 8),
      );

      expect(result, hasLength(1));
      _expectInterval(result.single, startHour: 11, endHour: 12);
    });

    test('merges overlapping busy intervals before subtracting them', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 18)],
        busyIntervals: [
          _interval(10, 11),
          AvailabilityInterval(
            startsAt: DateTime(2026, 9, 14, 10, 30),
            endsAt: DateTime(2026, 9, 14, 12),
          ),
          _interval(12, 13),
        ],
        requestedDurationMinutes: 30,
        notBefore: DateTime(2026, 9, 14, 8),
      );

      expect(result, hasLength(2));
      _expectInterval(result[0], startHour: 9, endHour: 10);
      _expectInterval(result[1], startHour: 13, endHour: 18);
    });

    test('cancelled visits do not occupy availability', () {
      final scheduled = Visit(
        id: 'scheduled',
        patientId: 'patient-1',
        clinicId: 'clinic-1',
        startsAt: DateTime(2026, 9, 14, 10),
        durationMinutes: 30,
      );
      final cancelled = Visit(
        id: 'cancelled',
        patientId: 'patient-2',
        clinicId: 'clinic-1',
        startsAt: DateTime(2026, 9, 14, 11),
        durationMinutes: 30,
        status: VisitStatus.cancelled,
      );
      final visits = [scheduled, cancelled];
      final busy = visits
          .where((visit) => visit.occupiesAvailability)
          .map(
            (visit) => AvailabilityInterval(
              startsAt: visit.startsAt,
              endsAt: visit.endsAt,
            ),
          )
          .toList();

      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 13)],
        busyIntervals: busy,
        requestedDurationMinutes: 30,
        notBefore: DateTime(2026, 9, 14, 8),
      );

      expect(result, hasLength(2));
      _expectInterval(result[0], startHour: 9, endHour: 10);
      _expectInterval(
        result[1],
        startHour: 10,
        startMinute: 30,
        endHour: 13,
      );
    });

    test('accepts an interval exactly equal to requested duration', () {
      final result = engine.findAvailableIntervals(
        workingIntervals: [_interval(9, 10)],
        busyIntervals: const [],
        requestedDurationMinutes: 60,
        notBefore: DateTime(2026, 9, 14, 8),
      );

      expect(result, hasLength(1));
      _expectInterval(result.single, startHour: 9, endHour: 10);
    });
  });

  group('AvailabilityEngine.findSuggestedStarts', () {
    test('rounds a current partial interval up to start precision', () {
      final starts = engine.findSuggestedStarts(
        availableIntervals: [
          AvailabilityInterval(
            startsAt: DateTime(2026, 9, 14, 10, 20),
            endsAt: DateTime(2026, 9, 14, 13),
          ),
        ],
        requestedDurationMinutes: 30,
        startPrecisionMinutes: 30,
        limit: 4,
      );

      expect(starts, [
        DateTime(2026, 9, 14, 10, 30),
        DateTime(2026, 9, 14, 11),
        DateTime(2026, 9, 14, 11, 30),
        DateTime(2026, 9, 14, 12),
      ]);
    });

    test('never suggests a start whose full duration crosses interval end', () {
      final starts = engine.findSuggestedStarts(
        availableIntervals: [_interval(9, 10)],
        requestedDurationMinutes: 45,
        startPrecisionMinutes: 30,
        limit: 4,
      );

      expect(starts, [DateTime(2026, 9, 14, 9)]);
    });

    test('keeps suggestions chronological across multiple intervals', () {
      final starts = engine.findSuggestedStarts(
        availableIntervals: [_interval(14, 16), _interval(9, 10)],
        requestedDurationMinutes: 30,
        startPrecisionMinutes: 30,
        limit: 3,
      );

      expect(starts, [
        DateTime(2026, 9, 14, 9),
        DateTime(2026, 9, 14, 9, 30),
        DateTime(2026, 9, 14, 14),
      ]);
    });
  });
}

AvailabilityInterval _interval(
  int startHour,
  int endHour, {
  int startMinute = 0,
  int endMinute = 0,
}) {
  return AvailabilityInterval(
    startsAt: DateTime(2026, 9, 14, startHour, startMinute),
    endsAt: DateTime(2026, 9, 14, endHour, endMinute),
  );
}

void _expectInterval(
  AvailabilityInterval interval, {
  required int startHour,
  int startMinute = 0,
  required int endHour,
  int endMinute = 0,
}) {
  expect(
    interval.startsAt,
    DateTime(2026, 9, 14, startHour, startMinute),
  );
  expect(
    interval.endsAt,
    DateTime(2026, 9, 14, endHour, endMinute),
  );
}
