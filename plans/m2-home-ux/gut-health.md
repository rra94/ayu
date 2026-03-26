# Feature A -- Gut Health Panel

## What
Auto-flag gut-harmful foods from logged intake plus a manual checklist for additional gut-harmful items.

## Why
Gut health is foundational to longevity. Automatically surfacing problematic foods and tracking manual gut stressors helps users make better choices without extra research.

## How

**Auto-flag rules:**
- Sugar > 15g/100g
- Fiber < 1g/100g

**Predefined manual items:** artificial sweeteners, alcohol, processed foods, NSAIDs, refined sugar, emulsifiers, fried foods, artificial coloring.

**UI:** Alert panel on Home that only appears when there are flags. Shows count of alerts (e.g., "Gut Health (2 alerts)"). Tapping expands to show details.

## New files/collections
- **ObjectBox collection:** `GutHealthItem` (id, name, category, dateTime, isAutoFlagged, sourceIntakeId?)
- `lib/features/gut_health/` -- BLoC, repository, auto-flag logic, UI widgets

## Modified files
- Home page -- conditional gut health alert panel (only visible when alerts exist)
- Intake logging flow -- run auto-flag check after each food is logged

## Checkpoint
Logging a high-sugar food triggers an auto-flag. Gut health alerts appear on Home. Manual items can be checked off. Panel hides when there are no flags.
