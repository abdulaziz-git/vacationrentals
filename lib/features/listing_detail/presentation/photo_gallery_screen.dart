import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_states.dart';
import '../../listings/application/listings_providers.dart';

/// Full-screen photo gallery: a grid of the listing's real photos; tapping a
/// tile opens a swipeable full-bleed pager.
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
            '${l?.photos.length ?? 0} photos',
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
          final photos = l?.photos ?? const <String>[];
          if (l == null || photos.isEmpty) {
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
            itemCount: photos.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => _openPager(context, photos, i),
                child: Image.asset(
                  photos[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Color(l.heroColor),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.white24,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openPager(BuildContext context, List<String> photos, int start) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PagerView(photos: photos, start: start),
      ),
    );
  }
}

class _PagerView extends StatelessWidget {
  const _PagerView({required this.photos, required this.start});
  final List<String> photos;
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
        itemCount: photos.length,
        itemBuilder: (context, i) {
          return Center(
            child: InteractiveViewer(
              child: Image.asset(
                photos[i],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image_outlined,
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
