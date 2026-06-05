import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../listings/domain/listing.dart';

/// Map presentation of results. Renders a stylized LBI-shaped map backdrop with
/// tappable price pins and a peek card at the bottom. A real MapKit/Google Maps
/// widget drops in here later; the pin + peek-card interaction stays the same.
class MapResultsView extends StatefulWidget {
  const MapResultsView({super.key, required this.items});
  final List<Listing> items;

  @override
  State<MapResultsView> createState() => _MapResultsViewState();
}

class _MapResultsViewState extends State<MapResultsView> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final selected = widget.items[_selected.clamp(0, widget.items.length - 1)];
    return Stack(
      children: [
        // Stylized water backdrop.
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFFBFE3F2)),
            child: CustomPaint(painter: _IslandPainter()),
          ),
        ),
        // Price pins scattered deterministically across the canvas.
        ...List.generate(widget.items.length, (i) {
          final l = widget.items[i];
          final dx = 0.12 + (l.id.hashCode % 70).abs() / 100;
          final dy = 0.1 + (l.town.name.hashCode % 65).abs() / 100;
          return Align(
            alignment: Alignment(dx * 2 - 1, dy * 2 - 1),
            child: _PricePin(
              label: Format.money(l.weeklyFrom),
              active: i == _selected,
              onTap: () => setState(() => _selected = i),
            ),
          );
        }),
        // Peek card for the selected listing.
        Positioned(
          left: 12,
          right: 12,
          bottom: 16,
          child: _PeekCard(listing: selected),
        ),
      ],
    );
  }
}

class _PricePin extends StatelessWidget {
  const _PricePin({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.sunset : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.deepSea,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PeekCard extends StatelessWidget {
  const _PeekCard({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/listing/${listing.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 84,
                  height: 84,
                  color: Color(listing.heroColor),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      listing.town.path,
                      style: const TextStyle(
                        color: AppTheme.ocean,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.title.replaceAll('**', ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.bedrooms} bd · Sleeps ${listing.sleeps} · '
                      '${Format.money(listing.weeklyFrom)}/wk',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _IslandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final land = Paint()..color = const Color(0xFFE9E2CF);
    final path = Path()
      ..moveTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.58, 0)
      ..lineTo(size.width * 0.52, size.height)
      ..lineTo(size.width * 0.40, size.height)
      ..close();
    canvas.drawPath(path, land);

    final road = Paint()
      ..color = const Color(0xFFC9BFA3)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(size.width * 0.49, 0),
      Offset(size.width * 0.45, size.height),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
