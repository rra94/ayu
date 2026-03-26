# Feature K -- Sleep Tracking

## What

Manual sleep logging (bedtime, wake time, quality score) with trend visualization. Designed to be supplemented by HealthKit auto-import in M5.

## Why

Sleep is the single highest-leverage longevity variable. Tracking bedtime consistency and duration helps users maintain a regular circadian rhythm -- a core tenet of Bryan Johnson's Blueprint protocol (8:30 PM bedtime target).

## How

### Manual Logging

- Log bedtime and wake time (time pickers, default to yesterday 10 PM -> today 6 AM)
- Quality score: 1-5 stars (subjective)
- Optional notes field (e.g., "woke up twice", "took melatonin")
- Duration auto-calculated from bed/wake times
- Handle cross-midnight bedtimes correctly

### Trend Visualization

- 7-day bar chart showing sleep duration per night
- Horizontal target line (configurable, default 8h)
- Quality stars below each bar
- Bedtime consistency: show bedtime dot plot (are you going to bed at the same time?)
- Weekly average duration and quality

### HealthKit Prep

- Data model is compatible with HealthKit sleep data (M5 Feature O will auto-import)
- When HealthKit is connected, manual entries are supplemented (not replaced) by auto data
- Source field on SleepRecord: "manual" or "healthkit"

## New Files / Collections

### ObjectBox Collection

- `SleepRecord` -- id, bedTime (DateTime), wakeTime (DateTime), qualityScore (int, 1-5), notes (String?), source (String)

### New Files

- `lib/features/sleep/data/dbo/sleep_record_dbo.dart`
- `lib/features/sleep/data/data_source/sleep_data_source.dart`
- `lib/features/sleep/bloc/sleep_bloc.dart`
- `lib/features/sleep/bloc/sleep_event.dart`
- `lib/features/sleep/bloc/sleep_state.dart`
- `lib/features/sleep/presentation/widgets/sleep_log_dialog.dart`
- `lib/features/sleep/presentation/widgets/sleep_stats_card.dart`
- `lib/features/sleep/presentation/widgets/sleep_trend_chart.dart`

## Modified Files

- Stats page -- add sleep card showing last night's sleep + 7-day trend
- Home page -- optionally show last night's sleep summary in Today's Progress
- Settings -- configurable sleep target (default 8h) and bedtime target (default 10:00 PM)

## Checkpoint

- Log sleep manually with bed/wake time and quality
- See 7-day trend chart with duration bars and quality stars
- Bedtime consistency dot plot visible
- Weekly averages computed correctly
