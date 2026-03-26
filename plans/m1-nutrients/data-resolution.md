# Feature M -- Data Source Resolution

## What
Priority system for nutrient data, completeness scoring, and "fill from similar" estimation for missing values.

## Why
Different data sources have different coverage. Users need to know how complete their nutrient data is and have a way to fill gaps without manual research.

## How

**Priority chain:** FDC > Nutritionix > OFF > Custom

**Null handling:**
- `null` = unknown (not 0)
- Display "--" for unknown values
- Do not count unknown values in RDA percentage calculations

**Completeness badge:**
- Green: >80% fields populated
- Yellow: 30-80% fields populated
- Gray: <30% fields populated

**"Fill from similar" button:**
- Search FDC for the closest match to the current food
- Fill missing fields from that match
- Mark filled values as "estimated"

**Manual override:** Any nutrient value can be manually overridden by the user.

## New files
- `lib/core/services/nutrient_resolver.dart` -- priority resolution, completeness scoring, fill-from-similar logic

## Modified files
- Meal detail UI -- add completeness badge, "fill from similar" button, manual override controls

## Checkpoint
Foods show a completeness badge. "Fill from similar" fills missing nutrient values. Manual overrides persist.
