# Feature E -- Biomarkers (Auto + Manual + Optimal Ranges)

## What
Two-mode biomarker tracking: auto-computed from food intake (daily) and manual lab result entry. Both use traffic-light color coding with standard and longevity-optimal ranges.

## Why
Biomarkers are the ground truth for health. Auto-computed diet biomarkers give daily feedback. Manual lab results track long-term trends. Optimal ranges (tighter than standard medical ranges) target longevity, not just absence of disease.

## How

### Auto-computed from food (daily)
Dietary cholesterol, sodium, omega-3, saturated fat, fiber, sugar, potassium, calcium, iron. Traffic light (green/yellow/red) based on AHA/WHO guidelines.

### Manual lab results
Blood tests, hormones, inflammation markers entered by the user.

### Biomarker categories
Cardiovascular, Metabolic, Lipids, Inflammation, Hormonal, Body composition, Liver/Kidney, Blood, Stress (perceived stress 1-10, cortisol, sleep quality, anxiety, mood), Longevity, Custom.

### Optimal Ranges (from Longevity Coach)
For each biomarker, define TWO ranges:
- **Normal range** -- standard medical reference (e.g., fasting glucose 70-100 mg/dL)
- **Optimal range** -- longevity-optimized (e.g., fasting glucose 72-85 mg/dL)

Color code: red (out of normal) -> yellow (normal but not optimal) -> green (optimal).

Source: Longevity Coach methodology + published research. Display both ranges on biomarker cards.

## New files/collections
- **ObjectBox collection:** `BiometricRecord` (id, type, value, unit, dateTime, source)
- `lib/core/utils/calc/optimal_range_calc.dart` -- normal and optimal range definitions per biomarker, color coding logic
- `lib/features/biomarkers/` -- BLoC, repository, biomarker card widgets, lab entry dialog

## Modified files
- Stats tab -- biomarker cards section
- Intake logging -- trigger auto-computed biomarker recalculation

## Checkpoint
Auto-computed biomarkers update after logging food. Manual lab results can be entered. Each biomarker shows red/yellow/green against both normal and optimal ranges.
