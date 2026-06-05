# PROJECT CONTEXT & ARCHITECTURE LEDGER

## 1. Project Identity & GitHub Linkage
* **Project Name:** Vacation Rentals
* **Repository:** github.com/abdulaziz-git/vacationrentals
* **Active GitHub Project URL:** github.com/abdulaziz-git/projects/5
* **Target Platforms:** iOS (Primary Focus MVP), Android (Future-ready).

## 2. Environment & MCP Targeting
To prevent hallucinations, Context7 MCP MUST use these exact versions:
* **Language Runtime:** Dart 3.x
* **Core Framework:** Flutter 3.x (Stable)
* **UI/Styling:** Material 3 (Use adaptive widgets where idiomatic).
* **State Management:** Riverpod 2.x (using riverpod_generator).
* **Routing:** GoRouter.
* **Data Modeling:** Freezed & JsonSerializable.

## 3. Automation & Verification Commands
Execute these exact terminal commands for local verification:
* **Run App (iOS Simulator):** `flutter run -d ios`
* **Run Test Suite:** `flutter test`
* **Run Linter/Formatter:** `dart format . && flutter analyze`
* **Code Generation:** `dart run build_runner build -d`
* **Graphify Re-index:** `graphify index .`

## 4. Architectural Boundaries (Feature-First)
Strictly enforce a **Feature-Driven** Clean Architecture inside the `lib/` directory:
* `lib/features/[feature_name]/`
  * `presentation/` - UI, Widgets, and Riverpod Controllers. **Must** handle Riverpod `AsyncValue` (loading, error, data) to satisfy Global UI/UX rules.
  * `domain/` - Plain Dart entities and abstract repository interfaces. No Flutter imports here.
  * `data/` - API clients, local storage, DTOs, and concrete repository implementations.
* `lib/core/` - Global routing (GoRouter), theme definitions, and base network clients.

## 5. Active Data & State Ledger
[Agent Instruction: Update this block automatically when executing schema/model changes]
* `User` domain entity: id (String), email (String), displayName (String)
* **Catalog domain** (`features/listings/domain/listing.dart`):
  * `Listing`: id, title, town, propertyType, locationType, bedrooms, fullBaths,
    halfBaths, sleeps, sqft, weeklyFrom/To, photoCount, description, bedConfig[],
    amenities[], rates[], availability[], reviews[], owner, rating, parking,
    keylessEntry, pets/smoking/wheelchair flags, badges[], viewCount.
  * Supporting: `Town`, `LbiRegion`, `PropertyType`, `LocationType`, `Amenity`
    (+`AmenityGroup`), `RatePeriod`, `AvailabilityDay` (+`DayStatus`), `Review`,
    `Owner`, `BedConfig`.
* **Booking domain** (`features/booking/domain/booking.dart`):
  * `Booking`: id, listingId, dates, guests, weeklyRate, travelInsurance,
    `BookingStatus`; computed nights/weeks/rentalCost/taxes/total/depositDue.
* `ListingsRepository` (abstract) + `ListingQuery`; concrete
  `MockListingsRepository` seeded from the VRLBI scrape. **TODO:** REST impl.
  No JSON/Freezed yet — mock returns Dart objects directly.

## 5b. NOTE — codegen deviation (mockup phase)
Riverpod is used WITHOUT `riverpod_generator`, and entities are plain immutable
Dart classes (NOT Freezed/JsonSerializable) so the mock build runs with no
`build_runner` step. This is a deliberate, drop-in-reversible choice for the
screen-mockup phase. Re-introduce Freezed + riverpod_generator + json_serializable
when wiring the real API/DTO layer.

## 6. Screen / Route Ledger (GoRouter)
StatefulShellRoute bottom-nav tabs: `/home`, `/search`, `/saved`, `/trips`,
`/account`. Root-pushed routes: `/listing/:id`, `/listing/:id/photos`,
`/listing/:id/review`, `/listing/:id/quote`, `/booking/:id/confirmed`,
`/owner/:name`, `/login`, `/signup`.
Verification hook: `--dart-define=START_ROUTE=/<path>` deep-links the app to a
single screen on boot (used for simulator screenshots); defaults to `/home`.