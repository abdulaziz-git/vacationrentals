# VRLBI Vacation Rentals — Apple / iOS Compliance Audit

**App:** Vacation Rentals (VRLBI — Long Beach Island)
**Platform audited:** iOS (primary), with notes on shared Flutter/Dart code
**Stack:** Flutter 3.x · Dart 3.12 · Material 3 · Riverpod 2.x (plain providers) · GoRouter · intl 0.20
**Audit date:** 2026-06-06
**Project phase:** **Mockup / prototype** (mock data layer, no live backend, UI-only auth)

> **Methodology.** This audit was produced by 8 parallel domain reviewers (App Store policy, HIG/UX, iOS native config, accessibility, Flutter architecture, privacy/security, adaptivity, i18n) whose ~72 findings were each put through an **adversarial verifier** that re-opened the cited code to confirm the claim is true, that the cited Apple guideline numbers are real (not hallucinated), and that severity is fair **for a mockup**. A completeness critic then hunted for missed areas. Every "blocker"/"high" and every newly-surfaced issue in this report was additionally re-checked by hand against the source. Severities below are the **verifier-adjusted** values (mockup-aware). Where the verifier refuted or corrected a finding, that is stated honestly.

---

## 1. Honest verdict

**This is a well-architected, good-looking mockup — and it is not submittable to the App Store today. That is expected and fine for this phase.** Nothing here is alarming; the gap between "polished prototype" and "ships through Apple review" is a known, mostly-mechanical checklist plus a real accessibility/adaptivity investment.

What's genuinely strong:

- **Clean architecture.** Feature-first layout, pure-Dart domain entities with zero Flutter imports, an abstract repository boundary with a swappable mock impl injected via a provider. Honors the project's own `CLAUDE.md` rules.
- **Four-state UX done right.** Loading (shimmer skeletons that mirror real cards), error (with retry), empty (actionable copy), and data are handled consistently via Riverpod `AsyncValue` on home, search, detail, and quote. This is the single best thing in the codebase.
- **Security hygiene.** No hardcoded secrets/keys/endpoints anywhere, no tracking/ads/analytics SDKs, App Transport Security left strict (no HTTP exceptions), passwords obscured. The booking flow correctly treats rentals as **real-world services** (In-App Purchase is *not* required — see §4.1).
- **Safe areas.** Sticky bottom bars and the floating nav correctly pad by the bottom inset; the home hero's under-status-bar bleed is intentional and handled.

The honest weaknesses, in priority order:

1. **Submission prerequisites are entirely absent** (expected for a mockup): placeholder `com.example.*` bundle id, no privacy manifest, no encryption-compliance key, no in-app account deletion, no real privacy-policy/terms link, no `.entitlements` file at all.
2. **iPad adaptivity is missing** while the build ships as a *universal* app — a known iPad-stretch rejection vector.
3. **Accessibility is the weakest dimension** — icon-only buttons without labels, a calendar that conveys availability by colour alone, sub-44pt touch targets, low-contrast yellow stars, and no Dynamic Type accommodation.
4. **A handful of real present-day bugs**, chiefly a **"Maps" pill that opens the owner profile instead of a map**, and several dead controls (share, notifications, Forgot password).

---

## 2. How to read this report

Every finding is tagged with a **bucket** so you can tell a prototype-expected gap from a real defect:

| Bucket | Meaning |
|---|---|
| 🟡 `expected-for-mockup` | Normal for a prototype. Only matters before a real submission. Do **not** treat as a bug. |
| 🔴 `blocks-submission` | Will cause App Store rejection or upload failure if shipped as-is. Must become true before review. |
| 🟠 `present-issue` | A real code / UX / accessibility defect that exists **right now** and is worth fixing regardless of phase. |

**Severity** (verifier-adjusted, mockup-aware): `blocker` > `high` > `medium` > `low` > `info`.

---

## 3. Scorecard

| Dimension | Verdict for a mockup | Highest live severity | Must-fix-before-submit items |
|---|---|---|---|
| App Store policy & readiness | Solid bones; many submission gates open | `blocker` (mock data) | Bundle id, account deletion, privacy policy, real data/auth |
| Human Interface Guidelines (UX) | Strong states; platform-fit gaps | `medium` | Dark Mode, status-bar style, touch targets |
| iOS native config & build | Clean modern scaffold, defaults unedited | `blocker` (bundle id) | Bundle id, privacy manifest, encryption key |
| **Accessibility** | **Weakest area** | `medium` (×several) | Icon labels, colour-only calendar, contrast, Dynamic Type |
| Flutter architecture & code | Genuinely good | `medium` (god-file) | None (quality only) |
| Privacy manifest & security | Clean; prod gaps only | `medium` | Privacy manifest, encryption key |
| **Adaptivity / iPad** | iPhone good; **iPad unhandled** | `high` (iPad) | iPad decision (lock or adapt) |
| Localization / i18n | English-only by design | `low` | None (scope choice) |
| Platform integration (entitlements) | No entitlements at all | `medium` | SIWA entitlement, "Maps" bug |

---

## 4. Detailed findings

> Evidence is given as `path:line`. Severities are mockup-aware. "↓ from X" means the verifier downgraded the original reviewer's severity because the issue is prototype-expected.

### 4.1 App Store Review Guidelines & submission readiness

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| ASR-1 | **Entirely mock data, UI-only auth, dead buttons** — the single biggest gate to review. Login/Signup just `context.pop()`; data is hardcoded with a 350 ms fake delay; many controls are no-ops. | `blocker` | 🟡 | `mock_listings_repository.dart:6`; `login_screen.dart:63`; `account_screen.dart:140` (every row `onTap: () {}`) — Guideline **2.1** |
| ASR-2 | **No in-app Account Deletion** despite offering account creation (Sign up + "Continue with Apple"). Apple has required an in-app delete path since June 2022. Also no Sign-out. | `high` | 🔴 | `account_screen.dart:74-93` (no delete/sign-out row); repo grep finds none — Guideline **5.1.1(v)** |
| ASR-3 | **No Privacy Policy / Terms link.** Signup's "I agree to the Terms & Privacy Policy" is **plain text, not tappable**; `url_launcher` isn't even a dependency. | `medium` ↓ | 🔴 | `signup_screen.dart:74` (plain `Text` inside `CheckboxListTile`) — Guideline **5.1.1 / 5.1.2** |
| ASR-4 | **Minimum-functionality risk (4.2).** As a read-only catalog over static data with no live inventory/booking backend, a submitted build risks being flagged as a thin web-repackage. (Clear native value once data is wired.) | `medium` | 🔴 | `pubspec.yaml` (no network client); `quote_screen.dart:209` (local-only) — Guideline **4.2** |
| ASR-5 | **Submission metadata gates** (process, not code): reviewer demo account once auth gates content, Support URL, age-rating questionnaire, screenshots, App Privacy "nutrition label." None wired (correct for now). | `low` ↓ | 🔴 | App Store Connect side; `account_screen.dart:97` commits a real business address |
| ASR-6 ✅ | **Bookings are real-world services → IAP correctly NOT required.** Stated explicitly so it is not mis-flagged: the 50% deposit / totals are physical-service payments (3.1.3(e)), not digital goods. Use Apple Pay / hosted checkout later — never StoreKit. | `info` | — | `quote_screen.dart:12-15`; `booking_confirmation_screen.dart:74` — Guideline **3.1.3(e)** |
| ASR-7 ✅ | **No-login browse path exists** (catalog + Account usable signed-out) and **Sign in with Apple is offered with no competing 3rd-party social login**, so the 4.8 SIWA-mandate is not triggered. Both are positives. (But the button is a dead no-op — see PLT-1.) | `info` | — | `login_screen.dart:78-82`; `account_screen.dart` signed-out — Guideline **4.8** |

*(Bundle id, encryption key, launch screen, and name mismatch are submission items too; they're owned by §4.3 to avoid duplication.)*

### 4.2 Human Interface Guidelines — UI/UX & platform fit

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| HIG-1 | **No Dark Mode.** Only `AppTheme.light()`; `MaterialApp` declares no `darkTheme`/`themeMode`. Dark-mode users get a permanently light app. HIG treats Dark Mode as expected. | `medium` ↓ | 🟠 | `main.dart:19`; `app_theme.dart:40-48` — HIG: Dark Mode |
| HIG-2 | **No status-bar overlay style** for the solid-blue hero that bleeds under the status bar → risk of dark glyphs on blue (low contrast), not reset when scrolling away. | `medium` ↓ | 🟠 | `home_screen.dart:22-23,97-100`; no `SystemUiOverlayStyle`/`AnnotatedRegion` anywhere — HIG: Status bars |
| HIG-3 | **Touch targets below 44pt.** Favorite heart ≈34pt, detail back/share/favorite circles ≈36pt (they're hand-built `Material+InkWell`, not `IconButton`, so they miss the 48dp floor). | `medium` ↓ | 🟠 | `listing_card.dart:519-543`; `listing_detail_screen.dart:301-314` — HIG: 44×44pt. *(Verifier note: the reviewer also cited `_MetaChips` — those are **decorative, non-interactive**, so disregard that one example.)* |
| HIG-4 | **No haptics anywhere** (favorite, tab switch, filter apply, booking submit all fire silently). | `low` ↓ | 🟠 | grep: no `HapticFeedback` in `lib/` — HIG: Playing haptics |
| HIG-5 | **No confirmation/undo on committing actions** — booking submits on one tap; un-favorite is instant with no undo. | `low` ↓ | 🟠 | `quote_screen.dart:209-212`; `listing_card.dart:467-468` — HIG: Confirming actions |
| HIG-6 | **Material calendar `showDatePicker` on an iOS-primary app** (project rules ask for adaptive widgets). A check-in/out flow would also benefit from a **date-range** picker. | `low` ↓ | 🟠 | `quote_screen.dart:190` — HIG: Pickers |
| HIG-7 | **Custom floating "pill" tab bar** is an allowed Flutter choice (and has good `Semantics`), but inactive tabs hide their labels, reducing discoverability vs the icon+label convention. | `low` | 🟠 | `scaffold_with_nav.dart:23-60,105-115` — HIG: Tab bars |
| HIG-8 ✅ | **Strong, consistent four-state coverage + safe-area-aware bars.** Genuinely good; preserve this pattern as real data lands, and extend it to Saved/Trips. | `info` | — | `async_states.dart`; `home_screen.dart:37-75`; `search_screen.dart:98-136` |

### 4.3 iOS native configuration & build settings

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| IOS-1 | **Placeholder bundle id `com.example.vacationrentals`.** Apple's reserved example prefix cannot be registered as an App ID — blocks the *first* upload, not just review. | `blocker` | 🟡 | `project.pbxproj:386,566,589` — App ID registration. *(Reviewer cited "ASRG 4.3" — that's the spam clause; the real constraint is App Store Connect App-ID registration, not a numbered review guideline.)* |
| IOS-2 | **Missing `ITSAppUsesNonExemptEncryption`.** Every TestFlight/App Store upload will prompt for export-compliance until set. HTTPS-only apps declare `<false/>`. | `medium` ↓ | 🔴 | `Info.plist` (key absent) |
| IOS-3 | **No `PrivacyInfo.xcprivacy` privacy manifest** anywhere in `ios/`. Apple has required one for submissions since 2024 (declares collected data + required-reason APIs). | `high` | 🔴 | `find ios -iname "*.xcprivacy"` → none (only the engine's own copy under `build/`) |
| IOS-4 | **Three inconsistent app names:** `CFBundleDisplayName` "Vacationrentals", `CFBundleName` "vacationrentals", in-app title "VRLBI — Vacation Rentals LBI". The home-screen name is unbranded/lowercased. | `low` ↓ | 🟠 | `Info.plist:10,18`; `main.dart:17` |
| IOS-5 | **Unbranded default Flutter launch screen** (tiny `LaunchImage` on white → blank flash). Reads as unfinished. | `low` ↓ | 🟡 | `LaunchScreen.storyboard:19,22`; `LaunchImage` PNGs are 1×1 placeholders |
| IOS-6 | **Universal target + landscape + iPad-upside-down enabled on a portrait-only UI** (see also §4.7). Either lock orientation or genuinely support it. | `low` ↓ | 🟠 | `Info.plist:56-68`; `TARGETED_DEVICE_FAMILY = "1,2"` |
| IOS-7 | **Legacy `CODE_SIGN_IDENTITY = "iPhone Developer"`** string (now "Apple Development/Distribution"); confirm Release/archive signs with a *distribution* identity. | `low` | 🟡 | `project.pbxproj:349,470,527` |
| IOS-8 | `IPHONEOS_DEPLOYMENT_TARGET = 13.0` (fine), `LSApplicationCategoryType` unset (set Travel in ASC), `UIRequiredDeviceCapabilities` absent (harmless). | `info` | 🟡 | `project.pbxproj:363,490,541`; `Info.plist` |
| IOS-9 ✅ | **Modern, clean scaffold:** new `FlutterAppDelegate`+`SceneDelegate`+Swift Package Manager (no legacy Podfile), `ENABLE_BITCODE = NO` (correct), full AppIcon set incl. a 1024px marketing icon **with no alpha** (won't trip transparency rejection), real `DEVELOPMENT_TEAM` set. | `info` | — | `project.pbxproj`; `AppIcon.appiconset` |

### 4.4 Accessibility — the weakest dimension

> Only **one** thoughtful `Semantics` usage exists in the whole app (the bottom-nav items, `scaffold_with_nav.dart:80`). Standard Material widgets carry default semantics, but custom controls and imagery do not.

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| A11Y-1 | **Icon-only buttons have no VoiceOver label/tooltip** — back, share, favorite, the notifications bell, and guest +/- steppers. The custom circle buttons aren't even `IconButton`, so VoiceOver announces a bare "button." | `medium` ↓ | 🟠 | `home_screen.dart:132-135`; `listing_detail_screen.dart:295-316,990-1010`; `quote_screen.dart:102-114` — HIG: VoiceOver labels |
| A11Y-2 | **Availability calendar conveys status by colour alone** (available/pending/booked are faint tints; VoiceOver reads just the day number). A guest with low vision / CVD can't tell bookable from booked. | `medium` ↓ | 🟠 | `availability_calendar.dart:147-195` — WCAG 1.4.1 / HIG: Don't rely on colour alone |
| A11Y-3 | **No Dynamic Type accommodation.** ~118 inline `fontSize:` literals, zero `textTheme` usage outside the theme, and text sits in fixed-height rows (`height:38`, `height:108`) → clipping/overflow at large accessibility sizes. (Flutter *does* scale text by default; the risk is layout breakage.) | `medium` ↓ | 🟠 | `app_theme.dart`; `search_screen.dart:267`; `home_screen.dart:250` — HIG: Dynamic Type |
| A11Y-4 | **Image placeholders neither labeled nor handled.** `Image.asset` has no `semanticLabel`, so hero photos are invisible to VoiceOver. | `medium` | 🟠 | `photo_placeholder.dart:43-49` — WCAG 1.1.1. *(Verifier note: the decorative camera glyph emits no semantics node today, so only the missing image label is the real gap.)* |
| A11Y-5 | **Rating stars expose no value.** A `Row` of 5 bare icons; VoiceOver hears nothing (and in the per-review list there's no adjacent number to compensate). | `medium` | 🟠 | `rating_stars.dart:13-27`; `listing_detail_screen.dart:620` |
| A11Y-6 | **Touch targets <44pt** (same controls as HIG-3, from the a11y/motor-impairment angle). | `medium` | 🟠 | `listing_card.dart:519-543`; `listing_detail_screen.dart:301-314` |
| A11Y-7 | **Low-contrast colours.** Yellow stars `#FFDC00` on white ≈ **1.36:1** (needs 3:1) — the strongest point; brand-blue 12.5px link text ≈ 3.76:1 and grey-400/500 hint text fail the 4.5:1 small-text bar. | `medium` | 🟠 | `app_theme.dart:23`; `rating_stars.dart:25`; `quote_screen.dart:300` — WCAG AA. *(Verifier corrected one claim: the grey-600 town label ≈4.61:1 actually **passes**.)* |
| A11Y-8 | **Shimmer ignores Reduce Motion** (repeats unconditionally; no `disableAnimations` check); skeletons aren't announced as a single "Loading" live region. | `low` ↓ | 🟠 | `async_states.dart:106-109` |
| A11Y-9 | Cards aren't grouped into one semantic node (VoiceOver swipes through every child); loading/error transitions aren't `liveRegion`-announced. | `low` | 🟠 | `listing_card.dart:21`; `search_screen.dart:99-103` |

### 4.5 Flutter / Dart architecture & code quality

*(All quality issues — none block submission. The verifier downgraded most to `low` given the deliberate mock phase.)*

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| ARCH-1 | **`listing_detail_screen.dart` is a 1040-line god-file** (~17 widget classes + widget-returning helper methods `_bedChip`/`_circleButton` that defeat const/rebuild isolation). | `medium` | 🟠 | `listing_detail_screen.dart:275,295` — split into `widgets/` like the calendar/rates already are |
| ARCH-2 | **No `autoDispose` on any provider** — family providers (`listingByIdProvider`, `ownerListingsProvider`) cache per-key state forever and never re-fetch on revisit (matters once REST data changes). | `low` ↓ | 🟠 | `listings_providers.dart:24,29`; grep: zero `autoDispose` |
| ARCH-3 | **`main()` has no error boundary / `ProviderObserver` / `SystemChrome` setup** (no `FlutterError.onError`, `PlatformDispatcher.onError`, `WidgetsFlutterBinding.ensureInitialized`). | `low` ↓ | 🟠 | `main.dart:7-9` |
| ARCH-4 | **`Format.money` hand-rolls `$` + comma grouping**, ignoring locale, though `intl`'s `NumberFormat.currency` is already a dependency (and mis-groups negatives). | `low` ↓ | 🟠 | `app_theme.dart:145-153` (used at 21 sites) |
| ARCH-5 | **Bare `flutter_lints`** — no `strict-casts`/`strict-inference`/`strict-raw-types`, despite the ledger mandating strict typing (the holes that bite when a JSON/DTO layer lands). | `low` | 🟠 | `analysis_options.yaml:10` |
| ARCH-6 | **Error UI exists but is unreachable** — the mock never throws, so the retry/error branches and `ref.invalidate` paths are untested (only one smoke test exists). | `low` | 🟡 | `mock_listings_repository.dart:462`; `home_screen.dart:43` |
| ARCH-7 | Minor: private `firstOrNull` extension shadows the SDK's; `Listing.withPhotos` re-lists all 23 fields by hand (copyWith footgun); `_DetailBody` watches the whole favorites `Set` (over-broad rebuild). | `low` | 🟠 | `mock_listings_repository.dart:516`; `listing.dart:205`; `listing_detail_screen.dart:62` |
| ARCH ✅ | **Positives:** pure domain layer (no Flutter imports), clean repository boundary, all `TextEditingController`/`AnimationController` correctly disposed, lists use `ListView.builder`/`SliverGrid`. | `info` | — | — |

### 4.6 Privacy manifest, data handling & security

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| PRIV-1 | **No privacy manifest** (`PrivacyInfo.xcprivacy`) — see IOS-3. Mandatory at submission. | `medium` ↓ | 🔴 | `find ios -iname "*.xcprivacy"` → none |
| PRIV-2 | **No `ITSAppUsesNonExemptEncryption`** — see IOS-2. | `medium` ↓ | 🔴 | `Info.plist` |
| PRIV-3 | **No autofill hints** on email/password fields → iOS can't offer Keychain AutoFill or strong-password suggestions; email field keeps autocorrect on. Real present UX/security defect. | `low` | 🟠 | `login_screen.dart:33-53`; `signup_screen.dart:36-65` — wrap in `AutofillGroup`, add `autofillHints` + `autocorrect:false` |
| PRIV-4 | **No secure-storage/Keychain dependency** for future tokens (fine now — auth goes nowhere; design it in before wiring real auth). | `low` ↓ | 🟡 | `pubspec.yaml` |
| PRIV-5 | **Production payment note:** never capture card data in-app (PCI). Use Apple Pay / Stripe PaymentSheet / hosted checkout for the deposit. | `info` | 🟡 | `quote_screen.dart:209-212` |
| PRIV ✅ | **Positives:** zero hardcoded secrets/keys/endpoints (no URLs at all), no tracking/ads SDKs, **ATS left strict** (no HTTP exceptions — keep it), no real PII in mock seed data. | `info` | — | grep clean; `Info.plist` (no `NSAppTransportSecurity`) |

### 4.7 Adaptivity, responsiveness, iPad & safe areas

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| ADP-1 | **Universal app (iPad enabled) with zero adaptive layout.** No `LayoutBuilder`, no width-based `MediaQuery`, no max-content-width — only hardcoded `crossAxisCount: 2/3`. On iPad / landscape, 2-column grids and the hero stretch to absurd widths. A classic iPad-stretch rejection vector. **Fast fix: `TARGETED_DEVICE_FAMILY = 1` (iPhone-only)**; proper fix: derive columns from width + clamp content width. | `high` | 🔴 | `project.pbxproj:367,494,547`; `home_screen.dart:64`; `filters_sheet.dart:134`; `listing_detail_screen.dart:380` — Guideline 2.4.1 |
| ADP-2 | **Floating nav occludes the last item.** With `extendBody: true`, the home `CustomScrollView` ends with only a 24pt spacer (search ends at 16pt), so the last "Browse by Area" card sits under the ~46pt+inset floating pill. | `medium` | 🟠 | `scaffold_with_nav.dart:24`; `home_screen.dart:77`; `search_screen.dart:130` — pad ~96pt at bottom |
| ADP-3 | Detail hero fixed at `expandedHeight: 280` and a 4-up spec `Row` assume portrait width → sparse/crowded off-portrait. Filter sheet locked at `FractionallySizedBox(0.9)` is cramped in landscape / oversized on iPad. | `low` | 🟠 | `listing_detail_screen.dart:66,337`; `filters_sheet.dart:21` |
| ADP-4 ✅ | **Excellent iPhone safe-area handling** — bottom bars pad by `MediaQuery.padding.bottom`, hero bleeds intentionally, nav wrapped in `SafeArea`, sheets use `isScrollControlled` + bottom-inset padding. | `info` | — | `quote_screen.dart:444`; `auth_scaffold.dart:81` |
| ~~ADP-X~~ | **REFUTED — not an issue.** A reviewer flagged keyboard-field occlusion in the quote form; the verifier confirmed the quote form has **no text fields** (dates use a picker, guests use steppers), and the auth/review forms put their buttons **inside** the scroll body, so the claimed risky pattern doesn't exist. Listed here for transparency. | — | — | `quote_screen.dart`; `write_review_screen.dart:95`; `auth_scaffold.dart` |

### 4.8 Localization & internationalization

> English-only, single-market (LBI/USD) is a **defensible scope choice** for this app. These are forward-looking, mostly `low`.

| # | Finding | Severity | Bucket | Evidence |
|---|---|---|---|---|
| L10N-1 | **No `flutter_localizations` / `localizationsDelegates` / `supportedLocales`.** Built-in widgets (date picker, selection menus) can't localize; device locale isn't propagated to `intl`. | `low` ↓ | 🟠 | `main.dart:16-21`; `pubspec.yaml` |
| L10N-2 | `Format.money` ignores locale (same as ARCH-4); `DateFormat` constructed without an explicit locale (falls back to `en_US`). | `low` | 🟠 | `app_theme.dart:145`; `quote_screen.dart:56` |
| L10N-3 | All user-facing strings hardcoded inline (incl. manual `guest`/`guests` pluralization); no ARB/`gen-l10n`. A few physical `EdgeInsets.only(left/right)` instead of directional `.start/.end` (minor RTL exposure). | `low` | 🟡 | pervasive; `home_screen.dart:308` etc. |
| L10N-4 ✅ | Good: `intl` **is** used correctly for dates in 4 places; US units (sqft/baths) are correct for an LBI-only product. | `info` | — | `quote_screen.dart`, `rates_table.dart` |

### 4.9 Platform integration & entitlements (completeness-critic — verified by hand)

> **There is no `.entitlements` file anywhere in `ios/`, and no `SystemCapabilities` in the Xcode project.** Several UI affordances promise capabilities that have no native backing. *(These were not run through the adversarial pass; I re-checked each one directly against the source.)*

| # | Finding | Severity | Bucket | Evidence (verified) |
|---|---|---|---|---|
| PLT-1 | **"Continue with Apple" is a dead no-op AND there's no SIWA entitlement.** The button can't be implemented without the `com.apple.developer.applesignin` capability, which is entirely absent. Becomes a submission blocker the moment auth is wired. | `medium` | 🟡 | `login_screen.dart:78-82` (`onPressed: () {}`); no `applesignin` in `project.pbxproj`; no `.entitlements` |
| PLT-2 | **🐛 The "Maps" pill opens the owner profile, not a map.** A dark pill with a map icon + "Maps" label navigates to `/owner/:name`. This is a real present-day functional/labeling bug — and there's no MapKit/`NSLocationWhenInUseUsageDescription`/location entitlement for the core map tab (which is a fake `CustomPaint`). | `medium` | 🟠 | `listing_detail_screen.dart:695` → `context.push('/owner/...')` under `Icons.map_outlined` + `'Maps'` at `:701-704` |
| PLT-3 | **No GoRouter `errorBuilder`/`onException`** — an unknown route or malformed deep link (the app documents a `START_ROUTE` deep-link hook) drops to the raw red error screen instead of a graceful "not found." Path params are force-unwrapped (`state.pathParameters['id']!`) straight into the repo. | `medium` | 🟠 | `app_router.dart` (whole `GoRouter` has no error handler) |
| PLT-4 | **Dead share + notifications controls.** The detail hero's `Icons.ios_share` button is `() {}`; the home notifications bell is `() {}`. No `share_plus`/`UIActivityViewController`; no APNs entitlement / `UIBackgroundModes`. (Falls under App Completeness 2.1.) | `low` | 🟠 | `listing_detail_screen.dart:74`; `home_screen.dart:133` |
| PLT-5 | **`pubspec.yaml` description is still `"A new Flutter project."`** — unconfigured scaffold metadata. | `low` | 🟡 | `pubspec.yaml:2` |
| PLT-6 | Notes only: no **Universal Links / associated-domains** for a share-a-listing app; no in-app **`SKStoreReviewController`** rating prompt. Both optional. | `info` | 🟡 | no `.entitlements`; no StoreKit usage |

> **Honest scope note from the critic:** Apple Pay/Wallet, Handoff, Widgets, App Clips, StoreKit, and kids/health/finance rules were deliberately **not** flagged — they aren't referenced or implied by this codebase, so raising them would be padding.

---

## 5. Prioritized remediation roadmap

### P0 — Required before any TestFlight / App Store submission
*(Mostly mechanical; none require redesign.)*

- [ ] Replace `com.example.vacationrentals` with a real owned bundle id in all 3 configs; register the App ID + create the App Store Connect record. **(IOS-1)**
- [ ] Add `ios/Runner/PrivacyInfo.xcprivacy` (start: `NSPrivacyTracking=false`, empty data types; add required-reason API codes as SDKs land). **(IOS-3 / PRIV-1)**
- [ ] Add `<key>ITSAppUsesNonExemptEncryption</key><false/>` to `Info.plist`. **(IOS-2 / PRIV-2)**
- [ ] Wire a real backend/REST repository + functional auth; make every visible control do something real or remove it. **(ASR-1, PLT-1/4)**
- [ ] Add an in-app **Delete Account** path (and Sign-out) once auth exists. **(ASR-2)**
- [ ] Publish a Privacy Policy + Terms; make the signup text tappable links; complete the App Privacy questionnaire in ASC. **(ASR-3)**
- [ ] **iPad decision:** either set `TARGETED_DEVICE_FAMILY = 1` (iPhone-only, fast & review-safe) or add genuine adaptive layouts. **(ADP-1)**
- [ ] Add the Sign in with Apple **entitlement** when implementing "Continue with Apple." **(PLT-1)**
- [ ] ASC process gates: reviewer demo account, Support URL, age rating, screenshots, Travel category. **(ASR-5)**

### P1 — Real present-day defects to fix now (independent of mockup status)

- [ ] **Fix the "Maps" pill** so it opens a map (or relabel/repoint it). **(PLT-2)**
- [ ] Add a GoRouter `errorBuilder` (+ graceful unknown-listing UI). **(PLT-3)**
- [ ] Accessibility pass: `tooltip`/`Semantics` labels on all icon buttons; non-colour cue + `Semantics` per calendar day; rating-stars aggregate label; `semanticLabel` on images; touch targets ≥44pt; darken yellow stars / raise grey hint contrast; drive text from `textTheme` and clamp text scaling. **(A11Y-1…7)**
- [ ] Add Dark Mode (`darkTheme` + `ThemeMode.system`) and re-check hardcoded white surfaces. **(HIG-1)**
- [ ] Set a `SystemUiOverlayStyle.light` over the blue hero. **(HIG-2)**
- [ ] Pad each tab's scroll content so the floating nav doesn't occlude the last item. **(ADP-2)**

### P2 — Polish & pre-production hygiene

- [ ] Haptics on key interactions; confirm/undo on committing actions; Cupertino/adaptive **date-range** picker. **(HIG-4/5/6)**
- [ ] Autofill hints + `AutofillGroup`; plan Keychain (`flutter_secure_storage`) for tokens. **(PRIV-3/4)**
- [ ] Replace `Format.money` with `intl NumberFormat`; add `flutter_localizations` delegates. **(ARCH-4 / L10N-1)**
- [ ] Stricter lints (`strict-casts`/`strict-inference`); split the 1040-line detail file; `autoDispose` family providers; add `FlutterError.onError` + `ProviderObserver` in `main()`. **(ARCH-1/2/3/5)**
- [ ] Branded launch screen; reconcile the three app names + the placeholder pubspec description; lock or polish landscape/iPad sheets. **(IOS-4/5/6, PLT-5)**
- [ ] Add a fault-injecting mock + a test that exercises the error/retry UI. **(ARCH-6)**

---

## 6. Methodology, confidence & limitations

- **Coverage:** all 35 Dart source files, `Info.plist`, `project.pbxproj`, storyboards, asset catalogs, `pubspec`, `analysis_options`, and the absence of `.entitlements`/privacy-manifest/Podfile were inspected.
- **Confidence:** every `blocker`/`high` and every §4.9 item was verified against the source by hand. Contrast ratios are **computed estimates** against `#FFFFFF`, not device-measured.
- **What this audit canNOT see:** the App Store Connect side (metadata, the App Privacy "nutrition label," screenshots, age rating, demo-account notes), on-device VoiceOver/Dynamic Type behavior, and runtime performance/jank. These need a real device + an ASC account.
- **Honesty on the findings themselves:** the verifier **refuted 1** finding (keyboard occlusion, §4.7) and **corrected citations on 4** (bundle-id guideline number, a decorative chip mis-flagged as a touch target, an image-exclusion rationale that's moot, and one grey that actually passes contrast). Those corrections are reflected above — this report does not inherit the raw reviewer claims uncritically.
- **Apple guideline numbers** cited (2.1, 4.2, 4.8, 5.1.1(v), 2.4.1, 3.1.3(e)) were checked for plausibility; a few were marked "approx" by the reviewers where the requirement is an App Store Connect/technical gate rather than a numbered review clause.

**Bottom line:** Architecturally and visually this is a strong prototype. Treat the P0 list as the "definition of done" for submission, invest in the P1 accessibility/adaptivity work (the part that needs real effort, not just config), and the app is on a clean path to App Store review.
