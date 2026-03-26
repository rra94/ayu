# Feature N -- Daily Summary Entity (DailySummaryEntity)

## What

A service that aggregates ALL daily health data into a single `DailySummaryEntity` structure. This entity serves as the canonical daily snapshot and the input format for future AI health coaching.

## Why

Data is currently scattered across 10+ collections (Intake, WaterRecord, SleepRecord, SupplementLog, FastingSession, BiometricRecord, etc.). No single query can answer "how was my day?" To power weekly reviews (Feature Y), longevity insights (Feature V), pattern detection (Feature R), and a future AI coach, we need a unified daily aggregate.

## How

### Service

`lib/core/services/daily_summary_service.dart`:

```dart
class DailySummaryService {
  /// Build a complete daily summary for the given date.
  /// Queries all relevant collections and aggregates.
  Future<DailySummaryEntity> buildSummary(DateTime date);

  /// Build summaries for a date range (used by weekly review).
  Future<List<DailySummaryEntity>> buildRange(DateTime start, DateTime end);
}
```

### DailySummaryEntity Fields

| Category | Fields |
|----------|--------|
| Nutrition | totalCalories, macros (carbs/fat/protein), micronutrients map, RDA% map, addedSugar, netCarbs, dataCompleteness (0.0-1.0) |
| Water | totalWaterML, waterGoalML, waterGoalMet (bool) |
| Weight | weightKG? (null if not logged that day) |
| Supplements | supplementsTaken (int), supplementsTotal (int), completionRate (double) |
| Habits | habitsCompleted (int), habitsTotal (int), completionRate (double) |
| Biomarkers | dietImpactScores (Map), manualReadings (List) |
| Fasting | fastingWindowHours?, fastingStart?, fastingEnd?, fastingComplete (bool) |
| Sleep | sleepDurationHours?, sleepQuality?, bedTime?, wakeTime? |
| Meal Timing | firstMealTime?, lastMealTime?, eatingWindowHours? |
| Activity | activeCaloriesBurned?, steps? |
| Gut Health | gutHealthFlagCount (int), autoFlaggedFoods (List) |
| Mood/Stress | stressScore?, moodScore? |
| Streaks | currentCleanStreak (int), isCheatDay (bool) |
| Bio Age | estimatedBioAge? (null if insufficient data) |
| Glycemic | dailyGlycemicLoad?, glClassification? |
| Omega | omega6to3Ratio? |
| Mindfulness | mindfulnessMinutes (int), sessionCount (int) |
| Plants | uniquePlantsThisWeek (int) |
| Meta | date, loggingCompleteness (0.0-1.0), dataSourceBreakdown (Map) |

### Computation Strategy

- **On-demand**: DailySummaryEntity is computed when requested (not persisted)
- Each field queries the relevant ObjectBox collection for the given date
- Null fields indicate no data (not zero) -- important distinction for AI interpretation
- `loggingCompleteness` = weighted score of how many data types were logged that day

### Caching

- Cache the current day's summary in memory (invalidate on any data change)
- Past days can be computed on-the-fly (ObjectBox queries are fast enough for 7-14 day ranges)
- If performance becomes an issue, persist DailySummaryEntity to ObjectBox as a denormalized cache

### AI-Ready Design

The entity is structured so a future AI agent can receive it as context:
- All fields are typed and documented
- Null means "not tracked" (the AI should not assume zero)
- `dataCompleteness` tells the AI how much to trust the data
- The entity can be serialized to JSON for API calls to Claude

## New Files / Collections

### New Files

- `lib/core/services/daily_summary_service.dart`
- `lib/core/domain/entity/daily_summary_entity.dart`

### No New Collections (initially)

Computed on-demand from existing collections. Optional: persist as ObjectBox entity for performance caching later.

## Modified Files

- `lib/core/di/locator.dart` -- register DailySummaryService
- Weekly Review Service (Feature Y) -- depends on DailySummaryService.buildRange()
- Longevity Insights Service (Feature V) -- uses DailySummaryEntity for cross-feature analysis
- Pattern Service (Feature R refinement) -- uses DailySummaryEntity for multi-feature correlation

## Checkpoint

- Call `buildSummary(today)` -- returns entity with all available data populated
- Null fields for categories with no data (e.g., sleep is null if not logged)
- `buildRange(monday, sunday)` returns 7 entities for the week
- `loggingCompleteness` correctly reflects what percentage of data types were logged
- Weekly review and longevity insights consume DailySummaryEntity successfully
