// Exercises the AsyncValue error/retry branch that the happy-path mock can
// never reach, by injecting a failing repository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vacationrentals/features/home/presentation/home_screen.dart';
import 'package:vacationrentals/features/listings/application/listings_providers.dart';
import 'package:vacationrentals/features/listings/data/mock_listings_repository.dart';

void main() {
  testWidgets('Home shows the error state + retry when fetching fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          listingsRepositoryProvider.overrideWithValue(
            MockListingsRepository(failRequests: true),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Past the 350 ms injected delay → the future rejects.
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
