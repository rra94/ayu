# Remaining Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all remaining planned features across 4 phases: M8 (Phone Sensors), M9 (Peptide Tracker), M10 (Polishing), M11 (Widget & Extras).

**Architecture:** Same patterns as M0-M7 — ObjectBox entities, data sources registered in locator.dart, widgets in CollapsibleSections on home page, platform channels in AppDelegate.swift for iOS-native APIs.

**Tech Stack:** Flutter iOS, ObjectBox, BLoC (where needed), Apple CoreMotion/CoreLocation/CMAltimeter, fl_chart

---

## Phase M8: Phone Sensors (CoreMotion, CoreLocation, Barometer)

Full spec: `docs/superpowers/specs/2026-03-24-phone-sensors-design.md`

### File Structure

| File | Purpose |
|------|---------|
| `ios/Runner/AppDelegate.swift` | Add 3 platform channels (modify) |
| `ios/Runner/Info.plist` | Add motion + location permissions (modify) |
| `lib/core/db/entities/activity_snapshot_ob.dart` | Activity type + timestamp entity |
| `lib/core/db/entities/location_visit_ob.dart` | Gym/outdoor visit entity |
| `lib/core/db/entities/pressure_reading_ob.dart` | Barometric pressure entity |
| `lib/core/db/entities/saved_location_ob.dart` | User-labeled places entity |
| `lib/core/db/data_sources/activity_snapshot_data_source.dart` | Activity CRUD + queries |
| `lib/core/db/data_sources/location_visit_data_source.dart` | Visit CRUD + queries |
| `lib/core/db/data_sources/pressure_data_source.dart` | Pressure CRUD + queries |
| `lib/core/db/data_sources/saved_location_data_source.dart` | Saved location CRUD |
| `lib/core/services/core_motion_service.dart` | Flutter wrapper for CoreMotion channel |
| `lib/core/services/location_inference_service.dart` | Visit clustering + gym detection |
| `lib/core/services/barometer_service.dart` | Pressure reading + trend |
| `lib/core/db/objectbox_db_provider.dart` | Register 4 new boxes (modify) |
| `lib/core/utils/locator.dart` | Register 4 data sources + 3 services (modify) |
| `lib/features/home/presentation/widgets/activity_dashboard_widget.dart` | 2-row activity card |
| `lib/features/home/home_page.dart` | Add ActivityDashboardWidget to Tracking section (modify) |
| `lib/core/services/agent_service.dart` | Add 3 new agents (modify) |
| `lib/core/services/observation_agent.dart` | Add 3 new observations, replace weather skeleton (modify) |

---

### Task 1: ObjectBox Entities (4 entities)

**Files:**
- Create: `lib/core/db/entities/activity_snapshot_ob.dart`
- Create: `lib/core/db/entities/location_visit_ob.dart`
- Create: `lib/core/db/entities/pressure_reading_ob.dart`
- Create: `lib/core/db/entities/saved_location_ob.dart`
- Modify: `lib/core/db/objectbox_db_provider.dart`

- [ ] **Step 1: Create ActivitySnapshotOB**

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class ActivitySnapshotOB {
  @Id()
  int id = 0;

  /// stationary, walking, running, cycling, automotive, unknown
  String activityType;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  ActivitySnapshotOB({
    this.id = 0,
    required this.activityType,
    required this.dateTime,
  });
}
```

- [ ] **Step 2: Create LocationVisitOB**

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class LocationVisitOB {
  @Id()
  int id = 0;

  double lat;
  double lon;

  @Property(type: PropertyType.date)
  DateTime arrivalTime;

  @Property(type: PropertyType.date)
  DateTime? departureTime;

  /// gym, home, work, other
  String label;

  /// FK to SavedLocationOB (0 if unmatched)
  int savedLocationId;

  LocationVisitOB({
    this.id = 0,
    required this.lat,
    required this.lon,
    required this.arrivalTime,
    this.departureTime,
    this.label = 'other',
    this.savedLocationId = 0,
  });

  double get durationMinutes => departureTime != null
      ? departureTime!.difference(arrivalTime).inMinutes.toDouble()
      : DateTime.now().difference(arrivalTime).inMinutes.toDouble();
}
```

- [ ] **Step 3: Create PressureReadingOB**

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class PressureReadingOB {
  @Id()
  int id = 0;

  /// Absolute barometric pressure in kPa
  double pressureKPa;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  PressureReadingOB({
    this.id = 0,
    required this.pressureKPa,
    required this.dateTime,
  });
}
```

- [ ] **Step 4: Create SavedLocationOB**

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class SavedLocationOB {
  @Id()
  int id = 0;

  double lat;
  double lon;
  double radiusMeters;

  /// User-confirmed label: gym, office, home, etc.
  String label;

  int visitCount;

  SavedLocationOB({
    this.id = 0,
    required this.lat,
    required this.lon,
    this.radiusMeters = 100,
    required this.label,
    this.visitCount = 0,
  });
}
```

- [ ] **Step 5: Register boxes in ObjectBoxDBProvider**

Add to `objectbox_db_provider.dart`:
- 4 `late Box<...>` field declarations
- 4 `store.box<...>()` assignments in `init()`

- [ ] **Step 6: Run build_runner to regenerate objectbox.g.dart**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 7: Verify**

Run: `flutter analyze lib/core/db/entities/activity_snapshot_ob.dart lib/core/db/entities/location_visit_ob.dart lib/core/db/entities/pressure_reading_ob.dart lib/core/db/entities/saved_location_ob.dart`
Expected: No issues found

- [ ] **Step 8: Commit**

```bash
git add -f lib/core/db/entities/activity_snapshot_ob.dart lib/core/db/entities/location_visit_ob.dart lib/core/db/entities/pressure_reading_ob.dart lib/core/db/entities/saved_location_ob.dart lib/core/db/objectbox_db_provider.dart lib/objectbox-model.json lib/objectbox.g.dart
git commit -m "feat(m8): add 4 phone sensor ObjectBox entities"
```

---

### Task 2: Data Sources (4 data sources)

**Files:**
- Create: `lib/core/db/data_sources/activity_snapshot_data_source.dart`
- Create: `lib/core/db/data_sources/location_visit_data_source.dart`
- Create: `lib/core/db/data_sources/pressure_data_source.dart`
- Create: `lib/core/db/data_sources/saved_location_data_source.dart`
- Modify: `lib/core/utils/locator.dart`

- [ ] **Step 1: Create ActivitySnapshotDataSource**

Methods: `addSnapshot()`, `getTodaySnapshots()`, `getLatestActivity()`, `pruneOlderThan(DateTime cutoff)`

Follow pattern from `water_data_source.dart`: constructor takes `Box<ActivitySnapshotOB>`, all methods async, query with `.betweenDate()` for date ranges.

- [ ] **Step 2: Create LocationVisitDataSource**

Methods: `addVisit()`, `updateDeparture(int id, DateTime departure)`, `getRecentVisits({int days = 30})`, `getVisitsByLabel(String label, {int days = 30})`, `getThisWeekGymCount()`, `pruneOlderThan(DateTime cutoff)`

- [ ] **Step 3: Create PressureDataSource**

Methods: `addReading()`, `getTodayReadings()`, `getReadingsForDateRange(DateTime start, DateTime end)`, `pruneOlderThan(DateTime cutoff)`

- [ ] **Step 4: Create SavedLocationDataSource**

Methods: `addLocation()`, `getAll()`, `findNearby(double lat, double lon, double radiusM)`, `incrementVisitCount(int id)`

`findNearby` uses simple Euclidean distance approximation (lat/lon degrees → ~111km per degree). Load all, filter in Dart — small dataset.

- [ ] **Step 5: Register all 4 data sources in locator.dart**

```dart
locator.registerLazySingleton<ActivitySnapshotDataSource>(
    () => ActivitySnapshotDataSource(objectBoxProvider.activitySnapshotBox));
locator.registerLazySingleton<LocationVisitDataSource>(
    () => LocationVisitDataSource(objectBoxProvider.locationVisitBox));
locator.registerLazySingleton<PressureDataSource>(
    () => PressureDataSource(objectBoxProvider.pressureReadingBox));
locator.registerLazySingleton<SavedLocationDataSource>(
    () => SavedLocationDataSource(objectBoxProvider.savedLocationBox));
```

- [ ] **Step 6: Verify**

Run: `flutter analyze lib/core/db/data_sources/activity_snapshot_data_source.dart lib/core/db/data_sources/location_visit_data_source.dart lib/core/db/data_sources/pressure_data_source.dart lib/core/db/data_sources/saved_location_data_source.dart`

- [ ] **Step 7: Commit**

```bash
git add -f lib/core/db/data_sources/activity_snapshot_data_source.dart lib/core/db/data_sources/location_visit_data_source.dart lib/core/db/data_sources/pressure_data_source.dart lib/core/db/data_sources/saved_location_data_source.dart lib/core/utils/locator.dart
git commit -m "feat(m8): add 4 phone sensor data sources + register in locator"
```

---

### Task 3: iOS Platform Channels (CoreMotion + CoreLocation + Barometer)

**Files:**
- Modify: `ios/Runner/AppDelegate.swift`
- Modify: `ios/Runner/Info.plist`

- [ ] **Step 1: Add Info.plist permission strings**

Add to Info.plist:
```xml
<key>NSMotionUsageDescription</key>
<string>Ayu tracks your activity to detect sedentary periods and suggest movement.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ayu detects gym visits and outdoor time to correlate with your health data.</string>
```

- [ ] **Step 2: Add CoreMotion platform channel to AppDelegate.swift**

New channel `com.rra94.ayu/core_motion` with methods:
- `getActivityType` → `CMMotionActivityManager().queryActivityStarting(from:to:)`, return latest activity as string
- `getStationaryDuration` → query activity history (bounded 12h), find minutes since last non-stationary

Import `CoreMotion` at top.

- [ ] **Step 3: Add CoreLocation platform channel**

New channel `com.rra94.ayu/core_location` with methods:
- `startSignificantLocationMonitoring` → `CLLocationManager().startMonitoringSignificantLocationChanges()` (When In Use)
- `getLastKnownLocation` → return cached lat/lon

AppDelegate must conform to `CLLocationManagerDelegate`, implement `locationManager(_:didUpdateLocations:)`. Use `FlutterEventChannel` to stream location updates to Dart.

- [ ] **Step 4: Add Barometer platform channel**

New channel `com.rra94.ayu/barometer` with method:
- `readPressure` → `CMAltimeter.startRelativeAltitudeUpdates()`, grab first `pressure` value (kPa), stop updates, return

- [ ] **Step 5: Verify iOS build**

Run: `flutter build ios --no-codesign` (or build via Xcode)
Expected: Compiles without errors

- [ ] **Step 6: Commit**

```bash
git add ios/Runner/AppDelegate.swift ios/Runner/Info.plist
git commit -m "feat(m8): add CoreMotion, CoreLocation, Barometer platform channels"
```

---

### Task 4: Flutter Services (CoreMotion + Location + Barometer)

**Files:**
- Create: `lib/core/services/core_motion_service.dart`
- Create: `lib/core/services/location_inference_service.dart`
- Create: `lib/core/services/barometer_service.dart`
- Modify: `lib/core/utils/locator.dart`

- [ ] **Step 1: Create CoreMotionService**

```dart
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/activity_snapshot_data_source.dart';
import 'package:opennutritracker/core/db/entities/activity_snapshot_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class CoreMotionService {
  static final _log = Logger('CoreMotionService');
  static const _channel = MethodChannel('com.rra94.ayu/core_motion');

  String? _cachedActivity;
  int? _cachedStationaryMin;
  DateTime? _cacheTime;

  Future<String> getCurrentActivity() async {
    try {
      final result = await _channel.invokeMethod<String>('getActivityType');
      _cachedActivity = result ?? 'unknown';
      return _cachedActivity!;
    } catch (e) {
      _log.warning('CoreMotion unavailable: $e');
      return 'unknown';
    }
  }

  Future<int> getStationaryMinutes() async {
    // Cache for 5 minutes
    if (_cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 5 &&
        _cachedStationaryMin != null) {
      return _cachedStationaryMin!;
    }
    try {
      final result = await _channel.invokeMethod<int>('getStationaryDuration');
      _cachedStationaryMin = result ?? 0;
      _cacheTime = DateTime.now();
      return _cachedStationaryMin!;
    } catch (e) {
      _log.warning('CoreMotion unavailable: $e');
      return 0;
    }
  }

  /// Call on app foreground to record current activity
  Future<void> recordSnapshot() async {
    final activity = await getCurrentActivity();
    final ds = locator<ActivitySnapshotDataSource>();
    await ds.addSnapshot(ActivitySnapshotOB(
      activityType: activity,
      dateTime: DateTime.now(),
    ));
  }
}
```

- [ ] **Step 2: Create LocationInferenceService**

Key methods:
- `startMonitoring()` → calls platform channel, listens to EventChannel
- `_onLocationUpdate(double lat, double lon)` → match against SavedLocationOB via `findNearby()`, create/update LocationVisitOB
- `getOutdoorMinutesToday()` → count minutes between location changes where activity = walking/running
- `_checkAutoDetection()` → if unmatched cluster has 3+ visits of 30-90min, generate agent suggestion

- [ ] **Step 3: Create BarometerService**

```dart
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/pressure_data_source.dart';
import 'package:opennutritracker/core/db/entities/pressure_reading_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class BarometerService {
  static final _log = Logger('BarometerService');
  static const _channel = MethodChannel('com.rra94.ayu/barometer');

  Future<void> recordReading() async {
    try {
      final kPa = await _channel.invokeMethod<double>('readPressure');
      if (kPa == null) return;
      final ds = locator<PressureDataSource>();
      await ds.addReading(PressureReadingOB(
        pressureKPa: kPa,
        dateTime: DateTime.now(),
      ));
    } catch (e) {
      _log.warning('Barometer unavailable: $e');
    }
  }

  Future<String> getPressureTrend() async {
    final ds = locator<PressureDataSource>();
    final now = DateTime.now();
    final readings = await ds.getReadingsForDateRange(
      now.subtract(const Duration(hours: 6)), now,
    );
    if (readings.length < 2) return 'stable';
    final first = readings.last.pressureKPa;
    final last = readings.first.pressureKPa;
    final delta = last - first;
    if (delta > 0.3) return 'rising';
    if (delta < -0.3) return 'falling';
    return 'stable';
  }

  Future<double?> getPressureChange(Duration window) async {
    final ds = locator<PressureDataSource>();
    final now = DateTime.now();
    final readings = await ds.getReadingsForDateRange(
      now.subtract(window), now,
    );
    if (readings.length < 2) return null;
    return readings.first.pressureKPa - readings.last.pressureKPa;
  }
}
```

- [ ] **Step 4: Register 3 services in locator.dart**

- [ ] **Step 5: Verify**

Run: `flutter analyze lib/core/services/core_motion_service.dart lib/core/services/location_inference_service.dart lib/core/services/barometer_service.dart`

- [ ] **Step 6: Commit**

```bash
git add -f lib/core/services/core_motion_service.dart lib/core/services/location_inference_service.dart lib/core/services/barometer_service.dart lib/core/utils/locator.dart
git commit -m "feat(m8): add CoreMotion, LocationInference, Barometer services"
```

---

### Task 5: Activity Dashboard Widget

**Files:**
- Create: `lib/features/home/presentation/widgets/activity_dashboard_widget.dart`
- Modify: `lib/features/home/home_page.dart`

- [ ] **Step 1: Create ActivityDashboardWidget**

Two-row Card matching TodayViewCard style:
- **Top row (Today):** Steps (from BiomarkerDataSource/HealthKit), Activity type icon, Active calories, Outdoor minutes
- **Bottom row (This Week):** Gym visits, Workout count, Avg resting HR
- Bottom row only shows if HealthKit connected
- Gold Lotus theme: `ayuGoldMuted`/`ayuGoldLight` for met goals, dimmed for unmet
- Permission states: "Enable Motion" chip if CoreMotion denied, "—" for Location items if denied

Uses same `_MiniGauge` and `_MiniStat` pattern as TodayViewCard. Step goal default: `ConfigOB.dailyStepGoal ?? 10000`.

- [ ] **Step 2: Add to home_page.dart Tracking section**

Insert `ActivityDashboardWidget()` after `StepsCard` in the "Tracking" CollapsibleSection.

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/features/home/presentation/widgets/activity_dashboard_widget.dart`

- [ ] **Step 4: Commit**

```bash
git add -f lib/features/home/presentation/widgets/activity_dashboard_widget.dart lib/features/home/home_page.dart
git commit -m "feat(m8): add 2-row activity dashboard to home page"
```

---

### Task 6: New Agents + Observation Updates

**Files:**
- Modify: `lib/core/services/agent_service.dart`
- Modify: `lib/core/services/observation_agent.dart`

- [ ] **Step 1: Add 3 new agents to AgentService**

Add to `getSuggestions()`:
```dart
try { suggestions.addAll(await _sedentaryAgent()); } catch (_) {}
try { suggestions.addAll(await _gymFrequencyAgent()); } catch (_) {}
try { suggestions.addAll(await _outdoorTimeAgent()); } catch (_) {}
```

Implement:
- `_sedentaryAgent()` — if stationaryMinutes > 180, not sleep hours (10pm-7am), not already active (steps < 5000)
- `_gymFrequencyAgent()` — reads gym visit count this week, positive or nudge
- `_outdoorTimeAgent()` — if outdoor minutes < 15 and it's after 2pm

- [ ] **Step 2: Add 3 new observations to ObservationAgent**

Replace `_weatherMoodCorrelation` with `_pressureMoodCorrelation`:
- Pressure drop > 0.7 kPa + low mood → suggest hydration/rest

Add `_sedentarySleepCorrelation`:
- Steps < 2000 + sleep quality <= 2 → suggest walking

Add `_gymProteinCorrelation`:
- Gym visit today + protein < 1.2g/kg → suggest more protein

- [ ] **Step 3: Enhance existing agents**

- `_hydrationAgent()` — check activity type, lower threshold on active days
- `_nutrientGapAgent()` — if gym today, prioritize protein/magnesium

- [ ] **Step 4: Verify**

Run: `flutter analyze lib/core/services/agent_service.dart lib/core/services/observation_agent.dart`

- [ ] **Step 5: Commit**

```bash
git add -f lib/core/services/agent_service.dart lib/core/services/observation_agent.dart
git commit -m "feat(m8): add sedentary, gym, outdoor agents + 3 new observations"
```

---

### Task 7: Data Retention + App Lifecycle

**Files:**
- Create: `lib/core/services/data_retention_service.dart`
- Modify: `lib/features/home/home_page.dart` (or wherever app foreground is handled)

- [ ] **Step 1: Create DataRetentionService**

```dart
class DataRetentionService {
  static Future<void> pruneOldData() async {
    final cutoff90 = DateTime.now().subtract(const Duration(days: 90));
    final cutoff30 = DateTime.now().subtract(const Duration(days: 30));

    await locator<ActivitySnapshotDataSource>().pruneOlderThan(cutoff90);
    await locator<LocationVisitDataSource>().pruneOlderThan(cutoff30);
    await locator<PressureDataSource>().pruneOlderThan(cutoff90);
  }
}
```

- [ ] **Step 2: Wire app lifecycle**

In home_page.dart (or MainScreen), use `WidgetsBindingObserver`:
- On `resumed`: call `CoreMotionService.recordSnapshot()`, `BarometerService.recordReading()`, `LocationInferenceService.startMonitoring()`
- On app start: call `DataRetentionService.pruneOldData()` once

- [ ] **Step 3: Verify + Commit**

```bash
git add -f lib/core/services/data_retention_service.dart lib/features/home/home_page.dart
git commit -m "feat(m8): add data retention pruning + app lifecycle sensor hooks"
```

---

## Phase M9: Peptide Tracker

### File Structure

| File | Purpose |
|------|---------|
| `lib/core/db/entities/peptide_ob.dart` | Peptide definition (name, concentration, cycle) |
| `lib/core/db/entities/peptide_log_ob.dart` | Injection log (dose, site, timestamp) |
| `lib/core/db/data_sources/peptide_data_source.dart` | Peptide CRUD + cycle queries |
| `lib/core/utils/calc/reconstitution_calc.dart` | BAC water + peptide mg → dose per unit |
| `lib/features/peptides/presentation/widgets/peptide_stack_widget.dart` | Active peptide stack card |
| `lib/features/peptides/presentation/widgets/peptide_log_dialog.dart` | Log injection dialog |
| `lib/features/peptides/presentation/widgets/injection_site_tracker.dart` | Body map for site rotation |
| `lib/core/db/objectbox_db_provider.dart` | Register 2 new boxes (modify) |
| `lib/core/utils/locator.dart` | Register data source (modify) |
| `lib/features/home/home_page.dart` | Add to Habits & Supplements section (modify) |
| `lib/core/services/agent_service.dart` | Add peptide reminder agent (modify) |

---

### Task 8: Peptide Entities + Data Source

**Files:**
- Create: `lib/core/db/entities/peptide_ob.dart`
- Create: `lib/core/db/entities/peptide_log_ob.dart`
- Create: `lib/core/db/data_sources/peptide_data_source.dart`
- Modify: `lib/core/db/objectbox_db_provider.dart`
- Modify: `lib/core/utils/locator.dart`

- [ ] **Step 1: Create PeptideOB**

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class PeptideOB {
  @Id()
  int id = 0;

  String name; // BPC-157, TB-500, GHK-Cu, Semaglutide, etc.
  String? brand;

  /// Reconstitution info
  double peptideMg; // total mg in vial
  double bacWaterMl; // ml of BAC water added
  double doseUnits; // units per injection (e.g., 10 units on insulin syringe)

  /// Dosing schedule
  String frequency; // daily, eod, mon_wed_fri, 5on2off, weekly
  int cycleDays; // total cycle length (e.g., 60)
  int restDays; // days off between cycles (e.g., 30)

  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime? endDate;

  bool isActive;

  /// Injection route: subq, im
  String route;

  String? notes;

  PeptideOB({
    this.id = 0,
    required this.name,
    this.brand,
    required this.peptideMg,
    required this.bacWaterMl,
    required this.doseUnits,
    this.frequency = 'daily',
    this.cycleDays = 60,
    this.restDays = 30,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.route = 'subq',
    this.notes,
  });

  /// Concentration: mcg per unit on syringe
  double get mcgPerUnit => (peptideMg * 1000) / (bacWaterMl * 100);

  /// Dose per injection in mcg
  double get doseMcg => mcgPerUnit * doseUnits;

  /// Days into current cycle
  int get cycleDayNumber {
    final elapsed = DateTime.now().difference(startDate).inDays;
    return (elapsed % (cycleDays + restDays)) + 1;
  }

  /// Whether currently in active phase (not rest)
  bool get isInActiveCyclePhase => cycleDayNumber <= cycleDays;

  /// Whether today is a dosing day based on frequency
  bool get isDoseDay {
    if (!isInActiveCyclePhase) return false;
    final dow = DateTime.now().weekday; // 1=Mon, 7=Sun
    switch (frequency) {
      case 'daily': return true;
      case 'eod': return DateTime.now().difference(startDate).inDays.isEven;
      case 'mon_wed_fri': return dow == 1 || dow == 3 || dow == 5;
      case '5on2off':
        final dayInWeek = cycleDayNumber % 7;
        return dayInWeek >= 1 && dayInWeek <= 5;
      case 'weekly': return dow == startDate.weekday;
      default: return true;
    }
  }
}
```

- [ ] **Step 2: Create PeptideLogOB**

```dart
import 'package:objectbox/objectbox.dart';

@Entity()
class PeptideLogOB {
  @Id()
  int id = 0;

  int peptideId; // FK to PeptideOB
  double doseUnits;
  double doseMcg;

  /// Injection site: abdomen_left, abdomen_right, thigh_left, thigh_right,
  /// deltoid_left, deltoid_right, glute_left, glute_right
  String injectionSite;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  String? notes;

  PeptideLogOB({
    this.id = 0,
    required this.peptideId,
    required this.doseUnits,
    required this.doseMcg,
    required this.injectionSite,
    required this.dateTime,
    this.notes,
  });
}
```

- [ ] **Step 3: Create PeptideDataSource**

Methods:
- `addPeptide()`, `updatePeptide()`, `deletePeptide(int id)`
- `getAllActive()` → query `isActive == true`, ordered by name
- `addLog()`, `getLogsForDate(DateTime date)`, `getLogsForPeptide(int peptideId, {int days = 30})`
- `getTodayLoggedIds()` → Set<int> of peptide IDs logged today
- `getLastInjectionSite(int peptideId)` → most recent site for rotation suggestion
- `getInjectionSiteHistory(int peptideId, {int count = 10})` → last N sites for rotation display

- [ ] **Step 4: Register in ObjectBoxDBProvider + locator**

- [ ] **Step 5: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: Verify + Commit**

```bash
git add -f lib/core/db/entities/peptide_ob.dart lib/core/db/entities/peptide_log_ob.dart lib/core/db/data_sources/peptide_data_source.dart lib/core/db/objectbox_db_provider.dart lib/core/utils/locator.dart lib/objectbox-model.json lib/objectbox.g.dart
git commit -m "feat(m9): add peptide + peptide log entities and data source"
```

---

### Task 9: Reconstitution Calculator

**Files:**
- Create: `lib/core/utils/calc/reconstitution_calc.dart`
- Create: `test/unit_test/reconstitution_calc_test.dart`

- [ ] **Step 1: Write tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/reconstitution_calc.dart';

void main() {
  group('ReconstitutionCalc', () {
    test('BPC-157 standard reconstitution', () {
      // 5mg peptide + 2ml BAC water = 2500mcg/ml
      // 10 units on 100-unit syringe = 0.1ml = 250mcg
      final result = ReconstitutionCalc.calculate(
        peptideMg: 5, bacWaterMl: 2, doseUnits: 10,
      );
      expect(result.concentrationMcgPerMl, 2500);
      expect(result.doseMcg, 250);
      expect(result.dosesPerVial, 20);
    });

    test('TB-500 reconstitution', () {
      // 5mg + 1ml = 5000mcg/ml, 50 units = 0.5ml = 2500mcg
      final result = ReconstitutionCalc.calculate(
        peptideMg: 5, bacWaterMl: 1, doseUnits: 50,
      );
      expect(result.concentrationMcgPerMl, 5000);
      expect(result.doseMcg, 2500);
      expect(result.dosesPerVial, 2);
    });

    test('injection site rotation suggests next site', () {
      final history = ['abdomen_left', 'abdomen_right', 'thigh_left'];
      final next = ReconstitutionCalc.suggestNextSite(history);
      expect(next, 'thigh_right'); // round-robin through sites
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit_test/reconstitution_calc_test.dart`

- [ ] **Step 3: Implement ReconstitutionCalc**

```dart
class ReconstitutionResult {
  final double concentrationMcgPerMl;
  final double doseMcg;
  final int dosesPerVial;

  ReconstitutionResult({
    required this.concentrationMcgPerMl,
    required this.doseMcg,
    required this.dosesPerVial,
  });
}

class ReconstitutionCalc {
  static const allSites = [
    'abdomen_left', 'abdomen_right',
    'thigh_left', 'thigh_right',
    'deltoid_left', 'deltoid_right',
    'glute_left', 'glute_right',
  ];

  static ReconstitutionResult calculate({
    required double peptideMg,
    required double bacWaterMl,
    required double doseUnits,
  }) {
    final concMcgPerMl = (peptideMg * 1000) / bacWaterMl;
    final doseMl = doseUnits / 100; // 100-unit syringe
    final doseMcg = concMcgPerMl * doseMl;
    final totalDoseMl = bacWaterMl;
    final dosesPerVial = (totalDoseMl / doseMl).floor();

    return ReconstitutionResult(
      concentrationMcgPerMl: concMcgPerMl,
      doseMcg: doseMcg,
      dosesPerVial: dosesPerVial,
    );
  }

  static String suggestNextSite(List<String> recentSites) {
    if (recentSites.isEmpty) return allSites.first;
    final lastSite = recentSites.last;
    final idx = allSites.indexOf(lastSite);
    return allSites[(idx + 1) % allSites.length];
  }
}
```

- [ ] **Step 4: Run tests to verify pass**

- [ ] **Step 5: Commit**

```bash
git add -f lib/core/utils/calc/reconstitution_calc.dart test/unit_test/reconstitution_calc_test.dart
git commit -m "feat(m9): add reconstitution calculator with tests"
```

---

### Task 10: Peptide Stack Widget + Log Dialog

**Files:**
- Create: `lib/features/peptides/presentation/widgets/peptide_stack_widget.dart`
- Create: `lib/features/peptides/presentation/widgets/peptide_log_dialog.dart`
- Modify: `lib/features/home/home_page.dart`

- [ ] **Step 1: Create PeptideStackWidget**

StatefulWidget showing active peptides as a checklist (same pattern as SupplementChecklistWidget):
- Header: "Peptides (X/Y dosed today)"
- Each row: peptide name, dose (e.g., "250mcg subq"), cycle day (e.g., "Day 14/60"), checkbox
- Tap checkbox → show PeptideLogDialog to confirm site
- "Add Peptide" button → dialog with fields: name, peptide mg, BAC water ml, dose units, frequency dropdown, cycle/rest days, route
- Shows reconstitution info: "250mcg per 10 units, 20 doses per vial"
- Gold checkmarks for completed, dimmed for pending
- Show "REST" badge if peptide is in rest phase

- [ ] **Step 2: Create PeptideLogDialog**

Dialog shown when tapping a peptide to log:
- Shows peptide name + calculated dose
- Injection site selector: 8 sites as a simple grid of chips
- Highlights suggested next site (from rotation)
- Shows last 3 sites used (for awareness)
- Confirm button logs the injection

- [ ] **Step 3: Add to home_page.dart**

Insert `PeptideStackWidget()` after `SupplementChecklistWidget` in the "Habits & Supplements" CollapsibleSection.

- [ ] **Step 4: Verify + Commit**

```bash
git add -f lib/features/peptides/presentation/widgets/peptide_stack_widget.dart lib/features/peptides/presentation/widgets/peptide_log_dialog.dart lib/features/home/home_page.dart
git commit -m "feat(m9): add peptide stack widget + injection log dialog"
```

---

### Task 11: Injection Site Tracker + Peptide Agent

**Files:**
- Create: `lib/features/peptides/presentation/widgets/injection_site_tracker.dart`
- Modify: `lib/core/services/agent_service.dart`

- [ ] **Step 1: Create InjectionSiteTracker**

A visual body map (simplified — 4x2 grid of labeled body regions):
- Each region shows last injection date and count
- Color-coded: green (>5 days since), yellow (3-5 days), red (<3 days)
- Tapping a region shows history for that site
- Accessible from PeptideStackWidget via "Site Map" button

- [ ] **Step 2: Add _peptideReminderAgent to AgentService**

```dart
static Future<List<AgentSuggestion>> _peptideReminderAgent() async {
  final now = DateTime.now();
  if (now.hour < 8 || now.hour > 22) return [];

  final ds = locator<PeptideDataSource>();
  final active = await ds.getAllActive();
  final todayLogged = await ds.getTodayLoggedIds();

  final pending = active.where((p) => p.isDoseDay && !todayLogged.contains(p.id)).toList();
  if (pending.isEmpty) return [];

  final names = pending.map((p) => p.name).join(', ');
  return [
    AgentSuggestion(
      type: 'peptide_reminder',
      title: '${pending.length} peptide${pending.length > 1 ? 's' : ''} due',
      message: '$names — don\'t forget today\'s dose',
    ),
  ];
}
```

Wire into `getSuggestions()`.

- [ ] **Step 3: Verify + Commit**

```bash
git add -f lib/features/peptides/presentation/widgets/injection_site_tracker.dart lib/core/services/agent_service.dart
git commit -m "feat(m9): add injection site tracker + peptide reminder agent"
```

---

## Phase M10: Polishing (Missing Competitive Features)

### Task 12: 30 Plants a Week Tracker

**Files:**
- Create: `lib/features/home/presentation/widgets/plant_tracker_widget.dart`
- Modify: `lib/features/home/home_page.dart`

- [ ] **Step 1: Create PlantTrackerWidget**

Reads this week's intake data, extracts unique plant-based foods (fruits, vegetables, legumes, grains, nuts, seeds, herbs — classify by OFF categories or simple keyword matching).

Shows: "18/30 plants this week" with a gold progress ring.
Tap to expand → list of unique plants counted.

No new entity needed — derives from existing IntakeEntity data.

- [ ] **Step 2: Add to Health section in home_page.dart**

- [ ] **Step 3: Commit**

```bash
git add -f lib/features/home/presentation/widgets/plant_tracker_widget.dart lib/features/home/home_page.dart
git commit -m "feat(m10): add 30 plants a week tracker"
```

---

### Task 13: Nutrient Synergy Checker

**Files:**
- Create: `lib/core/services/nutrient_synergy_service.dart`
- Create: `test/unit_test/nutrient_synergy_test.dart`
- Modify: `lib/features/meal_detail/presentation/widgets/meal_detail_nutriments_table.dart`

- [ ] **Step 1: Write tests for synergy rules**

Test cases:
- Iron + Vitamin C → "enhanced absorption (2-6x)"
- Calcium + Iron → "calcium inhibits iron absorption"
- Vitamin D + Calcium → "vitamin D enhances calcium absorption"
- Fat + Vitamin A/D/E/K → "fat-soluble, needs dietary fat"
- Zinc + Copper → "high zinc inhibits copper absorption"

- [ ] **Step 2: Implement NutrientSynergyService**

Static rules engine. Given a meal's nutrient profile, return list of `SynergyTip`:
```dart
class SynergyTip {
  final String type; // 'enhancer' or 'inhibitor'
  final String nutrientA;
  final String nutrientB;
  final String message;
}
```

~15-20 evidence-based rules from WHO/FAO.

- [ ] **Step 3: Show synergy tips in meal detail**

Add a "Synergy" section below the nutriments table showing relevant tips for the current meal.

- [ ] **Step 4: Commit**

```bash
git add -f lib/core/services/nutrient_synergy_service.dart test/unit_test/nutrient_synergy_test.dart lib/features/meal_detail/presentation/widgets/meal_detail_nutriments_table.dart
git commit -m "feat(m10): add nutrient synergy checker with 15+ rules"
```

---

### Task 14: Allergen Persistence

**Files:**
- Modify: `lib/core/services/allergen_service.dart`
- Modify: `lib/core/db/entities/config_ob.dart`

- [ ] **Step 1: Persist allergens in ConfigOB**

Add `String? allergenJson` field to ConfigOB (JSON-encoded list of allergen strings). Load on app start, save when user updates.

Replace `AllergenService._userAllergens` in-memory Set with ObjectBox-backed persistence.

- [ ] **Step 2: Verify + Commit**

```bash
git add -f lib/core/services/allergen_service.dart lib/core/db/entities/config_ob.dart
git commit -m "fix(m10): persist allergen preferences to ObjectBox"
```

---

## Phase M11: Widget & Extras

### Task 15: iOS Lock Screen Widget

**Files:**
- Modify: `ios/AyuWidget/` (existing widget extension directory)
- Modify: `lib/core/services/widget_service.dart`

- [ ] **Step 1: Design widget data**

Widget shows: today's calories (consumed/goal), water %, streak count.
Uses `home_widget` package to push data from Flutter → WidgetKit.

- [ ] **Step 2: Implement WidgetKit SwiftUI view**

Small widget (systemSmall): calorie ring + streak number.
Medium widget: calorie ring + water + supplements + streak.

- [ ] **Step 3: Wire widget_service.dart to update on data changes**

Call `HomeWidget.updateWidget()` after each intake/water/supplement log.

- [ ] **Step 4: Commit**

```bash
git add ios/AyuWidget/ lib/core/services/widget_service.dart
git commit -m "feat(m11): add iOS Lock Screen + Home Screen widget"
```

---

### Task 16: Blueprint Mode (Optional)

**Files:**
- Modify: `lib/core/db/entities/config_ob.dart`
- Create: `lib/core/services/blueprint_service.dart`

- [ ] **Step 1: Add blueprintMode flag to ConfigOB**

When enabled: auto-set macro targets to Bryan Johnson's Blueprint protocol, show Blueprint-specific UI hints (e.g., "Super Veggie" meal template, olive oil target, supplement timing).

- [ ] **Step 2: Implement BlueprintService with protocol defaults**

- [ ] **Step 3: Commit**

```bash
git add -f lib/core/db/entities/config_ob.dart lib/core/services/blueprint_service.dart
git commit -m "feat(m11): add Blueprint Mode toggle"
```

---

## Summary

| Phase | Tasks | Focus |
|-------|-------|-------|
| **M8** | Tasks 1-7 | Phone sensors (CoreMotion, CoreLocation, Barometer) + Activity Dashboard |
| **M9** | Tasks 8-11 | Peptide tracker (entities, reconstitution calc, stack widget, site rotation, agent) |
| **M10** | Tasks 12-14 | Polish (30 plants, synergy checker, allergen persistence) |
| **M11** | Tasks 15-16 | iOS widget + Blueprint Mode |

**Total: 16 tasks across 4 phases.**

Each phase produces working, testable software independently. Run `flutter analyze` after each task, manual test on iPhone after each phase.
