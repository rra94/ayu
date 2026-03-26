# Phone Sensors Integration — CoreMotion, CoreLocation, Barometer

**Date:** 2026-03-24
**Status:** Approved

## Overview

Add on-device phone sensor integration to Ayu using CoreMotion (steps, activity detection, sedentary tracking), CoreLocation (significant location changes for gym/outdoor detection), and CMAltimeter (barometric pressure for weather-mood correlation). Data surfaces through an Activity Dashboard on the home page and cross-domain agent insights.

**Principles:** Zero cloud. All sensor data stays on-device in ObjectBox. Location data is particularly sensitive — never exported or synced. None of the new services interact with Supabase or any remote backend.

---

## 1. iOS Platform Channels

Three new platform channels in `AppDelegate.swift`:

### `com.rra94.ayu/core_motion`
- `getActivityType` — One-shot `CMMotionActivityManager` query. Returns: `stationary`, `walking`, `running`, `cycling`, `automotive`, `unknown`.
- `getStationaryDuration` — Queries `CMMotionActivityManager` activity history (bounded to last 12 hours, cached for 5 min), returns minutes since last non-stationary activity.

**Note:** Steps are read from HealthKit (already integrated via `health` package), not from a separate `CMPedometer` stream. This avoids dual sources of truth. CoreMotion is used only for activity type detection and sedentary tracking.

### `com.rra94.ayu/core_location`
- `startSignificantLocationMonitoring` — Registers for `CLLocationManager.startMonitoringSignificantLocationChanges()`. Fires on ~500m movement. Uses "When In Use" permission only (sufficient for personal use, avoids "Always" permission complexity).
- `getLastKnownLocation` — Returns cached lat/lon from last significant change.
- Location changes pushed to Flutter via `FlutterEventChannel`, processed by `LocationInferenceService`.
- **Lifecycle:** Monitoring starts on app foreground, iOS may continue delivering events briefly in background. No `UIBackgroundModes` `location` capability needed — gym detection works from accumulated visits while app is in use.

### `com.rra94.ayu/barometer`
- `readPressure` — Single `CMAltimeter.startRelativeAltitudeUpdates()` reading. Returns absolute pressure (kPa) only. Called once on app foreground, stored in ObjectBox. Relative altitude is not stored (resets each time, meaningless for single readings).

### Info.plist Permissions
- `NSMotionUsageDescription` — "Ayu tracks your activity to detect sedentary periods and suggest movement."
- `NSLocationWhenInUseUsageDescription` — "Ayu detects gym visits and outdoor time to correlate with your health data."

No "Always" location permission — "When In Use" is sufficient for personal use.

---

## 2. Data Layer

### New ObjectBox Entities

**`ActivitySnapshotOB`**
- `int id` (ObjectBox @Id)
- `int steps` — cumulative step count for the day
- `double distanceMeters` — distance walked/run
- `String activityType` — stationary/walking/running/cycling/automotive
- `DateTime dateTime`

One record per app-open or per significant activity change.

**`LocationVisitOB`**
- `int id`
- `double lat`, `double lon`
- `DateTime arrivalTime`
- `DateTime? departureTime`
- `String label` — gym/home/work/other
- `int savedLocationId` — FK to SavedLocationOB (0 if unmatched)

**`PressureReadingOB`**
- `int id`
- `double pressureKPa` — absolute barometric pressure
- `DateTime dateTime`

One per app-open. No relative altitude (resets per session, useless for single readings).

**`SavedLocationOB`**
- `int id`
- `double lat`, `double lon`
- `double radiusMeters` — default 100m
- `String label` — user-confirmed label ("gym", "office", etc.)
- `int visitCount` — auto-incremented, used for auto-detection threshold

Auto-detected after 3+ visits to the same spot (within radius). `visitCount` incremented by `LocationInferenceService` when a new visit matches. User confirms label once via agent suggestion.

### Data Retention
- `ActivitySnapshotOB` — keep 90 days, prune older on app start.
- `LocationVisitOB` — keep 30 days of raw lat/lon. After 30 days, delete raw coordinates but keep label + date (aggregated).
- `PressureReadingOB` — keep 90 days, prune older.
- `SavedLocationOB` — permanent (user-confirmed places).

### New Data Sources

- **`ActivitySnapshotDataSource`** — CRUD, `getTodaySteps()`, `getStationarySince()`, `getWeekSummary()`, `getLatestActivity()`
- **`LocationVisitDataSource`** — CRUD, `getVisitsByLabel(String label, {int days})`, `getRecentVisits({int days})`, `getThisWeekGymCount()`
- **`PressureDataSource`** — CRUD, `getReadingsForDateRange(DateTime start, DateTime end)`, `getTodayReadings()`
- **`SavedLocationDataSource`** — CRUD, `findNearby(double lat, double lon, double radiusM)`, `getAll()`

---

## 3. Flutter Services

### `CoreMotionService`
- Wrapper around `com.rra94.ayu/core_motion` platform channel.
- `Future<String> getCurrentActivity()` — one-shot activity type.
- `Future<int> getStationaryMinutes()` — minutes since last movement (cached 5 min, bounded 12h lookback).
- Steps come from HealthKit (existing `HealthKitService.sync()`), not from CoreMotion.
- On app foreground: queries activity type, stores `ActivitySnapshotOB`.
- Graceful degradation: if permission denied, methods return defaults ("unknown" activity, 0 minutes).
- **Lifecycle:** Uses `WidgetsBindingObserver` — queries on `resumed`, no-op on `paused`.

### `LocationInferenceService`
- Consumes location events from `com.rra94.ayu/core_location` EventChannel.
- **Visit clustering:** Same spot within 100m of a `SavedLocationOB` = same place. Creates `LocationVisitOB` on arrival, updates departure time on next location change.
- **Auto-detection:** After 3+ visits lasting 30-90 minutes to an unlabeled cluster, generates an agent suggestion: "You visit this place often — is it a gym?"
- **Outdoor time:** Estimates outdoor minutes from location changes + activity type. Walking/running between locations = outdoor time.

### `BarometerService`
- Wrapper around `com.rra94.ayu/barometer` platform channel.
- `Future<void> recordReading()` — called on app foreground, stores `PressureReadingOB`.
- `Future<String> getPressureTrend()` — compares last 6h of readings, returns "rising", "falling", or "stable".
- `Future<double?> getPressureChange(Duration window)` — kPa delta over window.

---

## 4. Agents

### New Agents in `AgentService`

**`_sedentaryAgent()`**
- Triggers when `CoreMotionService.getStationaryMinutes() > 180` (3 hours).
- Suppressed during sleep hours (10pm-7am).
- Suppressed if today's steps already > 5000 (user has been active enough).
- Message: "You've been sitting for 3+ hours — even a 5 min walk helps."

**`_gymFrequencyAgent()`**
- Reads `LocationVisitDataSource.getThisWeekGymCount()`.
- Positive reinforcement: "3 gym visits this week, up from 2 last week!"
- Nudge if declining: "No gym visits in 5 days — schedule a session?"
- Only fires if user has a saved "gym" location.

**`_outdoorTimeAgent()`**
- Estimates outdoor minutes today from `LocationInferenceService`.
- If < 15 min and it's after 2pm: "Only 15 min outside today — get some sun for vitamin D."
- Correlates with vitamin D status from biomarkers if available.

### ObservationAgent Additions

**`_pressureMoodCorrelation()`** (replaces `_weatherMoodCorrelation` skeleton)
- Reads `BarometerService.getPressureChange(Duration(hours: 6))`.
- If pressure dropped > 0.7 kPa (~7 hPa) AND user logged low mood (symptom 8, severity >= 3):
  "Barometric pressure dropped today and you logged low mood — pressure changes can trigger headaches and fatigue. Stay hydrated and rest."

**`_sedentarySleepCorrelation()`**
- If today's steps < 2000 AND last night's sleep quality <= 2:
  "You were sedentary all day and slept poorly — even a 20 min walk improves deep sleep."

**`_gymProteinCorrelation()`**
- If gym visit detected today AND protein intake so far < 1.2g per kg body weight:
  "Gym day but protein is low — aim for 1.6g/kg on training days for recovery."

### Existing Agent Enhancements

**`_hydrationAgent()`** — If today's activity type includes running/cycling, lower the "behind pace" threshold (suggest water earlier on active days).

**`_nutrientGapAgent()`** — If gym detected today, prioritize protein and magnesium gaps in suggestions.

---

## 5. Activity Dashboard Widget

### Location
Home page → **Tracking** collapsible section, after `TodayViewCard`.

### Layout
Two-row Card, same visual style as `TodayViewCard` (gold Lotus theme).

**Top row — Today (4 items):**

| Steps | Activity | Calories | Outdoor |
|-------|----------|----------|---------|
| 6,234 / 10k | Walking icon | 340 kcal | 45 min |

- **Steps** — Today's count from HealthKit (via `BiomarkerDataSource`), gold `_MiniGauge` showing % of `ConfigOB.dailyStepGoal` (default 10,000 if null).
- **Activity** — Current activity type as icon (directions_walk / directions_run / directions_bike / airline_seat_recline_normal / directions_car). Updates on app foreground.
- **Calories** — Active energy burned today from `BiomarkerDataSource` (HealthKit sync). Gold `_MiniStat`.
- **Outdoor** — Estimated minutes outside. Gold text when > 30 min, dimmed gold otherwise.

**Bottom row — This Week (3 items):**

| Gym | Workouts | Avg HR |
|-----|----------|--------|
| 2x / 3x | 4 sessions | 62 bpm |

- **Gym** — Visit count this week from `LocationVisitDataSource`. Gold when hitting target (default 3x/week).
- **Workouts** — Count of HealthKit workout sessions this week from `BiomarkerDataSource`.
- **Avg HR** — Average resting heart rate this week from `BiomarkerDataSource`. Gold when in optimal range (< 65 bpm).

Bottom row only appears if HealthKit is connected (check `HealthKitService.hasPermissions()`).

### Permission States
- CoreMotion not granted → top row shows "Enable Motion" chip → triggers permission prompt on tap.
- Location not granted → Outdoor and Gym show "—" with subtle "Enable" text.
- Barometer has no UI — feeds ObservationAgent silently, no permission needed (CMAltimeter doesn't require explicit permission).

### Theme
- Gold gauges (`ayuGoldMuted` / `ayuGoldLight`) for met goals.
- Dimmed gold (`gold.withValues(alpha: 0.6)`) for unmet.
- Red override only for calorie overshoot (consistent with dashboard widget).
- Card radius 16px, 0 elevation (from CardTheme).

---

## 6. Files to Create

| File | Purpose |
|------|---------|
| `ios/Runner/AppDelegate.swift` | Add 3 platform channels (modify existing) |
| `ios/Runner/Info.plist` | Add motion + location permission strings (modify existing) |
| `lib/core/db/entities/activity_snapshot_ob.dart` | ActivitySnapshotOB entity |
| `lib/core/db/entities/location_visit_ob.dart` | LocationVisitOB entity |
| `lib/core/db/entities/pressure_reading_ob.dart` | PressureReadingOB entity |
| `lib/core/db/entities/saved_location_ob.dart` | SavedLocationOB entity |
| `lib/core/db/data_sources/activity_snapshot_data_source.dart` | Activity CRUD + queries |
| `lib/core/db/data_sources/location_visit_data_source.dart` | Location visit CRUD + queries |
| `lib/core/db/data_sources/pressure_data_source.dart` | Pressure CRUD + queries |
| `lib/core/db/data_sources/saved_location_data_source.dart` | Saved location CRUD + queries |
| `lib/core/services/core_motion_service.dart` | CoreMotion platform channel wrapper |
| `lib/core/services/location_inference_service.dart` | Visit clustering + gym detection |
| `lib/core/services/barometer_service.dart` | Barometric pressure wrapper |
| `lib/features/home/presentation/widgets/activity_dashboard_widget.dart` | 2-row Activity Dashboard |
| `lib/core/utils/locator.dart` | Register new data sources + services (modify existing) |
| `lib/core/services/agent_service.dart` | Add 3 new agents (modify existing) |
| `lib/core/services/observation_agent.dart` | Add 3 new observations, replace weather skeleton (modify existing) |

## 7. Verification

- `flutter analyze` — zero errors
- `flutter build ios` — compiles with new platform channels
- Manual test on iPhone:
  - Steps count updates live
  - Activity type icon changes (walk around, sit down)
  - Pressure reading stored on app open (check ObjectBox)
  - After 3+ gym visits, auto-detection prompt appears
  - Sedentary agent fires after 3h sitting
  - Outdoor time estimate reasonable
  - Dashboard shows "Enable Motion" / "Enable Location" when permissions not granted
  - Bottom row hidden when HealthKit not connected
