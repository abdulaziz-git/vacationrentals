import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../application/bookings_controller.dart';
import '../domain/booking.dart';

/// Shown after a successful "Request to Book". Confirms the request and points
/// the traveler to their Trips tab.
class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref
        .watch(bookingsProvider)
        .where((b) => b.id == bookingId)
        .firstOrNull;
    return Scaffold(
      body: SafeArea(
        child: booking == null
            ? const EmptyState(
                icon: Icons.error_outline,
                title: 'Booking not found',
                message: 'We could not locate this request.')
            : _Body(booking: booking),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, MMM d, y');
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.seafoam.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: AppTheme.seafoam, size: 56),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Request sent!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Your booking request for ${booking.town} has been sent to the '
                'owner. You\'ll get a confirmation once they accept — usually '
                'within a day.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Request ${booking.id}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE2B8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(booking.status.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _row('Rental', booking.listingTitle),
                    _row('Check-in', df.format(booking.checkIn)),
                    _row('Check-out', df.format(booking.checkOut)),
                    _row('Guests', '${booking.guests}'),
                    _row('Total', Format.money(booking.total)),
                    _row('Deposit due now', Format.money(booking.depositDue)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, 16 + MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              FilledButton(
                onPressed: () => context.go('/trips'),
                child: const Text('View my trips'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 120,
                child: Text(label,
                    style: TextStyle(color: Colors.grey.shade600))),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
