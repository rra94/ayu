# NSDR / Meditation Timer

## What

A simple countdown timer for Non-Sleep Deep Rest (NSDR), meditation, breathwork, and yoga nidra sessions with history tracking.

## Why

Bryan Johnson does daily NSDR for recovery and cognitive performance. Andrew Huberman recommends NSDR as a daily practice. Rather than switching to a separate meditation app, users can track mindfulness alongside their other health data and auto-complete the "meditation" habit in their daily checklist.

## How

### Timer

- User selects session type: NSDR, meditation, breathwork, yoga nidra, custom
- User selects duration: presets (5 min, 10 min, 20 min, 30 min) or custom
- Countdown timer with circular progress gauge
- Completion chime (haptic + optional sound)
- Session logged automatically on completion
- Early exit: prompt "Save partial session?" -> logs actual elapsed time

### Presets

| Type | Default Duration |
|------|-----------------|
| NSDR | 10 min |
| Meditation | 20 min |
| Breathwork | 5 min |
| Yoga Nidra | 30 min |

### Habit Integration

- When a session completes, auto-check the corresponding habit in the daily habits checklist (Feature H)
- Mapping: NSDR/meditation/yoga_nidra -> "meditation" habit; breathwork -> "breathwork" habit (if configured)

### Optional: Ambient Sounds

- Silent mode (default)
- Rain, singing bowls, white noise (future enhancement, low priority)
- Audio assets kept minimal to avoid app size bloat

## New Files / Collections

### ObjectBox Collection

- `MindfulnessSession` -- id, type (enum: nsdr, meditation, breathwork, yoga_nidra, custom), durationMinutes (int), dateTime

### New Files

- `lib/features/mindfulness/data/dbo/mindfulness_session_dbo.dart`
- `lib/features/mindfulness/data/data_source/mindfulness_data_source.dart`
- `lib/features/mindfulness/bloc/mindfulness_bloc.dart`
- `lib/features/mindfulness/bloc/mindfulness_event.dart`
- `lib/features/mindfulness/bloc/mindfulness_state.dart`
- `lib/features/mindfulness/presentation/widgets/mindfulness_timer_widget.dart`
- `lib/features/mindfulness/presentation/widgets/mindfulness_history_widget.dart`
- `lib/features/mindfulness/presentation/widgets/mindfulness_stats_card.dart`

## Modified Files

- Home page -- quick access button or Today's Progress integration
- Stats page -- mindfulness session history card (sessions this week, total minutes)
- Habits BLoC -- listen for mindfulness session completion, auto-check habit

## Checkpoint

- Select "NSDR 10 min", start timer, see countdown with circular gauge
- Complete session -- logged to history, "meditation" habit auto-checked
- End session early -- prompted to save partial session
- Stats card shows sessions this week and total minutes
