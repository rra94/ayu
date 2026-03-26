# M4: Longevity Suite

## Overview

The Longevity Suite adds health-span oriented tracking features: supplements, fasting, sleep, meal timing, streaks, and NSDR/meditation. All features depend on M0 (ObjectBox + modular architecture) being complete.

## Features

| ID | Feature | Description |
|----|---------|-------------|
| F  | Supplements | Barcode auto-detect + manual supplement stack with daily checklist |
| G  | Fasting Timer | Circular countdown timer with protocol presets (16:8, 18:6, OMAD) |
| K  | Sleep Tracking | Bedtime/wake logging, quality score, 7-day trends |
| L  | Meal Timing | Circadian eating window visualization on a 24h clock |
| Q  | Streaks | Cheat meal streak tracker with configurable thresholds |
| -  | NSDR Timer | Non-Sleep Deep Rest / meditation countdown timer |

## Dependencies

- M0 complete (ObjectBox collections, modular feature folders, service layer)
- New ObjectBox collections: Supplement, SupplementLog, FastingSession, SleepRecord, MindfulnessSession

## New Feature Modules

```
lib/features/
  supplements/
  fasting/
  sleep/
  meal_timing/
  streaks/
```

## Checkpoint

Supplement checklist, fasting timer, sleep logging, meal timing clock, streaks, and NSDR timer all functional on iPhone. Each feature has its own BLoC, data source, and Stats card.
