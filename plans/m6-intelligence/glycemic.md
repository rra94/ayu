# Feature W -- Net Carbs + Omega Ratio + Glycemic Index/Load

## What

Three advanced nutritional metrics: net carb calculation, omega-6:omega-3 ratio tracking, and glycemic index/load estimation per meal and per day.

## Why

These metrics are central to metabolic health and longevity:
- **Net carbs** matter more than total carbs for blood sugar impact (fiber and sugar alcohols don't spike glucose)
- **Omega-6:3 ratio** is a key inflammation marker -- Western diets average 15:1, optimal is <4:1
- **Glycemic load** predicts blood sugar response better than carb count alone

## How

### Net Carbs

- Formula: `netCarbs = totalCarbs - fiber - sugarAlcohols`
- Add `sugarAlcohols100` field to MealNutriments (FDC nutrient ID: 1086)
- Display net carbs alongside total carbs in:
  - Daily summary dashboard
  - Meal detail nutriments table
  - Stats nutrient breakdown

### Omega-6:Omega-3 Ratio

- FDC nutrient IDs: omega-6 (1316), omega-3 (1404, or EPA 1278 + DHA 1272)
- Add `omega6_100` and `omega3_100` fields to MealNutriments
- Calculate daily ratio: `totalOmega6 / totalOmega3`
- Traffic light on Stats:
  - Green: <4:1
  - Yellow: 4:1 -- 10:1
  - Red: >10:1
- Show as "Omega Ratio: 6.2:1" card on Stats page

### Glycemic Index / Load

New file `lib/core/utils/calc/glycemic_calc.dart`:

- GI data is NOT available in FDC/OFF APIs directly
- Use a hardcoded lookup table of ~200 common foods -> GI values (sourced from published GI databases: University of Sydney, Harvard Health)
- Match logged foods to lookup table by name/category (fuzzy matching)
- Per-meal GL calculation: `mealGL = sum(food_GI * carbs_per_serving / 100)` for each food in the meal
- Daily GL: sum of all meal GLs
- Classification: Low GL (<10 per meal, <80 per day), Medium (10-19, 80-120), High (>20, >120)
- If a food has no GI match, exclude from GL calculation and note "partial estimate"

### UI

- Stats page: dedicated "Glycemic" card showing daily GL with classification badge
- Meal detail: per-meal GL shown below macros
- Stats page: "Omega Balance" card with ratio and traffic light
- Daily summary: net carbs shown alongside total carbs

## New Files / Collections

### New Files

- `lib/core/utils/calc/glycemic_calc.dart` -- GI lookup table + GL calculation
- `lib/core/utils/calc/glycemic_index_data.dart` -- hardcoded food -> GI mapping (~200 entries)
- `lib/features/stats/presentation/widgets/glycemic_card.dart`
- `lib/features/stats/presentation/widgets/omega_ratio_card.dart`

### No New Collections

Extends existing MealNutriments with new fields: sugarAlcohols100, omega6_100, omega3_100.

## Modified Files

- `MealNutriments` ObjectBox entity -- add sugarAlcohols100, omega6_100, omega3_100 fields
- `MealNutrimentsEntity` -- add perUnit getters for new fields, netCarbs computed property
- `fdc_const.dart` -- add nutrient IDs for sugar alcohols (1086), omega-6 (1316), omega-3 (1404/1278/1272)
- Meal detail nutriments table -- show net carbs, omega values, per-meal GL
- Stats page -- add Glycemic card and Omega Ratio card
- Daily summary dashboard -- show net carbs

## Checkpoint

- Log a meal with known GI foods -- per-meal GL appears in meal detail
- Daily GL classification shown on Stats (Low/Medium/High)
- Omega ratio card shows ratio with traffic light color
- Net carbs displayed alongside total carbs in dashboard and meal detail
