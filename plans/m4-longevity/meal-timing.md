# Feature L -- Meal Timing / Circadian

## What

Visualize daily eating patterns on a 24-hour clock. Calculate eating window duration, flag out-of-window meals, and help users maintain a consistent circadian eating schedule.

## Why

Time-restricted eating improves metabolic health markers. The Bryan Johnson Blueprint targets a 6 AM -- 11 AM eating window. Users need to see their actual eating window vs. their target to build consistency.

## How

### Data Source

No new ObjectBox collection needed. Uses existing intake timestamps from the Intake collection. Queries all intakes for a given day and extracts meal times.

### Calculations

New file `lib/core/utils/calc/meal_timing_calc.dart`:
- `firstMealTime(day)` -- earliest intake timestamp
- `lastMealTime(day)` -- latest intake timestamp
- `eatingWindowHours(day)` -- duration between first and last meal
- `isOutsideWindow(intake, targetStart, targetEnd)` -- returns true if intake falls outside configured window
- `averageEatingWindow(days)` -- 7-day or 30-day average window

### 24-Hour Clock Visualization

- Circular 24h clock face (0-24 hours)
- Colored arc showing the eating window (first meal to last meal)
- Target window shown as a lighter background arc
- Individual meal dots plotted on the clock
- Out-of-window meals highlighted in red
- Center text: "Eating window: 5.2h" and "Target: 5h"

### Configuration

- Target eating window start/end (default: 6:00 AM -- 11:00 AM for Blueprint)
- Configurable in Settings under "Meal Timing"
- Option to receive a notification if logging a meal outside the window

## New Files / Collections

### New Files

- `lib/core/utils/calc/meal_timing_calc.dart`
- `lib/features/meal_timing/bloc/meal_timing_bloc.dart`
- `lib/features/meal_timing/bloc/meal_timing_event.dart`
- `lib/features/meal_timing/bloc/meal_timing_state.dart`
- `lib/features/meal_timing/presentation/widgets/circadian_clock_widget.dart`
- `lib/features/meal_timing/presentation/widgets/meal_timing_stats_card.dart`

### No New Collections

Relies entirely on existing Intake timestamps.

## Modified Files

- Stats page -- add meal timing card with 24h clock
- Intake logging flow -- check if meal is outside configured window, show warning
- Settings -- add meal timing configuration (target window start/end)
- Home "Today's Progress" -- optionally show eating window status

## Checkpoint

- Log meals at various times throughout the day
- See 24h clock with eating window arc and meal dots
- Out-of-window meals flagged in red on the clock
- Stats card shows eating window duration and 7-day average
- Configure a custom target window in Settings
