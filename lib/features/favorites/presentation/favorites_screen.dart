import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/listing_card.dart';
import '../../listings/application/listings_providers.dart';
import '../application/favorites_controller.dart';

/// The Saved tab: listings the traveler has hearted. Reacts live to favorite
/// toggles anywhere in the app.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final all = ref.watch(allListingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: all.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (_, _) => const ListingCardSkeleton(),
        ),
        error: (e, _) =>
            ErrorStateView(onRetry: () => ref.invalidate(allListingsProvider)),
        data: (listings) {
          final saved = listings.where((l) => favIds.contains(l.id)).toList();
          if (saved.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'No saved rentals',
              message: 'Tap the heart on any rental to save it here for later.',
              action: FilledButton(
                onPressed: () => context.go('/search'),
                style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                child: const Text('Browse rentals'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: saved.length,
            itemBuilder: (context, i) => ListingCard(listing: saved[i]),
          );
        },
      ),
    );
  }
}
