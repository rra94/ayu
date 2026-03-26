# Feature O -- Apple HealthKit

## What

Two-way sync with Apple HealthKit to import weight, steps, workouts, sleep, and heart rate data into local ObjectBox collections.

## Why

Most longevity-focused users wear an Apple Watch. HealthKit is the canonical source for HRV, sleep stages, workout data, and resting heart rate. Importing this data enables cross-feature correlations (HRV vs. meal timing, sleep vs. calorie intake) that are impossible with manual entry alone.

## How

### Setup

- Add `health: ^11.0.0` to pubspec.yaml
- iOS `Info.plist`: add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription`
- Add HealthKit entitlement to Runner.entitlements
- Request read permissions for: weight, steps, workouts, sleep, heart_rate, heart_rate_variability_sdnn, active_energy_burned

### Sync Strategy

- **On-demand sync**: User taps "Sync with Apple Health" button on Stats page
- **Background sync**: Periodic sync when app is foregrounded (check last sync timestamp, fetch new data)
- **Deduplication**: Check for existing records with same timestamp before inserting
- **Conflict resolution**: HealthKit data takes precedence for auto-imported types; manual entries are preserved with source="manual"

### Data Mapping

| HealthKit Type | Local Collection | Notes |
|---------------|-----------------|-------|
| weight | WeightRecord | Merge with manual entries |
| steps | DailySummary field | Aggregate daily |
| workouts | UserActivity | Map workout type + calories |
| sleep | SleepRecord | Bed/wake + stages if available |
| heart_rate | BiometricRecord | Resting HR daily average |
| hrv_sdnn | BiometricRecord | Overnight average for correlation |
| active_energy | DailySummary field | Daily burned kcal |

### UI

- Settings: "Apple Health" toggle with permission status indicator
- Stats page: "Last synced: 2 hours ago" with manual sync button
- Data source badges on records: "Apple Watch" icon vs manual icon

## New Files / Collections

### New Files

- `lib/features/health_connect/services/healthkit_service.dart`
- `lib/features/health_connect/bloc/healthkit_bloc.dart`
- `lib/features/health_connect/bloc/healthkit_event.dart`
- `lib/features/health_connect/bloc/healthkit_state.dart`
- `lib/features/health_connect/presentation/widgets/healthkit_settings_card.dart`
- `lib/features/health_connect/presentation/widgets/healthkit_sync_button.dart`

### No New Collections

Writes into existing collections: WeightRecord, SleepRecord, BiometricRecord, UserActivity.

## Modified Files

- `ios/Runner/Info.plist` -- HealthKit usage descriptions
- `ios/Runner/Runner.entitlements` -- HealthKit entitlement
- `pubspec.yaml` -- add `health: ^11.0.0`
- Settings page -- add Apple Health configuration section
- Stats page -- add sync button and last-synced indicator
- WeightRecord, SleepRecord, BiometricRecord data sources -- handle source field for deduplication

## Checkpoint

- Grant HealthKit permissions on iPhone
- Tap sync -- weight, sleep, and HR data appear in Stats
- Manual entries coexist with HealthKit data (no duplicates)
- HRV data available for correlation features
