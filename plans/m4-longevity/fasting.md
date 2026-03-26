# Feature G -- Fasting Timer

## What

A start/stop fasting timer with protocol presets, circular countdown visualization, and session history.

## Why

Intermittent fasting is central to most longevity protocols (16:8, 18:6, OMAD). Users need a built-in timer rather than switching to a separate fasting app, especially since meal timing data already lives in this app.

## How

### Timer Logic

- User selects a protocol (16:8, 18:6, 20:4, OMAD, custom hours) and taps Start
- Timer counts up from start time; circular gauge shows progress toward target hours
- When target is reached, show completion notification
- User can end the fast early (partial session is still logged)
- Persist running timer state so it survives app restarts

### Protocol Presets

| Protocol | Fast | Eat |
|----------|------|-----|
| 16:8     | 16h  | 8h  |
| 18:6     | 18h  | 6h  |
| 20:4     | 20h  | 4h  |
| OMAD     | 23h  | 1h  |
| Custom   | Nh   | -   |

### Integration with Meal Timing (Feature L)

- If a meal is logged while a fast is active, warn: "You have an active fast. End fast and log meal?"
- Auto-end fast when first meal of the day is logged (configurable)

## New Files / Collections

### ObjectBox Collection

- `FastingSession` -- id, startTime, endTime?, targetHours, type (enum: sixteen_eight, eighteen_six, twenty_four, omad, custom)

### New Files

- `lib/features/fasting/data/dbo/fasting_session_dbo.dart`
- `lib/features/fasting/data/data_source/fasting_data_source.dart`
- `lib/features/fasting/bloc/fasting_bloc.dart`
- `lib/features/fasting/bloc/fasting_event.dart`
- `lib/features/fasting/bloc/fasting_state.dart`
- `lib/features/fasting/presentation/widgets/fasting_timer_widget.dart`
- `lib/features/fasting/presentation/widgets/fasting_history_widget.dart`
- `lib/features/fasting/presentation/widgets/fasting_stats_card.dart`

## Modified Files

- Home page -- "Today's Progress" card shows fasting status: "Fasting 14h / 16h" with progress bar
- Stats page -- fasting history card with session list and average window
- Intake logging flow -- check for active fast and prompt accordingly

## Checkpoint

- Start a 16:8 fast, see circular timer counting up
- Close and reopen app -- timer persists
- Complete the fast -- session saved to history
- Stats card shows average fasting window and session history
