import 'dart:async';

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
  if (!wasSaved) return;

  const dwell = Duration(seconds: 3);
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  final controller = messenger.showSnackBar(
    SnackBar(
      content: const Text('Removed from saved'),
      duration: dwell,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => notifier.toggle(id),
      ),
    ),
  );

  // Flutter's built-in auto-dismiss timer only starts once the entrance
  // animation reports "completed" — which doesn't happen under Reduce Motion /
  // a screen reader, leaving the SnackBar stuck until acted on. Drive the
  // dismissal ourselves so it always clears after [dwell] (cancelled if the
  // user taps Undo, which closes the controller early).
  var open = true;
  unawaited(controller.closed.then((_) => open = false));
  Timer(dwell, () {
    if (open) {
      messenger.removeCurrentSnackBar(reason: SnackBarClosedReason.timeout);
    }
  });
}
