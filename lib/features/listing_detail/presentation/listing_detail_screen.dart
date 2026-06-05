import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/amenity_icons.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../favorites/application/favorites_controller.dart';
import '../../listings/application/listings_providers.dart';
import '../../listings/domain/listing.dart';
import 'widgets/availability_calendar.dart';
import 'widgets/rates_table.dart';

/// The full property page: gallery header, specs, description, amenities,
/// availability, rates, policies, suitability, reviews, owner, and a sticky
/// "Request to Book" bar.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(listingByIdProvider(listingId));
    return Scaffold(
      body: async.when(
        loading: () => const _DetailSkeleton(),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: ErrorStateView(
              onRetry: () => ref.invalidate(listingByIdProvider(listingId))),
        ),
        data: (listing) {
          if (listing == null) {
            return const Scaffold(
              body: EmptyState(
                icon: Icons.house_outlined,
                title: 'Listing not found',
                message: 'This rental may no longer be available.',
              ),
            );
          }
          return _DetailBody(listing: listing);
        },
      ),
      bottomNavigationBar:
          async.maybeWhen(data: (l) => l == null ? null : _BookBar(listing: l), orElse: () => null),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(listing.id);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          leading: _circleButton(
              context, Icons.arrow_back, () => context.pop()),
          actions: [
            _circleButton(context, Icons.ios_share, () {}),
            _circleButton(
              context,
              isFav ? Icons.favorite : Icons.favorite_border,
              () => ref.read(favoritesProvider.notifier).toggle(listing.id),
              tint: isFav ? AppTheme.sunset : null,
            ),
            const SizedBox(width: 6),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: GestureDetector(
              onTap: () => context.push('/listing/${listing.id}/photos'),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PhotoPlaceholder(
                    seedColor: listing.heroColor,
                    height: 280,
                    icon: Icons.image_outlined,
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.collections,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('View all ${listing.photoCount} photos',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (listing.badges.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: listing.badges
                        .map((b) => Chip(
                              label: Text(b),
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  AppTheme.seafoam.withValues(alpha: 0.12),
                              side: BorderSide.none,
                              labelStyle: const TextStyle(
                                  color: AppTheme.seafoam,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: AppTheme.ocean),
                    const SizedBox(width: 4),
                    Text(listing.town.path,
                        style: const TextStyle(
                            color: AppTheme.ocean,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${listing.viewCount} views',
                        style: const TextStyle(
                            color: Colors.black45, fontSize: 12.5)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(listing.title.replaceAll('**', ''),
                    style: const TextStyle(
                        fontSize: 24,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.deepSea)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    RatingStars(rating: listing.reviewAverage),
                    const SizedBox(width: 8),
                    Text(
                      listing.reviews.isEmpty
                          ? 'No reviews yet'
                          : '${listing.reviewAverage.toStringAsFixed(1)} · '
                              '${listing.reviews.length} reviews',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SpecGrid(listing: listing),
                const Divider(height: 36),
                _section('About this rental'),
                Text(listing.description,
                    style: const TextStyle(height: 1.55, fontSize: 15)),
                const Divider(height: 36),
                _section('Sleeping arrangements'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: listing.bedConfig
                      .map((b) => _bedChip(b))
                      .toList(),
                ),
                const Divider(height: 36),
                _section('Amenities'),
                _Amenities(listing: listing),
                const Divider(height: 36),
                _section('Availability'),
                AvailabilityCalendar(days: listing.availability),
                const Divider(height: 36),
                _section('Rates'),
                RatesTable(rates: listing.rates),
                const Divider(height: 36),
                _section('Policies'),
                const _Policies(),
                const Divider(height: 36),
                _section('Good to know'),
                _Suitability(listing: listing),
                const Divider(height: 36),
                _ReviewsSection(listing: listing),
                const Divider(height: 36),
                _OwnerCard(listing: listing),
                const SizedBox(height: 24),
                _MoreFromOwner(listing: listing),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(t,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.deepSea)),
      );

  Widget _bedChip(BedConfig b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bed, size: 20, color: AppTheme.ocean),
            const SizedBox(width: 8),
            Text('${b.count}× ${b.label}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _circleButton(BuildContext context, IconData icon, VoidCallback onTap,
      {Color? tint}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: tint ?? AppTheme.deepSea),
          ),
        ),
      ),
    );
  }
}

class _SpecGrid extends StatelessWidget {
  const _SpecGrid({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final specs = [
      (Icons.king_bed_outlined, '${listing.bedrooms}', 'Bedrooms'),
      (Icons.bathtub_outlined, '${listing.totalBaths}', 'Bathrooms'),
      (Icons.group_outlined, '${listing.sleeps}', 'Sleeps'),
      (Icons.square_foot, '${listing.sqft}', 'Sq ft'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.sand.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: specs.map((s) {
          return Expanded(
            child: Column(
              children: [
                Icon(s.$1, color: AppTheme.ocean),
                const SizedBox(height: 6),
                Text(s.$2,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17)),
                Text(s.$3,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Amenities extends StatelessWidget {
  const _Amenities({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final popular =
        listing.amenities.where((a) => a.group == AmenityGroup.popular).toList();
    final rest =
        listing.amenities.where((a) => a.group != AmenityGroup.popular).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 4.5,
          children: popular
              .map((a) => Row(
                    children: [
                      Icon(amenityIcon(a.icon, a.label),
                          size: 20, color: AppTheme.deepSea),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(a.label,
                              style: const TextStyle(fontSize: 14))),
                    ],
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _showAll(context, rest),
          style: OutlinedButton.styleFrom(minimumSize: const Size(180, 46)),
          child: Text('Show all ${listing.amenities.length} amenities'),
        ),
      ],
    );
  }

  void _showAll(BuildContext context, List<Amenity> rest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('All amenities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...listing.amenities.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(amenityIcon(a.icon, a.label),
                          size: 20, color: AppTheme.deepSea),
                      const SizedBox(width: 12),
                      Text(a.label, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _Policies extends StatelessWidget {
  const _Policies();

  @override
  Widget build(BuildContext context) {
    Widget row(IconData i, String t, String s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(i, size: 20, color: AppTheme.ocean),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t,
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                    Text(s,
                        style: TextStyle(
                            color: Colors.grey.shade700, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        );
    return Column(
      children: [
        row(Icons.login, 'Check-in / Check-out',
            'Check-in 2:00 PM · Check-out 12:00 PM · Changeover any day'),
        row(Icons.payments_outlined, 'Deposit',
            '50% deposit due within 7 days. Balance + security deposit due 45 days before arrival.'),
        row(Icons.cancel_outlined, 'Cancellation',
            'Refund minus 15% service fee if re-booked. Travel insurance strongly recommended.'),
      ],
    );
  }
}

class _Suitability extends StatelessWidget {
  const _Suitability({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, bool ok) => Row(
          children: [
            Icon(ok ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: ok ? AppTheme.seafoam : Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: ok ? AppTheme.deepSea : Colors.grey.shade500,
                    decoration: ok ? null : TextDecoration.lineThrough)),
          ],
        );
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: [
        item(Icons.pets, 'Pets welcome', listing.petsWelcome),
        item(Icons.smoking_rooms, 'Smoking allowed', listing.smokingAllowed),
        item(Icons.accessible, 'Wheelchair accessible',
            listing.wheelchairAccessible),
        item(Icons.vpn_key, 'Key-less entry', listing.keylessEntry),
        item(Icons.local_parking, '${listing.parking} car parking',
            listing.parking > 0),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              listing.reviews.isEmpty
                  ? 'Reviews'
                  : '${listing.reviewAverage.toStringAsFixed(1)} · '
                      '${listing.reviews.length} reviews',
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepSea),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/listing/${listing.id}/review'),
              child: const Text('Write a review'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (listing.reviews.isEmpty)
          const EmptyState(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            message: 'Be the first guest to review this rental.',
          )
        else
          ...listing.reviews.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              AppTheme.ocean.withValues(alpha: 0.15),
                          child: Text(r.author[0],
                              style: const TextStyle(
                                  color: AppTheme.ocean,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Text(r.author,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        RatingStars(rating: r.rating, size: 14),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r.body, style: const TextStyle(height: 1.45)),
                  ],
                ),
              )),
      ],
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final o = listing.owner;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sand.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.ocean,
            child: Text(o.name[0],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(o.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    if (o.verified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          size: 18, color: AppTheme.ocean),
                    ],
                  ],
                ),
                Text('${o.listingCount} rentals · Responds ${o.responseTime}',
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 13)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/owner/${Uri.encodeComponent(o.name)}'),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Contact owner'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreFromOwner extends ConsumerWidget {
  const _MoreFromOwner({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final others = ref.watch(ownerListingsProvider(
        (owner: listing.owner.name, excludeId: listing.id)));
    return others.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('More from this owner',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.deepSea)),
            const SizedBox(height: 12),
            ...items.take(3).map((l) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => context.push('/listing/${l.id}'),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: Color(l.heroColor),
                        child: const Icon(Icons.photo_camera_outlined,
                            color: Colors.white54, size: 20),
                      ),
                    ),
                    title: Text(l.title.replaceAll('**', ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text(
                        '${l.town.name} · ${Format.money(l.weeklyFrom)}/wk'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                )),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _BookBar extends StatelessWidget {
  const _BookBar({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Format.money(listing.weeklyFrom),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 20)),
              const Text('per week', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: () => context.push('/listing/${listing.id}/quote'),
              child: const Text('Request to Book'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        SkeletonBox(height: 280, radius: 0),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 14, width: 140),
              SizedBox(height: 12),
              SkeletonBox(height: 24, width: 260),
              SizedBox(height: 16),
              SkeletonBox(height: 80),
              SizedBox(height: 20),
              SkeletonBox(height: 16, width: 200),
              SizedBox(height: 10),
              SkeletonBox(height: 16),
              SizedBox(height: 10),
              SkeletonBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
