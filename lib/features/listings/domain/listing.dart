// Domain entities for the VRLBI catalog. Plain immutable Dart (no Flutter
// imports) so the domain layer stays framework-agnostic per the architecture
// ledger. Swap to Freezed later — these are drop-in compatible.

/// Long Beach Island is split into broad regions. Each town belongs to one.
enum LbiRegion {
  northEnd('LBI - North End'),
  middleIsland('LBI - Middle Island'),
  southEnd('LBI - South End'),
  mainland('LBI - Mainland Area');

  const LbiRegion(this.label);
  final String label;
}

/// Property kinds seen across the VRLBI inventory.
enum PropertyType {
  house('House'),
  condo('Condo'),
  duplex('Duplex'),
  townhouse('Townhouse'),
  cottage('Cottage'),
  apartment('Apartment'),
  boatYacht('Boat - Yacht');

  const PropertyType(this.label);
  final String label;
}

/// Where the home sits relative to the water — a primary VRLBI filter.
enum LocationType {
  oceanfront('Oceanfront'),
  oceanBlock('Ocean Block'),
  bayside('Bayside'),
  bayfront('Bayfront'),
  midIsland('Mid-Island');

  const LocationType(this.label);
  final String label;
}

/// A town on the island, scoped to a region.
class Town {
  const Town(this.name, this.region);
  final String name;
  final LbiRegion region;

  String get path => '${region.label} > $name';
}

/// One amenity, grouped into the buckets VRLBI uses on the detail page.
enum AmenityGroup { popular, indoor, outdoor, access, entertainment }

class Amenity {
  const Amenity(this.label, this.group, {this.icon});
  final String label;
  final AmenityGroup group;

  /// Optional Material icon codepoint name resolved in the UI layer.
  final String? icon;
}

/// A nightly/weekly/monthly rate band for a date range.
class RatePeriod {
  const RatePeriod({
    required this.label,
    required this.start,
    required this.end,
    this.nightly,
    this.weekly,
    this.monthly,
    required this.minNights,
    this.changeoverDay,
  });

  final String label;
  final DateTime start;
  final DateTime end;
  final int? nightly;
  final int? weekly;
  final int? monthly;
  final int minNights;
  final String? changeoverDay;
}

/// Availability state for a single calendar day.
enum DayStatus { available, pending, notAvailable, noRates }

class AvailabilityDay {
  const AvailabilityDay(this.date, this.status);
  final DateTime date;
  final DayStatus status;
}

/// A guest review.
class Review {
  const Review({
    required this.author,
    required this.rating,
    required this.date,
    required this.body,
  });

  final String author;
  final double rating;
  final DateTime date;
  final String body;
}

/// The verified owner / manager behind a listing.
class Owner {
  const Owner({
    required this.name,
    required this.verified,
    required this.listingCount,
    required this.responseTime,
  });

  final String name;
  final bool verified;
  final int listingCount;
  final String responseTime;
}

/// Sleeping configuration, e.g. "2 Queen, 2 Bunk".
class BedConfig {
  const BedConfig(this.label, this.count);
  final String label;
  final int count;
}

/// The core catalog entity — a rentable property.
class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.town,
    required this.propertyType,
    required this.locationType,
    required this.bedrooms,
    required this.fullBaths,
    required this.halfBaths,
    required this.sleeps,
    required this.sqft,
    required this.weeklyFrom,
    this.weeklyTo,
    required this.heroColor,
    required this.photoCount,
    required this.description,
    required this.bedConfig,
    required this.amenities,
    required this.rates,
    required this.availability,
    required this.reviews,
    required this.owner,
    this.rating = 0,
    this.parking = 0,
    this.keylessEntry = false,
    this.petsWelcome = false,
    this.smokingAllowed = false,
    this.wheelchairAccessible = false,
    this.badges = const [],
    this.viewCount = 0,
  });

  final String id;
  final String title;
  final Town town;
  final PropertyType propertyType;
  final LocationType locationType;
  final int bedrooms;
  final int fullBaths;
  final int halfBaths;
  final int sleeps;
  final int sqft;
  final int weeklyFrom;
  final int? weeklyTo;

  /// Seed color used to render the placeholder photo in the mock build.
  final int heroColor;
  final int photoCount;
  final String description;
  final List<BedConfig> bedConfig;
  final List<Amenity> amenities;
  final List<RatePeriod> rates;
  final List<AvailabilityDay> availability;
  final List<Review> reviews;
  final Owner owner;
  final double rating;
  final int parking;
  final bool keylessEntry;
  final bool petsWelcome;
  final bool smokingAllowed;
  final bool wheelchairAccessible;
  final List<String> badges;
  final int viewCount;

  double get reviewAverage {
    if (reviews.isEmpty) return rating;
    final sum = reviews.fold<double>(0, (a, r) => a + r.rating);
    return sum / reviews.length;
  }

  String get bathLabel {
    final parts = <String>['$fullBaths full'];
    if (halfBaths > 0) parts.add('$halfBaths half');
    return parts.join(', ');
  }

  int get totalBaths => fullBaths + halfBaths;
}
