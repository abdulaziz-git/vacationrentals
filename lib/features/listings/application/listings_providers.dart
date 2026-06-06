import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_listings_repository.dart';
import '../domain/listing.dart';
import '../domain/listings_repository.dart';

/// Single source of truth for the catalog data layer. Swap the concrete
/// implementation here when the REST repository lands.
final listingsRepositoryProvider = Provider<ListingsRepository>(
  (ref) => MockListingsRepository(),
);

/// Featured rentals for the home screen.
final featuredListingsProvider = FutureProvider<List<Listing>>(
  (ref) => ref.watch(listingsRepositoryProvider).fetchFeatured(),
);

/// Full catalog (used by the default search results view).
final allListingsProvider = FutureProvider<List<Listing>>(
  (ref) => ref.watch(listingsRepositoryProvider).fetchAll(),
);

/// A single listing by id, for the detail screen. autoDispose so per-id state
/// is released when the screen is popped and re-fetched on next visit (matters
/// once REST data can change between visits).
final listingByIdProvider = FutureProvider.autoDispose.family<Listing?, String>(
  (ref, id) => ref.watch(listingsRepositoryProvider).byId(id),
);

/// Other rentals from the same owner (detail screen "nearby / more from host").
final ownerListingsProvider = FutureProvider.autoDispose
    .family<List<Listing>, ({String owner, String excludeId})>(
      (ref, arg) => ref
          .watch(listingsRepositoryProvider)
          .byOwner(arg.owner, excludeId: arg.excludeId),
    );

/// The static list of towns for filter UIs.
final townsProvider = Provider<List<Town>>(
  (ref) => ref.watch(listingsRepositoryProvider).towns(),
);
