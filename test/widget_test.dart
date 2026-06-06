// Smoke test: the app boots into the home screen with the VRLBI brand mark.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vacationrentals/main.dart';

void main() {
  testWidgets('App boots to home with VRLBI branding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VrlbiApp()));
    // Pump past the mock repository's 350ms delay so the loading skeletons
    // (which run repeating shimmer timers) are replaced by the data state.
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('VRLBI'), findsWidgets);
    // The floating bottom-nav renders the active tab's label ("Home" on boot).
    expect(find.text('Home'), findsOneWidget);
  });
}
