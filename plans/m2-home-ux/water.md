# Feature J -- Water Tracking

## What
Simple hydration tracker on the Home page.

## Why
Hydration is a daily health fundamental. A compact, low-friction water tracker encourages consistent logging.

## How

- Compact widget: progress bar + quick buttons (+250ml, +500ml, custom)
- Daily goal configurable (default 2500ml)
- Integrates into the "Today's Progress" card on the condensed Home layout

## New files/collections
- **ObjectBox collection:** `WaterRecord` (id, amountML, dateTime)
- `lib/features/water/` -- BLoC, repository, UI widgets

## Modified files
- Home page -- embed water progress in Today's Progress card
- Settings -- daily water goal configuration
- Quick Actions bar -- "+Water" button triggers quick-add

## Checkpoint
Tapping +Water logs 250ml or 500ml. Progress bar updates. Daily goal is configurable in Settings.
