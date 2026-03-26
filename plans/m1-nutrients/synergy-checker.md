# Nutrient Synergy Checker

## What
Flag synergistic and antagonistic nutrient pairings in the same meal or day.

## Why
Nutrient absorption is heavily influenced by what is eaten together. Users benefit from actionable tips on pairing (or separating) nutrients -- backed by peer-reviewed research.

## How

**Synergistic pairs (boost absorption):**
- Vitamin C + Iron -- "Great combo! Vitamin C boosts iron absorption"
- Vitamin D + Calcium -- "Vitamin D helps calcium absorption"
- Fat + fat-soluble vitamins (A, D, E, K) -- "Fat in this meal helps absorb vitamins A/D/E/K"
- Vitamin B12 + Folate -- work together for red blood cell formation

**Antagonistic pairs (block absorption):**
- Calcium + Iron -- "Calcium in this meal may reduce iron absorption by 50%"
- Coffee/tea (tannins) + Iron -- "Tannins block iron. Wait 1 hour after meal"
- Phytates (grains/legumes) + Zinc/Iron -- "Phytates reduce mineral absorption"
- High-dose Zinc + Copper -- "Long-term high zinc depletes copper"

**UI:** Show as subtle, dismissible cards after logging a meal: "Nutrient tip: ..."

**Data source:** Hardcoded lookup table of known interactions from peer-reviewed sources. No ML required.

## New files
- `lib/core/services/nutrient_synergy_service.dart` -- interaction lookup, pair detection, tip generation

## Modified files
- Meal logging confirmation screen -- display synergy/antagonism tips after a meal is logged

## Checkpoint
After logging a meal containing iron and vitamin C, a synergy tip appears. After logging calcium and iron together, an antagonism warning appears. Tips are dismissible.
