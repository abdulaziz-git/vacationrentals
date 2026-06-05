import '../domain/listing.dart';
import '../domain/listings_repository.dart';

/// In-memory implementation seeded from the real VRLBI scrape (towns, rates,
/// the "Bayside Beauty" detail page, amenity taxonomy). Returns Dart objects
/// directly — no JSON yet. Replace with a REST-backed implementation later.
class MockListingsRepository implements ListingsRepository {
  static const _towns = <Town>[
    Town('Barnegat Light', LbiRegion.northEnd),
    Town('Harvey Cedars', LbiRegion.northEnd),
    Town('North Beach', LbiRegion.northEnd),
    Town('Surf City', LbiRegion.northEnd),
    Town('Ship Bottom', LbiRegion.southEnd),
    Town('Brant Beach', LbiRegion.southEnd),
    Town('Beach Haven Crest', LbiRegion.southEnd),
    Town('Spray Beach', LbiRegion.southEnd),
    Town('North Beach Haven', LbiRegion.southEnd),
    Town('Beach Haven Gardens', LbiRegion.southEnd),
    Town('Beach Haven Park', LbiRegion.southEnd),
    Town('Beach Haven', LbiRegion.southEnd),
    Town('Haven Beach', LbiRegion.southEnd),
    Town('Holgate', LbiRegion.southEnd),
  ];

  @override
  List<Town> towns() => _towns;

  Town _town(String name) => _towns.firstWhere((t) => t.name == name);

  // ---- Shared amenity taxonomy (from the detail page) ----------------------
  static const _popular = <Amenity>[
    Amenity('Air Conditioning', AmenityGroup.popular, icon: 'ac'),
    Amenity('Heated Pool', AmenityGroup.popular, icon: 'pool'),
    Amenity('WiFi', AmenityGroup.popular, icon: 'wifi'),
    Amenity('Washer / Dryer', AmenityGroup.popular, icon: 'laundry'),
    Amenity('Rooftop Deck', AmenityGroup.popular, icon: 'deck'),
    Amenity('EV Charger (Level 2)', AmenityGroup.popular, icon: 'ev'),
  ];
  static const _indoor = <Amenity>[
    Amenity('Central Air', AmenityGroup.indoor),
    Amenity('Dishwasher', AmenityGroup.indoor),
    Amenity('Coffee Maker', AmenityGroup.indoor),
    Amenity('Keurig', AmenityGroup.indoor),
    Amenity('Microwave', AmenityGroup.indoor),
    Amenity('Ceiling Fans', AmenityGroup.indoor),
    Amenity('Internet', AmenityGroup.indoor),
    Amenity('Pack N Play', AmenityGroup.indoor),
    Amenity('Living Room', AmenityGroup.indoor),
  ];
  static const _outdoor = <Amenity>[
    Amenity('Balcony', AmenityGroup.outdoor),
    Amenity('Grill', AmenityGroup.outdoor),
    Amenity('Outdoor Shower', AmenityGroup.outdoor),
  ];

  List<AvailabilityDay> _availability(DateTime from, {int weeksBooked = 2}) {
    final days = <AvailabilityDay>[];
    for (var i = 0; i < 120; i++) {
      final date = DateTime(from.year, from.month, from.day + i);
      final week = i ~/ 7;
      DayStatus status;
      if (week < weeksBooked) {
        status = DayStatus.notAvailable;
      } else if (week == weeksBooked) {
        status = DayStatus.pending;
      } else {
        status = DayStatus.available;
      }
      days.add(AvailabilityDay(date, status));
    }
    return days;
  }

  // ---- The flagship detail listing (real scrape) ---------------------------
  late final Listing _baysideBeauty = Listing(
    id: '3925',
    title: '**New Rental** Bayside Beauty - Epic Sunset Views!',
    town: _town('Beach Haven Crest'),
    propertyType: PropertyType.house,
    locationType: LocationType.bayside,
    bedrooms: 4,
    fullBaths: 2,
    halfBaths: 0,
    sleeps: 12,
    sqft: 1500,
    weeklyFrom: 7250,
    heroColor: 0xFFE8743B,
    photoCount: 24,
    rating: 0,
    parking: 4,
    keylessEntry: true,
    viewCount: 467,
    badges: ['New Rental', 'EV Charger', 'Rooftop Deck'],
    description:
        'Welcome to West Winifred, a beautiful four bedroom, two bathroom, '
        'single family home that we have lovingly restored with all of the '
        'luxe, modern amenities everyone wants. Winifred is a raised home with '
        'a garage stocked with goodies — beach cart, adult bikes, beach toys '
        'galore, games like Kan Jam and cornhole, boogie boards. Walk through '
        'to the first floor back deck for a dining table near the gas grill, '
        'string lights, and a double-wide outdoor shower. The third-floor '
        'reverse-living space has full water views to Atlantic City from dawn '
        'til sundown, plus two decks. A short walk to the beach across the BLVD '
        'at a traffic light for easy crossing.',
    bedConfig: const [
      BedConfig('Queen', 2),
      BedConfig('Bunk Beds (twin / full)', 2),
      BedConfig('Baby Crib', 1),
    ],
    amenities: const [..._popular, ..._indoor, ..._outdoor],
    rates: [
      RatePeriod(
        label: 'Early Summer',
        start: DateTime(2026, 6, 8),
        end: DateTime(2026, 6, 20),
        nightly: 800,
        weekly: 7250,
        minNights: 3,
      ),
      RatePeriod(
        label: 'Peak Summer',
        start: DateTime(2026, 6, 21),
        end: DateTime(2026, 8, 30),
        weekly: 7250,
        minNights: 7,
        changeoverDay: 'Sun - Sun',
      ),
      RatePeriod(
        label: 'Early Fall',
        start: DateTime(2026, 8, 31),
        end: DateTime(2026, 9, 27),
        nightly: 750,
        minNights: 3,
      ),
    ],
    availability: _availability(DateTime(2026, 6, 1)),
    reviews: const [],
    owner: const Owner(
      name: 'Heidi Raney',
      verified: true,
      listingCount: 3,
      responseTime: 'within a day',
    ),
  );

  // ---- A spread of catalog listings (from the search results scrape) -------
  late final List<Listing> _catalog = [
    _baysideBeauty,
    _make(
      '1',
      'Oceanblock Oasis — Pool, 4 Houses to the Beach',
      'Haven Beach',
      PropertyType.house,
      LocationType.oceanBlock,
      bedrooms: 5,
      full: 5,
      half: 0,
      sleeps: 10,
      from: 15000,
      to: 17000,
      color: 0xFF2E86AB,
      badges: ['Pool', 'Ocean Block'],
      rating: 4.9,
      reviews: 12,
    ),
    _make(
      '2',
      'Newly Built Oceanside — 5BR, Pool',
      'Brant Beach',
      PropertyType.house,
      LocationType.oceanBlock,
      bedrooms: 5,
      full: 3,
      half: 2,
      sleeps: 16,
      from: 4500,
      to: 14000,
      color: 0xFF06A77D,
      badges: ['Pool', 'New Build'],
      rating: 4.8,
      reviews: 9,
    ),
    _make(
      '3',
      'Heated Saltwater Pool — Perfect for Family Shares',
      'Ship Bottom',
      PropertyType.house,
      LocationType.oceanBlock,
      bedrooms: 4,
      full: 3,
      half: 1,
      sleeps: 10,
      from: 6000,
      to: 8950,
      color: 0xFFF4A259,
      badges: ['Heated Pool'],
      rating: 4.7,
      reviews: 21,
    ),
    _make(
      '4',
      'Bayfront Bliss — Sunset Dock',
      'Brant Beach',
      PropertyType.house,
      LocationType.bayfront,
      bedrooms: 4,
      full: 2,
      half: 1,
      sleeps: 10,
      from: 12000,
      color: 0xFF8E7DBE,
      badges: ['Bayfront', 'Dock'],
      rating: 5.0,
      reviews: 6,
    ),
    _make(
      '5',
      'Pet-Friendly Townhouse — \$300 Off Select Weeks',
      'Beach Haven',
      PropertyType.townhouse,
      LocationType.midIsland,
      bedrooms: 3,
      full: 2,
      half: 1,
      sleeps: 8,
      from: 1500,
      to: 5800,
      color: 0xFFE8743B,
      badges: ['Pet Friendly', 'Special Offer'],
      rating: 4.4,
      reviews: 18,
    ),
    _make(
      '6',
      'Panoramic Views — Pool, Elevator & Pet Friendly',
      'Surf City',
      PropertyType.house,
      LocationType.oceanfront,
      bedrooms: 4,
      full: 3,
      half: 0,
      sleeps: 10,
      from: 4900,
      to: 5900,
      color: 0xFF2E86AB,
      badges: ['Pool', 'Elevator', 'Pet Friendly'],
      rating: 4.6,
      reviews: 14,
    ),
    _make(
      '7',
      'Newly Updated Beach Block',
      'Barnegat Light',
      PropertyType.house,
      LocationType.oceanBlock,
      bedrooms: 6,
      full: 4,
      half: 0,
      sleeps: 15,
      from: 4500,
      to: 11000,
      color: 0xFF06A77D,
      badges: ['Beach Block'],
      rating: 4.9,
      reviews: 11,
    ),
    _make(
      '8',
      'Luxury Oceanfront Retreat — Rooftop Pool',
      'Surf City',
      PropertyType.house,
      LocationType.oceanfront,
      bedrooms: 6,
      full: 5,
      half: 1,
      sleeps: 12,
      from: 45000,
      to: 55000,
      color: 0xFF222E50,
      badges: ['Oceanfront', 'Rooftop Pool', 'Luxury'],
      rating: 5.0,
      reviews: 8,
    ),
    _make(
      '9',
      'Cozy & Spacious — Bikes, Toys, Game Room',
      'Brant Beach',
      PropertyType.house,
      LocationType.bayside,
      bedrooms: 4,
      full: 2,
      half: 1,
      sleeps: 10,
      from: 4750,
      to: 6250,
      color: 0xFFF4A259,
      badges: ['Game Room'],
      rating: 4.5,
      reviews: 23,
    ),
    _make(
      '10',
      'Bay Breeze Escape',
      'North Beach',
      PropertyType.house,
      LocationType.bayside,
      bedrooms: 4,
      full: 2,
      half: 0,
      sleeps: 9,
      from: 6000,
      to: 8500,
      color: 0xFF8E7DBE,
      badges: ['Bayside'],
      rating: 4.7,
      reviews: 10,
    ),
    _make(
      '11',
      'Charming Cottage Near the Bay',
      'Beach Haven Park',
      PropertyType.cottage,
      LocationType.midIsland,
      bedrooms: 2,
      full: 1,
      half: 0,
      sleeps: 5,
      from: 1975,
      color: 0xFF06A77D,
      badges: ['Cottage'],
      rating: 4.3,
      reviews: 7,
    ),
    _make(
      '12',
      'Bright Bay Duplex — Walk to Everything',
      'Holgate',
      PropertyType.duplex,
      LocationType.bayside,
      bedrooms: 3,
      full: 2,
      half: 0,
      sleeps: 8,
      from: 1200,
      to: 3950,
      color: 0xFFE8743B,
      badges: ['Duplex'],
      rating: 4.2,
      reviews: 15,
    ),
  ];

  Listing _make(
    String id,
    String title,
    String townName,
    PropertyType type,
    LocationType locationType, {
    required int bedrooms,
    required int full,
    required int half,
    required int sleeps,
    required int from,
    int? to,
    required int color,
    List<String> badges = const [],
    double rating = 0,
    int reviews = 0,
  }) {
    return Listing(
      id: id,
      title: title,
      town: _town(townName),
      propertyType: type,
      locationType: locationType,
      bedrooms: bedrooms,
      fullBaths: full,
      halfBaths: half,
      sleeps: sleeps,
      sqft: 1200 + bedrooms * 250,
      weeklyFrom: from,
      weeklyTo: to,
      heroColor: color,
      photoCount: 12 + (id.hashCode % 20).abs(),
      rating: rating,
      parking: 2 + bedrooms ~/ 2,
      keylessEntry: true,
      petsWelcome: badges.contains('Pet Friendly'),
      viewCount: 120 + (id.hashCode % 400).abs(),
      badges: badges,
      description:
          'A wonderful $townName getaway sleeping $sleeps guests across '
          '$bedrooms bedrooms. Steps from the beach with everything you need '
          'for a classic Long Beach Island summer.',
      bedConfig: [
        BedConfig('Queen', bedrooms ~/ 2),
        BedConfig('Twin', bedrooms - bedrooms ~/ 2),
      ],
      amenities: const [..._popular, ..._indoor, ..._outdoor],
      rates: [
        RatePeriod(
          label: 'Summer',
          start: DateTime(2026, 6, 21),
          end: DateTime(2026, 8, 30),
          weekly: from,
          minNights: 7,
          changeoverDay: 'Sat - Sat',
        ),
      ],
      availability: _availability(
        DateTime(2026, 6, 1),
        weeksBooked: 1 + (id.hashCode % 4).abs(),
      ),
      reviews: List.generate(
        reviews.clamp(0, 3),
        (i) => Review(
          author: ['The Murphys', 'D. Chen', 'Sarah & Mike'][i % 3],
          rating: rating == 0 ? 5 : rating,
          date: DateTime(2025, 8 - i, 14),
          body:
              'Fantastic week in $townName — the house was spotless and '
              'exactly as pictured. We will be back next summer!',
        ),
      ),
      owner: Owner(
        name: [
          'Heidi Raney',
          'Coastal Stays LLC',
          'Mark Delaney',
        ][id.hashCode.abs() % 3],
        verified: true,
        listingCount: 2 + id.hashCode.abs() % 5,
        responseTime: 'within a few hours',
      ),
    );
  }

  Future<T> _delayed<T>(T value) =>
      Future.delayed(const Duration(milliseconds: 350), () => value);

  @override
  Future<List<Listing>> fetchAll() => _delayed(_catalog);

  @override
  Future<List<Listing>> fetchFeatured() => _delayed(_catalog.take(8).toList());

  @override
  Future<Listing?> byId(String id) =>
      _delayed(_catalog.where((l) => l.id == id).firstOrNull);

  @override
  Future<List<Listing>> byOwner(String ownerName, {String? excludeId}) =>
      _delayed(
        _catalog
            .where((l) => l.owner.name == ownerName && l.id != excludeId)
            .toList(),
      );

  @override
  Future<List<Listing>> search(ListingQuery q) {
    var results = _catalog.where((l) {
      if (q.text != null && q.text!.trim().isNotEmpty) {
        final t = q.text!.toLowerCase();
        if (!l.title.toLowerCase().contains(t) &&
            !l.town.name.toLowerCase().contains(t)) {
          return false;
        }
      }
      if (q.region != null && l.town.region != q.region) return false;
      if (q.town != null && l.town.name != q.town!.name) return false;
      if (q.propertyTypes.isNotEmpty &&
          !q.propertyTypes.contains(l.propertyType)) {
        return false;
      }
      if (q.locationTypes.isNotEmpty &&
          !q.locationTypes.contains(l.locationType)) {
        return false;
      }
      if (q.minBedrooms != null && l.bedrooms < q.minBedrooms!) return false;
      if (q.minSleeps != null && l.sleeps < q.minSleeps!) return false;
      if (q.maxWeekly != null && l.weeklyFrom > q.maxWeekly!) return false;
      if (q.amenities.isNotEmpty) {
        final labels = l.amenities.map((a) => a.label).toSet();
        if (!q.amenities.every(labels.contains)) return false;
      }
      return true;
    }).toList();
    return _delayed(results);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
