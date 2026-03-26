# Feature R -- Pattern Auto-Logging

## What
Learn eating routines from history and offer one-tap auto-log suggestions. Anti-laziness feature.

## Why
Most people eat similar meals on similar days. Detecting patterns and offering one-tap logging reduces friction to near zero for routine meals.

## How

**Analysis (pure Dart, no ML):**
- Analyze 30-day intake history via ObjectBox queries
- Detect: day-of-week patterns, frequency patterns, meal combos
- Threshold: meal appears >60% of relevant days to trigger a suggestion

**Smart timing windows:**
- Breakfast: 6-9 AM
- Lunch: 11 AM - 1 PM
- Dinner: 5-8 PM

**UI:** Card at top of Home: "Your usual Monday breakfast?" with "Log it" / "Not today" buttons. Dismissible; only appears when a pattern is detected and the timing is relevant.

## New files
- `lib/core/services/meal_pattern_service.dart` -- frequency analysis, pattern detection, suggestion generation
- `lib/features/patterns/` -- BLoC, UI widgets (suggestion card)

## Modified files
- Home page -- pattern suggestion card (conditional, dismissible)

## Checkpoint
After 30 days of data, pattern suggestions appear at the correct time of day. Tapping "Log it" logs the suggested meal. "Not today" dismisses the card.
