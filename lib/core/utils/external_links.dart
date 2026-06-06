import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// VRLBI external destinations (placeholders pointing at the live site until
/// dedicated policy pages exist).
class ExternalLinks {
  ExternalLinks._();

  static final Uri privacyPolicy = Uri.parse(
    'https://www.vacationrentalslbi.com/privacy',
  );
  static final Uri terms = Uri.parse(
    'https://www.vacationrentalslbi.com/terms',
  );
  static final Uri support = Uri.parse('https://www.vacationrentalslbi.com');

  /// Apple/Google Maps query for a place (opens the platform maps app).
  static Uri mapsQuery(String place) =>
      Uri.parse('https://maps.apple.com/?q=${Uri.encodeComponent(place)}');
}

/// Opens [url] in the platform browser/app; on failure shows a SnackBar instead
/// of throwing, so a missing handler never crashes the UI.
Future<void> openExternal(BuildContext context, Uri url) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't open ${url.host}")),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      SnackBar(content: Text("Couldn't open ${url.host}")),
    );
  }
}
