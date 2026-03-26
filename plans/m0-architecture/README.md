# M0: Architecture Refactor

## What
Replace Hive with ObjectBox, restructure the codebase into self-contained feature modules, and add a service layer between repositories and BLoCs.

## Why
- ObjectBox is actively maintained, Flutter-native, supports complex queries, relations, and indexes.
- Hive has end-of-life concerns; ObjectBox is better for long-term viability.
- The flat folder layout does not scale. Feature modules enable parallel development and clear ownership.
- A service layer decouples business logic from state management, making BLoCs thin coordinators.

## How

### M0.1 -- ObjectBox Migration

- Add `objectbox: ^4.0.1`, `objectbox_flutter_libs: ^4.0.1` to pubspec.yaml; add `objectbox_generator: ^4.0.1` + `build_runner` in dev deps.
- Replace `hive_db_provider.dart` with `objectbox_db_provider.dart` (single Store instance).
- Convert each `@HiveType` DBO to `@Entity()` ObjectBox entity (same fields, new annotations).
- Build one-time migration: read all Hive data, write to ObjectBox, flag complete in Config.
- **DO NOT remove Hive deps immediately.** Keep Hive read-only deps for 3-6 months minimum. Users skip updates -- someone jumping from v1.0 to v1.4 must still be able to migrate. Only sunset Hive code when analytics confirm 99%+ of active users have migrated.

**Collections:**
Intake, Meal, MealNutriments, TrackedDay, User, Config, UserActivity, PhysicalActivity, GutHealthItem, WeightRecord, BiometricRecord, Supplement, SupplementLog, FastingSession, Habit, HabitLog, FavoriteMeal, WaterRecord, SleepRecord, DexaScan

### M0.2 -- Modular Feature Architecture

Restructure flat folder layout into self-contained feature modules:

```
lib/
  core/
    db/                    -- ObjectBox provider
    di/locator.dart        -- simplified DI
    services/              -- NEW orchestration layer
      nutrition_service.dart
      health_metrics_service.dart
      daily_summary_service.dart
      nutrient_resolver.dart
    utils/calc/            -- existing (keep)
    presentation/          -- shared widgets
    navigation/
  features/
    food_data/             -- CORE: FDC/OFF/Nutritionix/barcode
    intake/                -- meal logging
    nutrition/             -- macro + micro tracking, RDA
    gut_health/            -- Feature A
    weight/                -- Feature C
    stats/                 -- Feature D (tab shell)
    biomarkers/            -- Feature E
    supplements/           -- Feature F
    fasting/               -- Feature G
    habits/                -- Feature H
    favorites/             -- Feature I
    water/                 -- Feature J
    sleep/                 -- Feature K
    meal_timing/           -- Feature L
    patterns/              -- Feature R
    streaks/               -- Feature Q
    dexa/                  -- Feature T
    health_connect/        -- Feature O
    diary/                 -- existing
    profile/               -- existing
    settings/              -- existing
    onboarding/            -- existing
```

### M0.3 -- Service Layer + BLoC Split

**Services:**
- `NutritionService` -- aggregates intake data, computes macro+micro totals, data completeness
- `HealthMetricsService` -- diet impact biomarkers, auto-flags, supplement detection
- `DailySummaryService` -- aggregates ALL daily data into single entity (future AI input)
- `NutrientResolver` -- FDC > Nutritionix > OFF > Custom priority, "fill from similar" estimation

**BLoC Split:**
```
HomeBloc (lightweight coordinator)
  WaterBloc, HabitsBloc, GutHealthBloc, FavoritesBloc, PatternsBloc

StatsBloc (lightweight coordinator)
  WeightBloc, NutritionBloc, BiomarkersBloc, SupplementsBloc,
  FastingBloc, SleepBloc, MealTimingBloc, StreaksBloc, DexaBloc
```

## Modified files
- `lib/core/utils/hive_db_provider.dart` -- replace with `objectbox_db_provider.dart`
- All `lib/core/data/dbo/*.dart` -- convert to ObjectBox collections
- All `lib/core/data/data_source/*.dart` -- use ObjectBox queries instead of Hive box iteration
- `lib/core/utils/locator.dart` -- pass ObjectBox instance instead of Hive boxes
- `pubspec.yaml` -- swap deps

## Checkpoint
App runs on iPhone with all existing features working on ObjectBox. No data loss from migration. App compiles, all existing features work, architecture is modular.
