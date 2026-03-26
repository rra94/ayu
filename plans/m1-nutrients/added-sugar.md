# Feature P -- Added Sugar Tracking

## What
Track added sugar separately from total sugar and flag excessive intake.

## Why
Total sugar includes naturally occurring sugars (fruit, milk). Added sugar is the health-relevant metric. WHO recommends <25g/day; users need visibility into this.

## How

- FDC nutrient ID 1235 = "Added Sugars" -- extract from FDC responses
- OFF: no reliable added sugar field -- mark as "N/A" or estimate
- Add `addedSugars100` to the nutrient model (per 100g)
- Flag if daily added sugar exceeds 25g (WHO guideline)
- Display added sugar alongside total sugar in daily summary and meal detail

## New files
None.

## Modified files
- `MealNutriments` ObjectBox collection -- add `addedSugars100` field
- `MealNutrimentsEntity` -- add field + getter
- `fdc_const.dart` -- add nutrient ID 1235
- Daily summary widget -- show added sugar with warning threshold

## Checkpoint
FDC products display added sugar. Daily total shows a warning when added sugar exceeds 25g.
