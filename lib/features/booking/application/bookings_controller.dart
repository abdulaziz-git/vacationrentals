import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/booking.dart';

/// Holds the traveler's bookings/trips. Seeded with one upcoming trip so the
/// Trips tab has content; new requests are appended from the quote flow.
class BookingsController extends StateNotifier<List<Booking>> {
  BookingsController()
      : super([
          Booking(
            id: 'BK-1042',
            listingId: '6',
            listingTitle: 'Panoramic Views — Pool, Elevator & Pet Friendly',
            town: 'Surf City',
            heroColor: 0xFF2E86AB,
            checkIn: DateTime(2026, 7, 11),
            checkOut: DateTime(2026, 7, 18),
            guests: 8,
            weeklyRate: 4900,
            travelInsurance: true,
            status: BookingStatus.confirmed,
          ),
        ]);

  int _seq = 1043;

  Booking add(Booking booking) {
    state = [booking, ...state];
    return booking;
  }

  String nextId() => 'BK-${_seq++}';
}

final bookingsProvider =
    StateNotifierProvider<BookingsController, List<Booking>>(
  (ref) => BookingsController(),
);
