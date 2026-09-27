import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumeno/app/auth/auth_user_scope.dart';

void main() {
  testWidgets('user change disposes the previous patient/provider cache', (
    tester,
  ) async {
    final accountChanges = StreamController<String?>.broadcast(sync: true);
    addTearDown(accountChanges.close);

    String? activeAccount = 'A';
    var requestCount = 0;
    final patientsForCurrentAccount = FutureProvider<String>((ref) async {
      requestCount++;
      return activeAccount == null
          ? 'No patients (signed out)'
          : 'Patients belonging to $activeAccount';
    });

    await tester.pumpWidget(
      AuthUserScope(
        initialUserId: activeAccount,
        userIds: accountChanges.stream,
        child: ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ref.watch(patientsForCurrentAccount).when(
                        data: (value) => Text(value),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, _) => const Text('Request failed'),
                      );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Patients belonging to A'), findsOneWidget);
    expect(requestCount, 1);

    activeAccount = null;
    accountChanges.add(null);
    await tester.pumpAndSettle();
    expect(find.text('No patients (signed out)'), findsOneWidget);
    expect(find.text('Patients belonging to A'), findsNothing);
    expect(requestCount, 2);

    activeAccount = 'B';
    accountChanges.add('B');
    await tester.pumpAndSettle();
    expect(find.text('Patients belonging to B'), findsOneWidget);
    expect(find.text('Patients belonging to A'), findsNothing);
    expect(requestCount, 3);

    activeAccount = 'A';
    accountChanges.add('A');
    await tester.pumpAndSettle();
    expect(find.text('Patients belonging to A'), findsOneWidget);
    expect(find.text('Patients belonging to B'), findsNothing);
    expect(requestCount, 4);
  });
}
