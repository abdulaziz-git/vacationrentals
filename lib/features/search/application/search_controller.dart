import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../listings/application/listings_providers.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listings_repository.dart';

/// Holds the live [ListingQuery] driving the results screen.
class SearchQueryController extends StateNotifier<ListingQuery> {
  SearchQueryController() : super(const ListingQuery());

  void update(ListingQuery q) => state = q;
  void reset() => state = const ListingQuery();
  void setText(String? text) => state = state.copyWith(text: text);
}

final searchQueryProvider =
    StateNotifierProvider<SearchQueryController, ListingQuery>(
      (ref) => SearchQueryController(),
    );

/// Results for the current query.
final searchResultsProvider = FutureProvider<List<Listing>>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(listingsRepositoryProvider).search(query);
});

/// Toggle between list and map presentation of the results.
final resultsViewProvider = StateProvider<ResultsView>(
  (ref) => ResultsView.list,
);

enum ResultsView { list, map }
