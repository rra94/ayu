# HRV-Late-Meal Correlation

## What

Correlate overnight heart rate variability (HRV) from Apple Watch with late-meal timing to quantify the impact of eating close to bedtime on recovery.

## Why

Research shows that eating within 2-3 hours of bedtime reduces overnight HRV (a key recovery and longevity biomarker). This feature turns abstract advice ("don't eat late") into personalized, data-backed evidence: "Your HRV is 15% higher when you stop eating 3+ hours before bed."

## How

### Data Requirements

- HealthKit HRV data (Feature O must be active with Apple Watch)
- Meal timing data (last meal timestamp from Feature L)
- Sleep data (bedtime from Feature K or HealthKit)
- Minimum 14 data points (nights) before showing any correlation

### Correlation Logic

New file `lib/core/services/hrv_meal_service.dart`:

1. For each night with both HRV and meal data:
   - Calculate `gap = bedtime - lastMealTime` (in hours)
   - Record overnight HRV average (from HealthKit sleep window)
2. Bucket nights into two groups:
   - "Early dinner" = gap >= 3 hours
   - "Late dinner" = gap < 3 hours
3. Compare average HRV between groups
4. Compute percentage difference and statistical significance (simple t-test or just count-based confidence)

### Insight Generation

- If >= 14 data points and >= 5 in each bucket:
  - "Your overnight HRV averages {X} ms on early-dinner nights vs {Y} ms on late-dinner nights ({Z}% difference)"
- If insufficient data:
  - "Tracking HRV vs. meal timing... {N}/14 nights recorded. Keep logging!"
- Show as insight card on Stats page under "Longevity Insights"

### Privacy

- All computation is on-device
- HRV data never leaves the device
- No cloud dependency

## New Files / Collections

### New Files

- `lib/core/services/hrv_meal_service.dart`
- `lib/features/health_connect/presentation/widgets/hrv_correlation_card.dart`

### No New Collections

Reads from existing BiometricRecord (HRV), Intake (last meal time), and SleepRecord (bedtime).

## Modified Files

- Stats page -- add HRV correlation insight card (conditionally shown when enough data exists)
- `longevity_insights_service.dart` -- include HRV-meal correlation in insights list

## Checkpoint

- With 14+ nights of Apple Watch HRV data and logged meals, insight card appears on Stats
- Card shows HRV comparison between early-dinner and late-dinner nights
- With insufficient data, shows progress indicator toward 14-night threshold
