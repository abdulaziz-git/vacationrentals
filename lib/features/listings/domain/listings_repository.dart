import 'listing.dart';

/// Abstract data-access boundary for the catalog. The presentation layer talks
/// only to this interface; the concrete implementation (mock today, REST later)
/// lives in the data layer.
abstract class ListingsRepository {
  Future<List<Listing>> fetchFeatured();
  Future<List<Listing>> fetchAll();
  Future<List<Listing>> search(ListingQuery query);
  Future<Listing?> byId(String id);
  Future<List<Listing>> byOwner(String ownerName, {String? excludeId});
  List<Town> towns();
}

/// Search / filter parameters assembled by the search feature.
class ListingQuery {
  const ListingQuery({
    this.text,
    this.region,
    this.town,
    this.propertyTypes = const {},
    this.locationTypes = const {},
    this.minBedrooms,
    this.minSleeps,
    this.maxWeekly,
    this.amenities = const {},
    this.checkIn,
    this.checkOut,
  });

  final String? text;
  final LbiRegion? region;
  final Town? town;
  final Set<PropertyType> propertyTypes;
  final Set<LocationType> locationTypes;
  final int? minBedrooms;
  final int? minSleeps;
  final int? maxWeekly;
  final Set<String> amenities;
  final DateTime? checkIn;
  final DateTime? checkOut;

  ListingQuery copyWith({
    String? text,
    LbiRegion? region,
    bool clearRegion = false,
    Town? town,
    bool clearTown = false,
    Set<PropertyType>? propertyTypes,
    Set<LocationType>? locationTypes,
    int? minBedrooms,
    bool clearMinBedrooms = false,
    int? minSleeps,
    bool clearMinSleeps = false,
    int? maxWeekly,
    bool clearMaxWeekly = false,
    Set<String>? amenities,
    DateTime? checkIn,
    DateTime? checkOut,
    bool clearDates = false,
  }) {
    return ListingQuery(
      text: text ?? this.text,
      region: clearRegion ? null : (region ?? this.region),
      town: clearTown ? null : (town ?? this.town),
      propertyTypes: propertyTypes ?? this.propertyTypes,
      locationTypes: locationTypes ?? this.locationTypes,
      minBedrooms: clearMinBedrooms ? null : (minBedrooms ?? this.minBedrooms),
      minSleeps: clearMinSleeps ? null : (minSleeps ?? this.minSleeps),
      maxWeekly: clearMaxWeekly ? null : (maxWeekly ?? this.maxWeekly),
      amenities: amenities ?? this.amenities,
      checkIn: clearDates ? null : (checkIn ?? this.checkIn),
      checkOut: clearDates ? null : (checkOut ?? this.checkOut),
    );
  }

  int get activeFilterCount {
    var n = 0;
    if (region != null) n++;
    if (town != null) n++;
    if (propertyTypes.isNotEmpty) n++;
    if (locationTypes.isNotEmpty) n++;
    if (minBedrooms != null) n++;
    if (minSleeps != null) n++;
    if (maxWeekly != null) n++;
    if (amenities.isNotEmpty) n++;
    if (checkIn != null) n++;
    return n;
  }
}
