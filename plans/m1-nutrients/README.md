# M1: Nutrient Pipeline

**Depends on:** M0

## What
Build a complete nutrient tracking pipeline: micronutrients with RDA targets, added sugar tracking, multi-source data resolution with completeness scoring, Nutritionix API integration, and a nutrient synergy checker.

## Why
The current app discards vitamin and mineral data at the entity layer. Users need full micronutrient visibility, data quality indicators, and actionable absorption tips to make informed dietary decisions.

## Sub-features

| ID | Feature | Plan File |
|----|---------|-----------|
| B | Micronutrient Tracking + RDA Targets | [micronutrients.md](micronutrients.md) |
| P | Added Sugar Tracking | [added-sugar.md](added-sugar.md) |
| M | Data Source Resolution | [data-resolution.md](data-resolution.md) |
| S | Nutritionix API (with caching) | [nutritionix.md](nutritionix.md) |
| NEW | Nutrient Synergy Checker | [synergy-checker.md](synergy-checker.md) |

## Checkpoint
Scan a food and see full micronutrient table with completeness badge. FDC products show added sugar. Nutritionix search works. Nutrient synergy tips appear after logging meals.
