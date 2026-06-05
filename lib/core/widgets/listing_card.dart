import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/application/favorites_controller.dart';
import '../../features/listings/domain/listing.dart';
import '../theme/app_theme.dart';
import 'photo_placeholder.dart';

/// The primary catalog card. Two layouts: a wide [ListingCard] for vertical
/// lists and a [ListingCardCompact] for horizontal carousels.
class ListingCard extends ConsumerWidget {
  const ListingCard({super.key, required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(listing.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PhotoPlaceholder(
                  seedColor: listing.heroColor,
                  height: 200,
                  label: listing.propertyType.label,
                  photoCount: listing.photoCount,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _FavButton(
                    active: isFav,
                    onTap: () =>
                        ref.read(favoritesProvider.notifier).toggle(listing.id),
                  ),
                ),
                if (listing.badges.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(listing.badges.first),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: AppTheme.ocean,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          listing.town.path,
                          style: const TextStyle(
                            color: AppTheme.ocean,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      if (listing.reviewAverage > 0) ...[
                        const Icon(Icons.star, size: 15, color: AppTheme.sun),
                        const SizedBox(width: 2),
                        Text(
                          listing.reviewAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    listing.title.replaceAll('**', ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SpecRow(listing: listing),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Format.money(listing.weeklyFrom),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.ocean,
                        ),
                      ),
                      const Text(
                        ' /week',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const Spacer(),
                      Text(
                        '${listing.viewCount} views',
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        chip(Icons.king_bed_outlined, '${listing.bedrooms} bd'),
        chip(Icons.bathtub_outlined, '${listing.totalBaths} ba'),
        chip(Icons.group_outlined, 'Sleeps ${listing.sleeps}'),
      ],
    );
  }
}

class ListingCardCompact extends ConsumerWidget {
  const ListingCardCompact({super.key, required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(listing.id);
    return SizedBox(
      width: 250,
      child: Card(
        margin: const EdgeInsets.only(right: 14),
        child: InkWell(
          onTap: () => context.push('/listing/${listing.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  PhotoPlaceholder(
                    seedColor: listing.heroColor,
                    height: 150,
                    label: listing.propertyType.label,
                    photoCount: listing.photoCount,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _FavButton(
                      active: isFav,
                      onTap: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(listing.id),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.town.name,
                      style: const TextStyle(
                        color: AppTheme.ocean,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title.replaceAll('**', ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${listing.bedrooms} bd · Sleeps ${listing.sleeps}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${Format.money(listing.weeklyFrom)} /wk',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact horizontal row used in the search/Lists results: a rounded
/// thumbnail with an overlaid rating pill, title, meta lines, a "Verified"
/// badge and the weekly price. Mirrors the Lists.png reference.
class ListingListRow extends ConsumerWidget {
  const ListingListRow({super.key, required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/listing/${listing.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: PhotoPlaceholder(
                    seedColor: listing.heroColor,
                    height: 104,
                    width: 96,
                  ),
                ),
                if (listing.reviewAverage > 0)
                  Positioned(
                    left: 8,
                    bottom: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.deepSea.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 13, color: AppTheme.sun),
                          const SizedBox(width: 3),
                          Text(
                            listing.reviewAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title.replaceAll('**', ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      height: 1.2,
                      color: AppTheme.deepSea,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${listing.bedrooms} Bedrooms · ${listing.propertyType.label}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          listing.town.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (listing.owner.verified) const _VerifiedBadge(),
                      const Spacer(),
                      Text(
                        Format.money(listing.weeklyFrom),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.deepSea,
                        ),
                      ),
                      const Text(
                        '/wk',
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small "Verified" pill with the brand-blue check, reused across cards.
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Verified',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppTheme.ocean,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 10, color: Colors.white),
        ),
      ],
    );
  }
}

/// Square-ish card for 2-column grids (home featured / saved). Rounded photo
/// with a favorite toggle, title, short description and weekly price.
class ListingGridCard extends ConsumerWidget {
  const ListingGridCard({super.key, required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(listing.id);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/listing/${listing.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PhotoPlaceholder(
                  seedColor: listing.heroColor,
                  height: 150,
                  label: listing.propertyType.label,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _FavButton(
                  active: isFav,
                  onTap: () =>
                      ref.read(favoritesProvider.notifier).toggle(listing.id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            listing.title.replaceAll('**', ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: AppTheme.deepSea,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            listing.description.replaceAll('\n', ' '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Format.money(listing.weeklyFrom),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppTheme.ocean,
                ),
              ),
              const Text(
                '/wk',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            active ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: active ? AppTheme.heart : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.deepSea.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
