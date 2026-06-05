/// A confirmed or in-progress booking request. VRLBI is a "request to book"
/// model — the owner confirms — so a booking starts as a quote.
class Booking {
  const Booking({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.town,
    required this.heroColor,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.weeklyRate,
    required this.travelInsurance,
    required this.status,
  });

  final String id;
  final String listingId;
  final String listingTitle;
  final String town;
  final int heroColor;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int weeklyRate;
  final bool travelInsurance;
  final BookingStatus status;

  int get nights => checkOut.difference(checkIn).inDays;

  int get weeks => (nights / 7).ceil();

  /// Base rental cost — prorated by week (VRLBI's primary unit).
  int get rentalCost => (weeklyRate * (nights / 7)).round();

  int get cleaningFee => 250;

  int get insuranceCost =>
      travelInsurance ? (rentalCost * 0.07).round() : 0;

  /// 12.625% NJ short-term rental tax (state + occupancy), illustrative.
  int get taxes => (rentalCost * 0.12625).round();

  int get total => rentalCost + cleaningFee + insuranceCost + taxes;

  /// 50% deposit due within 7 days, per VRLBI policy.
  int get depositDue => (total * 0.5).round();
}

enum BookingStatus {
  requested('Requested', 'Awaiting owner confirmation'),
  confirmed('Confirmed', 'Your stay is booked'),
  completed('Completed', 'Trip complete');

  const BookingStatus(this.label, this.detail);
  final String label;
  final String detail;
}
