# mobile/CLAUDE.md

Flutter 3.47 · Material 3 · packages: `http`, `shared_preferences`, `flutter_map` + `latlong2`, `intl`,
`url_launcher`, `flutter_localizations`. **No state-management library** — `StatefulWidget` + `FutureBuilder`.
Read the root `CLAUDE.md` first.

## Run

```bash
flutter pub get
flutter gen-l10n                                    # after editing any .arb
flutter analyze                                     # must be clean
flutter run -d chrome                               # or: -d web-server --web-port 5555 (what the agent uses)
flutter run --dart-define=API_URL=https://host/api/v1
```
Dev Mac status: Chrome works; Xcode/CocoaPods absent; Android SDK present but licenses unaccepted
(`flutter doctor --android-licenses`). Verify UI in the Claude browser pane at **390×844**.

## Architecture

```
lib/main.dart                  App (StatefulWidget). AppState.refresh()/setLang(). MaterialApp with locale from
                               Api.I.lang; home = Login | CustomerHome | WorkerHome by Api.I.role.
lib/api.dart                   Api.I singleton: get/post/put/patch/form, login/register/logout, token+role+lang in
                               SharedPreferences (web: localStorage keys flutter.token/role/lang). ApiException(status, message).
                               inr(v) formats ₹. API base = --dart-define API_URL, default http://localhost:8000/api/v1.
lib/widgets.dart               kStatuses order, statusLabel(t, s), StatusChip, WelfareBadges, PriceSplit, Loading,
                               Async<T>(future, builder), toast(), LangMenu.
lib/l10n/app_{en,hi,mr}.arb    every UI string; generated app_localizations*.dart are committed.
lib/screens/login.dart         phone/password; "Create account" toggles register mode (role segmented button,
                               society dropdown from GET /services/cooperatives for workers).
lib/screens/customer/home.dart services grid → BookScreen; Emergency FAB → bottom sheet of services → BookScreen(emergency:true);
                               My bookings list (BookingTile, also reused by the worker tab).
lib/screens/customer/book.dart address, flutter_map pin (tap to move, default Andheri), date+time pickers,
                               emergency switch, live PriceSplit preview → POST /bookings → MatchScreen, or
                               BookingDetail directly if the API auto-assigned (emergency).
lib/screens/customer/match.dart POST /bookings/{id}/match → WorkerCard list (rank, score, ⭐, km, experience,
                               jobs this week, skills, welfare badges, score-breakdown bar) → assign → BookingDetail.
lib/screens/customer/booking_detail.dart status timeline over kStatuses, worker card, PriceSplit, actions by status:
                               completed→Pay (demo-mark-paid), paid→Rate dialog, paid/rated→View invoice (url_launcher
                               with ?token=), requested/assigned/accepted→Cancel.
lib/screens/worker/home.dart   AppBar availability Switch (POST /workers/me/availability) + NavigationBar with 4 tabs;
                               `refreshKey` bumps re-create tabs on switch so they refetch.
lib/screens/worker/jobs.dart   GET /workers/me/jobs → cards with "Estimated earnings ₹wage" → Accept.
lib/screens/worker/my_bookings.dart GET /bookings → BookingTile with Start / Mark complete buttons by status.
lib/screens/worker/earnings.dart GET /workers/me/earnings → month total card + per-job list.
lib/screens/worker/profile.dart GET /workers/me → welfare card, skills (multi-select dialog from /services →
                               PUT /workers/me/skills), certifications (name-only add via multipart form).
```

## Conventions

- Screens own their futures: `late Future<T> x = _load();` and refresh with `setState(() { x = _load(); })`.
  **Never** `setState(() => x = _load())` — the arrow returns the Future and Flutter throws.
- All strings through `AppLocalizations.of(context)!` (`t.foo`). Add the key to **all three** ARB files, then
  `flutter gen-l10n`. Placeholders: `"kmAway": "{km} km away"` with `@kmAway` metadata in `app_en.arb` only.
- Money: API returns strings (`"500.00"`); always go through `inr()` for display, `double.parse` for maths.
- Navigation: plain `Navigator.push` / `pushReplacement`; callers `await` and refetch on return.
- Errors: catch `ApiException`/anything, `toast(context, e)`; guard with `if (mounted)`.
- Role check for shared widgets: `Api.I.role == 'worker'` (e.g. BookingTile shows customer name to workers).
- Map: OSM tiles with `userAgentPackageName: 'in.coop.sahakarseva'`; no API key required.

## Deferred on purpose

Razorpay Flutter SDK (no web target; wire `razorpay_flutter` for Android and call `POST /payments/verify`),
certificate file picker/upload (backend already accepts a file), push notifications, offline cache, tests.
