import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/account_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/booking/presentation/booking_confirmation_screen.dart';
import '../../features/booking/presentation/quote_screen.dart';
import '../../features/booking/presentation/trips_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/listing_detail/presentation/listing_detail_screen.dart';
import '../../features/listing_detail/presentation/photo_gallery_screen.dart';
import '../../features/owner/presentation/owner_profile_screen.dart';
import '../../features/reviews/presentation/write_review_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import 'scaffold_with_nav.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

/// App router. A [StatefulShellRoute] hosts the five primary tabs; detail,
/// booking, auth and gallery routes push over the shell from the root.
/// Initial location. Honors a `START_ROUTE` define (used to deep-link into a
/// single screen during simulator verification, e.g.
/// `--dart-define=START_ROUTE=/search`); defaults to `/home`.
const _startRoute = String.fromEnvironment(
  'START_ROUTE',
  defaultValue: '/home',
);

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: _startRoute,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ScaffoldWithNav(shell: shell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trips',
              builder: (context, state) => const TripsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/listing/:id',
      builder: (context, state) =>
          ListingDetailScreen(listingId: state.pathParameters['id']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/listing/:id/photos',
      builder: (context, state) =>
          PhotoGalleryScreen(listingId: state.pathParameters['id']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/listing/:id/review',
      builder: (context, state) =>
          WriteReviewScreen(listingId: state.pathParameters['id']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/listing/:id/quote',
      builder: (context, state) =>
          QuoteScreen(listingId: state.pathParameters['id']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/booking/:id/confirmed',
      builder: (context, state) =>
          BookingConfirmationScreen(bookingId: state.pathParameters['id']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/owner/:name',
      builder: (context, state) =>
          OwnerProfileScreen(ownerName: state.pathParameters['name']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
  ],
);
