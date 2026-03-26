# Feature Q -- Cheat Meal Streak

## What

Track consecutive "clean" days and surface streak statistics. A cheat meal is configurable: calorie threshold, added sugar threshold, or manual tag.

## Why

Streak tracking is a proven behavior reinforcement mechanism. Seeing "15-day clean streak" motivates continued adherence. Configurable thresholds mean the feature works for any diet philosophy, not just calorie counting.

## How

### Cheat Meal Definition (configurable)

A meal is flagged as a "cheat" if ANY of the following are true:
- Single meal exceeds calorie threshold (default: >800 kcal)
- Single meal exceeds added sugar threshold (default: >20g)
- User manually tags the meal as cheat

A "clean day" is any day with zero cheat meals.

### Streak Calculation

Query intake data and compute:
- **Current streak** -- consecutive clean days ending today (or yesterday if today has no meals yet)
- **Longest streak** -- all-time record
- **Monthly cheat count** -- number of cheat meals this calendar month
- **Cheat frequency** -- "1 cheat meal every 8 days" (rolling 90-day average)

### Data Source

No new ObjectBox collection. Uses existing Intake data with threshold checks. Streak state is computed on-the-fly from intake queries (cacheable in memory for the current session).

### UI

- Stats page: Streak card showing current streak (large number), longest streak, monthly cheat count
- Motivational text: "Keep going!" at <7 days, "Strong week!" at 7+, "Amazing discipline!" at 30+
- Streak break notification: "Your 12-day streak ended. Start a new one!"
- Cheat meals are highlighted (not shamed) in the diary view with a subtle tag

## New Files / Collections

### New Files

- `lib/features/streaks/services/streak_service.dart`
- `lib/features/streaks/bloc/streak_bloc.dart`
- `lib/features/streaks/bloc/streak_event.dart`
- `lib/features/streaks/bloc/streak_state.dart`
- `lib/features/streaks/presentation/widgets/streak_stats_card.dart`

### No New Collections

Computed from existing Intake data + configurable thresholds stored in Config.

## Modified Files

- Config collection -- add cheatCalorieThreshold (int, default 800), cheatSugarThreshold (int, default 20)
- Stats page -- add streak card
- Diary page -- subtle "cheat" tag on flagged meals
- Settings -- configurable cheat thresholds under "Streaks"
- Intake logging -- option to manually tag a meal as cheat

## Checkpoint

- Log meals over several days; streak counter increments for clean days
- Log a meal over 800 kcal; streak resets, cheat count increments
- Stats card shows current streak, longest streak, monthly cheat count
- Change thresholds in Settings; streak recalculates
