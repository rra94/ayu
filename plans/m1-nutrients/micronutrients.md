# Feature B -- Micronutrient Tracking + RDA Targets

## What
Capture vitamins and minerals from FDC/OFF APIs (currently discarded at entity layer) and display them with RDA percentage targets.

## Why
Users cannot see vitamin/mineral intake. Without micronutrient data, the app is limited to macro tracking and misses a core nutrition use case.

## How

Expand the nutrient model with 23 new fields:

**Minerals:** sodium, potassium, calcium, iron, magnesium, phosphorus, zinc, copper, manganese, selenium

**Vitamins:** A (RAE), C, D, E, K, B1, B2, B3, B5, B6, B9, B12

**Other:** cholesterol

- Add fields to `MealNutriments` ObjectBox collection and `MealNutrimentsEntity`
- Add `perUnit` getters to entity
- Map FDC nutrient IDs (1087-1185) in `fdc_const.dart`
- Map OFF micronutrient keys in `off_product_nutriments_dto.dart`
- Build expandable Vitamins/Minerals sections in `meal_detail_nutriments_table.dart`

## New files
- `lib/core/utils/calc/rda_calc.dart` -- NIH DRI values by gender/age, returns `Map<String, double>`

## Modified files
- `MealNutriments` ObjectBox collection -- add 23 fields
- `MealNutrimentsEntity` -- add fields + `perUnit` getters
- `fdc_const.dart` -- add nutrient IDs (1087-1185)
- `off_product_nutriments_dto.dart` -- add OFF micronutrient keys
- `meal_detail_nutriments_table.dart` -- expandable Vitamins/Minerals sections

## Checkpoint
Scanning a food shows a full micronutrient table with values and RDA percentages.
