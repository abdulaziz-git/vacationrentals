import 'package:flutter/material.dart';

/// Renders a gradient placeholder standing in for a listing photo. Keeps the
/// mock build fully offline (no network image fetch). Replace with a real
/// image widget once photo URLs are wired up.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.seedColor,
    required this.height,
    this.label,
    this.photoCount,
    this.icon = Icons.photo_camera_outlined,
  });

  final int seedColor;
  final double height;
  final String? label;
  final int? photoCount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final base = Color(seedColor);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: 0.95),
            Color.lerp(base, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon,
                size: 40, color: Colors.white.withValues(alpha: 0.55)),
          ),
          if (label != null)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          if (photoCount != null)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.collections_outlined,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('$photoCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
