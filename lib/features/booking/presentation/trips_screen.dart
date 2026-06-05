import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../application/bookings_controller.dart';
import '../domain/booking.dart';

/// The Trips tab: upcoming and past booking requests grouped by status.
class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: bookings.isEmpty
          ? EmptyState(
              icon: Icons.luggage_outlined,
              title: 'No trips yet',
              message: 'Your booking requests and stays will appear here.',
              action: FilledButton(
                onPressed: () => context.go('/search'),
                style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
                child: const Text('Find a rental'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _GroupLabel('Upcoming'),
                ...bookings
                    .where((b) => b.status != BookingStatus.completed)
                    .map((b) => _TripCard(booking: b)),
                if (bookings.any((b) => b.status == BookingStatus.completed))
                  _GroupLabel('Past'),
                ...bookings
                    .where((b) => b.status == BookingStatus.completed)
                    .map((b) => _TripCard(booking: b)),
              ],
            ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.deepSea,
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d');
    final color = switch (booking.status) {
      BookingStatus.confirmed => AppTheme.seafoam,
      BookingStatus.requested => const Color(0xFFE8A13B),
      BookingStatus.completed => Colors.grey,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => context.push('/listing/${booking.listingId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Color(booking.heroColor),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white38,
                    size: 36,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.listingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: AppTheme.ocean,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.town,
                        style: const TextStyle(
                          color: AppTheme.ocean,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${df.format(booking.checkIn)} – '
                        '${df.format(booking.checkOut)} · '
                        '${booking.guests} guests',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      const Spacer(),
                      Text(
                        Format.money(booking.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.status.detail,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.5,
                    ),
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
