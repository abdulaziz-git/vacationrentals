import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/listing_card.dart';
import '../../listings/application/listings_providers.dart';

/// Public owner / manager profile with their verified badge, stats, a contact
/// action, and the full set of their listings.
class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key, required this.ownerName});
  final String ownerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = Uri.decodeComponent(ownerName);
    final listings =
        ref.watch(ownerListingsProvider((owner: name, excludeId: '')));
    return Scaffold(
      appBar: AppBar(title: const Text('Owner profile')),
      body: listings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
            onRetry: () => ref.invalidate(
                ownerListingsProvider((owner: name, excludeId: '')))),
        data: (items) {
          final sample = items.isNotEmpty ? items.first.owner : null;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.ocean,
                    child: Text(name[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified,
                                color: AppTheme.ocean, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Verified owner / manager',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                        if (sample != null)
                          Text('Responds ${sample.responseTime}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.mail_outline, size: 18),
                      label: const Text('Email'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Call'),
                    ),
                  ),
                ],
              ),
              const Divider(height: 36),
              Text('${items.length} rentals from $name',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const EmptyState(
                  icon: Icons.house_outlined,
                  title: 'No active listings',
                  message: 'This owner has no published rentals right now.',
                )
              else
                ...items.map((l) => ListingCard(listing: l)),
            ],
          );
        },
      ),
    );
  }
}
