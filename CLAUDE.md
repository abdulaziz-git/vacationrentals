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

## 7. UI / Design System Ledger
Brand palette = live VRLBI site: `AppTheme.ocean` brand blue `#0081ff`,
`AppTheme.deepSea` navy `#073855` (text/headings + "Maps" pill),
`AppTheme.sun`/`sunset` yellow `#FFDC00`/`#FFC400` (stars, accents),
`AppTheme.heart` `#F5463B` (favorites), `seafoam` sky-blue, `tint` pale-blue
chips, `canvas` `#F4F7FB` background. **Flat solid fills only — no gradients.**
Component themes: pill (StadiumBorder) filled/outlined buttons, 24px rounded
cards, 18px rounded inputs, stadium chips with explicit dark labels
(`labelStyle`/`secondaryLabelStyle` set so chip text is never invisible).

Shared catalog widgets (`core/widgets/listing_card.dart`):
* `ListingCard` (wide), `ListingCardCompact` (carousel) — original.
* `ListingListRow` — search/Lists row: rounded thumbnail + overlaid rating
  pill + Verified badge + weekly price.
* `ListingGridCard` — 2-col grid card (home featured / saved): photo + fav
  toggle + title + blurb + price.
`PhotoPlaceholder` takes an optional `width` (solid per-listing tint block).

Layout patterns (reference-driven):
* Bottom nav (`scaffold_with_nav.dart`): floating rounded white bar, active
  tab expands into a brand-blue pill with label; `extendBody: true`.
* Home: solid-blue hero bleeds under the status bar (no top SafeArea; hero
  pads by `MediaQuery.padding.top`), location pill, 2-col featured grid.
* Search: quick-filter chip row (All resets · Type/Region/Price open sheet).
* Detail: owner row + dark "Maps" pill, see-more description, `_Accordion`
  (ExpansionTile) sections, sticky "Book Now" bar with chat circle button.
* Filter sheet: selectable property-type cards (`_RoomCard`) + chips.
* Auth: `AuthScaffold` solid-blue header + white sheet running to the bottom
  edge (`SafeArea(bottom:false)`, scroll padded by bottom inset). Sheet is a
  `Material` so `ListTile`/`SwitchListTile` children render ink correctly.