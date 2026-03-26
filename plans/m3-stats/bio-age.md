# Feature U -- Biological Age Calculation

## What
Calculate estimated biological age from lab biomarkers and lifestyle factors. Display alongside chronological age on Stats.

## Why
Biological age is the single most compelling metric for longevity tracking. It answers "how old is my body really?" and motivates protocol adherence.

Inspired by: [BioAge](https://github.com/dayoonkwon/BioAge), [Biolearn](https://www.biorxiv.org/content/10.1101/2023.12.02.569722v4.full)

## How

### Phenotypic Age (Levine 2018)
Uses: albumin, creatinine, glucose, CRP, lymphocyte %, MCV, RDW, ALP, WBC + chronological age. Requires all 9 markers for full calculation.

### Simplified estimate
Uses available biomarkers + lifestyle factors (exercise, sleep, BMI). Works with partial data.

### Display
"Chronological age: 35 | Biological age: 31" on Stats page.

### Empty state handling (critical)
Most users get blood work 1-2x/year. The UI must NOT look like a broken dashboard of missing data 95% of the time.

- **0 markers entered:** "Add your first blood work results to calculate biological age" with a CTA button to enter lab results.
- **Partial markers (1-8 of 9):** "Estimated bio age: ~32 (based on 4/9 markers). Add more for accuracy: [albumin] [CRP] [ALP]..." -- list the specific missing markers.
- **All 9 markers entered:** Full Phenotypic Age calculation with confidence indicator.

## New files
- `lib/core/utils/calc/biological_age_calc.dart` -- Phenotypic Age formula, simplified estimate, missing-marker detection

## Modified files
- Stats tab -- biological age card with progressive empty states
- Biomarker entry flow -- highlight which markers are needed for bio age

## Checkpoint
With 0 markers, a friendly CTA appears. With partial markers, an estimate shows with a list of missing markers. With all 9, the full Phenotypic Age displays with confidence.
