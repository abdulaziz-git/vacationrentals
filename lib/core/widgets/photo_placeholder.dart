import 'package:flutter/material.dart';

/// Renders a listing photo from a bundled asset ([imageAsset]); when absent
/// (or the asset fails to load) it falls back to a solid [seedColor] block
/// with a camera icon, so the mock build degrades gracefully.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.seedColor,
    required this.height,
    this.width = double.infinity,
    this.imageAsset,
    this.semanticLabel,
    this.label,
    this.photoCount,
    this.icon = Icons.photo_camera_outlined,
  });

  final int seedColor;
  final double height;
  final double width;

  /// Optional bundled image asset path; rendered with [BoxFit.cover].
  final String? imageAsset;

  /// VoiceOver description for the image (e.g. the listing title).
  final String? semanticLabel;
  final String? label;
  final int? photoCount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final base = Color(seedColor);
    Widget colorBlock() => Container(
      color: base,
      alignment: Alignment.center,
      child: Icon(icon, size: 40, color: Colors.white.withValues(alpha: 0.55)),
    );
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              semanticLabel: semanticLabel,
              errorBuilder: (_, _, _) => colorBlock(),
            )
          else
            colorBlock(),
          if (label != null)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (photoCount != null)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.collections_outlined,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$photoCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
