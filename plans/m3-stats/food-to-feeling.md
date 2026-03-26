# Food-to-Feeling Correlation Engine

## What
Correlate symptom logs (brain fog, bloating, energy crash, headache, etc.) with preceding food intake to identify personal trigger foods.

## Why
Food sensitivities are highly individual. Doctors often recommend elimination diets, but few people follow through. Automated correlation analysis surfaces trigger foods from normal eating patterns without requiring a restrictive protocol.

## How

**Symptom types (enum):** brain_fog, bloating, gas, energy_crash, headache, heartburn, skin_breakout, joint_pain, mood_low, anxiety, insomnia, custom.

**Correlation logic:**
- When user logs a symptom, look back 2-6 hours at food intake
- Over time (30+ data points), calculate correlation scores
- Simple frequency analysis (not ML): for each symptom, count how often each food/food-category precedes it vs baseline
- Example output: "Bloating appears 3x more often after dairy products"

**UI:**
- Quick symptom log: banner at bottom of Home "How are you feeling?" with tap-to-select symptom icons
- Stats page: "Food-to-Feeling" card showing top correlations ranked by strength
- Meal detail: if a food has been flagged as a potential trigger, show a subtle warning

## New files/collections
- **ObjectBox collection:** `SymptomLog` (id, symptom: enum, severity: 1-5, dateTime, notes?)
- `lib/core/services/food_feeling_service.dart` -- lookback window analysis, frequency counting, correlation scoring
- `lib/features/stats/presentation/widgets/food_feeling_card.dart` -- correlation display widget

## Modified files
- Home page -- "How are you feeling?" quick-log banner
- Stats tab -- Food-to-Feeling correlation card
- Meal detail screen -- subtle trigger warning for flagged foods

## Checkpoint
Logging a symptom records it with timestamp. After 30+ symptom logs, the Food-to-Feeling card shows ranked correlations. Flagged foods show warnings in meal detail.
