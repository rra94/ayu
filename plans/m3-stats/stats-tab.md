# Feature D -- Stats Tab Shell

## What
New 4th navigation tab (between Diary and Profile) that serves as the scrollable container for all stats cards.

## Why
Stats and trends are currently scattered or missing. A dedicated tab provides a single place for all health metrics and trends.

## How

- Add Stats at navigation index 2; Profile moves to index 3.
- Scrollable layout with cards for each metric area.

**Card layout (top to bottom):**
1. TDEE / BMR card
2. Weight chart
3. Nutrient %RDA
4. Diet impact
5. Added sugar
6. Supplements
7. Biomarkers
8. Sleep
9. Meal timing
10. Fasting
11. Streaks
12. DEXA
13. Food-to-Feeling correlations
14. Bristol Stool distribution

Each card is a self-contained widget loaded by the StatsBloc coordinator.

## New files
- `lib/features/stats/` -- StatsBloc (coordinator), stats page, card widget slots

## Modified files
- `main_screen.dart` -- add Stats tab at index 2, shift Profile to index 3
- Bottom navigation bar -- add Stats icon

## Checkpoint
Stats tab appears in navigation. Scrolling shows placeholder cards for all metric areas. Profile tab still works at its new index.
