import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/favorites_controller.dart';

/// Toggles a listing's saved state with a haptic tick, and — when *removing* —
/// shows an undo SnackBar (HIG: confirm/undo on committing actions).
void toggleFavorite(BuildContext context, WidgetRef ref, String id) {
  final notifier = ref.read(favoritesProvider.notifier);
  final wasSaved = ref.read(favoritesProvider).contains(id);
  HapticFeedback.selectionClick();
  notifier.toggle(id);
  if (wasSaved) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Removed from saved'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => notifier.toggle(id),
          ),
        ),
      );
  }
}
