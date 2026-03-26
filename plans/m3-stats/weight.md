# Feature C -- Weight History + Target + ETA

## What
Weight tracking with history chart, target line, and estimated time to goal.

## Why
Weight is the most common health metric users track. A target line and ETA provide motivation and expectation setting.

## How

- Line chart (fl_chart) showing weight over time
- Horizontal target line on the chart
- ETA text: `weeksToGoal = abs(current - target) / 0.45` (safe rate of ~1 lb/week)
- Log weight entries and delete entries
- Target weight stored in Config

## New files/collections
- **ObjectBox collection:** `WeightRecord` (id, weightKG, dateTime)
- `lib/core/utils/calc/weight_goal_calc.dart` -- ETA calculation
- `lib/features/weight/` -- BLoC, repository, chart widget

## Modified files
- Config collection -- add `targetWeightKG` field
- Stats tab -- weight chart card
- Settings -- target weight input

## Checkpoint
Logging weight entries shows a line chart on Stats. Target line is visible. ETA text displays weeks to goal. Entries can be deleted.
