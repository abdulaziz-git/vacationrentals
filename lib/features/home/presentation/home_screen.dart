import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/listing_card.dart';
import '../../listings/application/listings_providers.dart';
import '../../listings/domain/listing.dart';
import '../../search/application/search_controller.dart';

/// Home: hero search prompt, curated collections, featured rentals carousel,
/// and browse-by-region. Demonstrates AsyncValue's loading / error / data
/// states; the carousel also renders an empty state when nothing is returned.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredListingsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(featuredListingsProvider.future),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Hero()),
              const SliverToBoxAdapter(child: _Collections()),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Featured LBI Rentals',
                  actionLabel: 'See all',
                  onAction: () => context.go('/search'),
                ),
              ),
              featured.when(
                loading: () => const SliverToBoxAdapter(
                    child: _FeaturedSkeleton()),
                error: (e, _) => SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: ErrorStateView(
                      onRetry: () =>
                          ref.invalidate(featuredListingsProvider),
                    ),
                  ),
                ),
                data: (items) => SliverToBoxAdapter(
                  child: items.isEmpty
                      ? const SizedBox(
                          height: 200,
                          child: EmptyState(
                            icon: Icons.house_outlined,
                            title: 'No featured rentals',
                            message: 'Check back soon for new listings.',
                          ),
                        )
                      : _FeaturedCarousel(items: items),
                ),
              ),
              const SliverToBoxAdapter(child: _BrowseByRegion()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.ocean, Color(0xFF0A567A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('VRLBI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Book Direct · No Fees',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Find your Long Beach\nIsland getaway',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                height: 1.15,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _SearchPrompt(),
        ],
      ),
    );
  }
}

class _SearchPrompt extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/search'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.ocean),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Where on LBI?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepSea)),
                    Text('Any dates · Add guests',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: AppTheme.sunset, shape: BoxShape.circle),
                child: const Icon(Icons.tune,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Collections extends ConsumerWidget {
  const _Collections();

  static const _items = [
    ('Oceanfront', Icons.waves, LocationType.oceanfront),
    ('With Pools', Icons.pool, null),
    ('Ocean Block', Icons.beach_access, LocationType.oceanBlock),
    ('Bayside', Icons.sailing, LocationType.bayside),
    ('Pet Friendly', Icons.pets, null),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final (label, icon, loc) = _items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final q = ref.read(searchQueryProvider);
              ref.read(searchQueryProvider.notifier).update(
                    loc == null
                        ? q
                        : q.copyWith(locationTypes: {loc}),
                  );
              context.go('/search');
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.ocean.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppTheme.ocean),
                ),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({required this.items});
  final List<Listing> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, i) =>
            ListingCardCompact(listing: items[i]),
      ),
    );
  }
}

class _FeaturedSkeleton extends StatelessWidget {
  const _FeaturedSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, i) => Container(
          width: 250,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
                child: SkeletonBox(height: 150, radius: 0),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 12, width: 90),
                    SizedBox(height: 10),
                    SkeletonBox(height: 14, width: 180),
                    SizedBox(height: 12),
                    SkeletonBox(height: 12, width: 120),
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

class _BrowseByRegion extends ConsumerWidget {
  const _BrowseByRegion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = LbiRegion.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Browse by Area'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: regions.map((r) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.seafoam.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.map_outlined, color: AppTheme.seafoam),
                  ),
                  title: Text(r.label,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Tap to explore rentals'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(searchQueryProvider.notifier).update(
                          ref.read(searchQueryProvider).copyWith(region: r),
                        );
                    context.go('/search');
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
