import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory saved/favorites set keyed by listing id. Persist to local storage
/// or the backend later — the UI only depends on this notifier.
class FavoritesController extends StateNotifier<Set<String>> {
  FavoritesController() : super(const {'1', '4'});

  void toggle(String id) {
    state = state.contains(id)
        ? (Set.of(state)..remove(id))
        : (Set.of(state)..add(id));
  }

  bool isFavorite(String id) => state.contains(id);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesController, Set<String>>(
  (ref) => FavoritesController(),
);
