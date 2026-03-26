# Blueprint Mode Toggle

## What
One-tap toggle that loads Bryan Johnson's full Blueprint protocol as the active configuration.

## Why
Blueprint is a well-defined, publicly documented longevity protocol. Providing a one-tap preset saves users hours of manual configuration and serves as a reference protocol.

## How

**When enabled:**
- Calorie target: 2,250 kcal/day
- Eating window: 6:00 AM - 11:00 AM (strict)
- Supplement stack: auto-loads Johnson's full supplement list as active supplements
- Biomarker optimal ranges: uses Blueprint's strict longevity targets (tighter than standard)
- Habits: auto-adds Blueprint habits (red light therapy, cold exposure, specific skincare protocol)
- Sleep target: 8+ hours, 8:30 PM bedtime
- Fasting: 18:6 protocol auto-configured

**UI:** Toggle in Settings at "Blueprint Mode". Shows warning: "This loads Bryan Johnson's protocol. Your current settings will be saved and can be restored."
- Saves current config as backup before switching
- "Exit Blueprint Mode" restores previous settings

## New files
- `lib/features/settings/services/blueprint_mode_service.dart` -- config backup/restore, Blueprint preset values
- Blueprint preset data (supplement list, habit list, target values)

## Modified files
- Settings screen -- add "Blueprint Mode" toggle with confirmation dialog
- Config collection -- add blueprint mode flag + backup storage

## Checkpoint
Enabling Blueprint Mode sets calorie target to 2,250, eating window to 6-11 AM, and loads the full supplement/habit list. Disabling restores previous settings.
