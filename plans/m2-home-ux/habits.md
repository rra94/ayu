# Feature H -- Daily Habits Checklist

## What
Bryan Johnson-style daily routine tracker with a compact checklist on the Home page.

## Why
Longevity protocols involve many daily habits beyond nutrition. A checklist keeps users accountable and shows completion progress at a glance.

## How

**Predefined habits:** face wash AM/PM, moisturizer, sunscreen, minoxidil, brush AM/PM, floss, mouthwash, hair oiling, meditation, cold exposure, morning workout, stretching. All customizable -- users can add, remove, or rename.

**UI:** Compact checklist on Home showing checkboxes + "8/12 done" progress. Integrates into the "Today's Progress" card.

## New files/collections
- **ObjectBox collections:**
  - `Habit` (id, name, category, icon, isActive, frequency)
  - `HabitLog` (id, habitId, dateTime, completed)
- `lib/features/habits/` -- BLoC, repository, UI widgets

## Modified files
- Home page -- embed habit progress in Today's Progress card
- Settings -- manage habits list (add, edit, remove, reorder)

## Checkpoint
Habit checklist displays on Home. Tapping a checkbox logs completion. Progress shows "X/Y done". Habits are customizable in Settings.
