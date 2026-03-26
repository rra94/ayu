# Bristol Stool Scale Logger

## What
Track digestive health via the Bristol Stool Scale (BSS) -- a medical classification system for stool form (types 1-7).

## Why
Stool form is a simple, validated proxy for digestive transit time and gut health. Types 3-4 are ideal. Tracking trends helps users correlate diet changes with digestive outcomes, especially when combined with the Food-to-Feeling engine.

## How

**Types:** 1 (hard lumps) through 7 (watery). Types 3-4 are ideal.

**UI:**
- Quick log: visual scale with 7 icons (medical standard illustrations), tap to log
- Accessible from Home "Today's Progress" or via Quick Actions
- Stats page: 7-day and 30-day distribution chart (are you trending toward 3-4?)
- Correlates with Food-to-Feeling engine: e.g., "Type 6 stools are 2x more likely after high-fiber meals"

## New files/collections
- **ObjectBox collection:** `StoolLog` (id, type: 1-7, dateTime, notes?)
- `lib/features/gut_health/presentation/widgets/bristol_stool_logger.dart` -- visual scale picker
- `lib/features/stats/presentation/widgets/bristol_stool_chart.dart` -- distribution chart

## Modified files
- Home page -- optional quick-log access via Today's Progress or Quick Actions
- Stats tab -- Bristol Stool distribution card
- `food_feeling_service.dart` -- integrate stool type as an additional correlation data point

## Checkpoint
Tapping a stool type icon logs the entry. Stats shows a 7-day/30-day distribution chart. Correlations with food intake appear after sufficient data.
