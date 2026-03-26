# 30 Plants a Week Tracker

## What
Track plant food diversity for microbiome health. Research shows eating 30+ different plant foods per week dramatically improves gut microbiome diversity.

## Why
The American Gut Project found that people who eat 30+ different plants per week have significantly more diverse gut microbiomes than those who eat fewer than 10. This feature gamifies plant diversity.

## How

- Auto-detect plant-based foods from logged intakes (fruits, vegetables, legumes, grains, nuts, seeds, herbs/spices)
- Each unique plant = 1 point (e.g., banana, spinach, lentils, oats = 4 plants)
- Same plant eaten multiple times in a week counts only once
- Weekly counter on Home "Today's Progress" card: "Plants: 18/30 this week"
- Visual: grid of 30 circles, filled in as new plants are logged -- satisfying completion UI
- Uses FDC/OFF food categories to classify what counts as a "plant"

**Classification:** food is classified as a plant via category keywords: vegetable, fruit, legume, grain, nut, seed, herb, spice.

## New files
- `lib/features/gut_health/services/plant_diversity_service.dart` -- analyzes 7-day rolling intake window, maintains unique plant food set, classifies foods via category keywords

## Modified files
- Home page Today's Progress card -- add "Plants: X/30 this week" line
- Optional: dedicated 30-plant grid view accessible by tapping the counter

## Checkpoint
Logging a banana and spinach shows "Plants: 2/30 this week". Logging banana again does not increment. Grid view fills circles as unique plants are logged.
