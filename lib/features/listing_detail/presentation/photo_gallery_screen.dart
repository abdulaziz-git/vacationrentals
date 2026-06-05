import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_states.dart';
import '../../listings/application/listings_providers.dart';

/// Full-screen photo gallery. A grid of placeholder tiles standing in for the
/// listing's photo set; tapping a tile opens a swipeable full-bleed pager.
class PhotoGalleryScreen extends ConsumerWidget {
  const PhotoGalleryScreen({super.key, required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(listingByIdProvider(listingId));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: async.maybeWhen(
          data: (l) => Text(
            '${l?.photoCount ?? 0} photos',
            style: const TextStyle(color: Colors.white),
          ),
          orElse: () => const Text('Photos'),
        ),
      ),
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => ErrorStateView(
          onRetry: () => ref.invalidate(listingByIdProvider(listingId)),
        ),
        data: (l) {
          if (l == null) {
            return const Center(
              child: Text('No photos', style: TextStyle(color: Colors.white70)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: l.photoCount,
            itemBuilder: (context, i) {
              final shade = Color.lerp(
                Color(l.heroColor),
                Colors.black,
                i / l.photoCount,
              )!;
              return GestureDetector(
                onTap: () => _openPager(context, l.heroColor, l.photoCount, i),
                child: Container(
                  color: shade,
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white24,
                    size: 30,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openPager(BuildContext context, int color, int count, int start) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PagerView(color: color, count: count, start: start),
      ),
    );
  }
}

class _PagerView extends StatelessWidget {
  const _PagerView({
    required this.color,
    required this.count,
    required this.start,
  });
  final int color;
  final int count;
  final int start;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: start),
        itemCount: count,
        itemBuilder: (context, i) {
          final shade = Color.lerp(Color(color), Colors.black, i / count)!;
          return Center(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: shade,
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.white24,
                  size: 60,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
