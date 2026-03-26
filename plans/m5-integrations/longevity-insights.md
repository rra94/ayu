# Feature V -- Optimal Ranges + Longevity Insights

## What

A rule-based insights engine that analyzes biomarker data against longevity-optimal ranges and generates actionable health recommendations. All computation is on-device.

## Why

Users who log biomarkers need more than raw numbers -- they need context. Standard medical "normal" ranges are designed to detect disease, not optimize health. Longevity-optimal ranges (inspired by Longevity Coach, Peter Attia, Bryan Johnson) are tighter and more actionable. This feature bridges the gap between data collection and behavior change.

## How

### Optimal Range System

Extends Feature E's biomarker ranges with a two-tier system:
- **Normal range**: standard medical reference (e.g., fasting glucose 70-100 mg/dL)
- **Optimal range**: longevity-optimized (e.g., fasting glucose 72-85 mg/dL)
- Color coding: red (out of normal) -> yellow (normal but not optimal) -> green (optimal)

### Insight Engine

New file `lib/core/services/longevity_insights_service.dart`:

1. **Biomarker insights**: Analyze each biomarker against optimal range
   - "Your fasting glucose (92) is normal but not optimal (target: 72-85). Consider reducing refined carbs."
   - "Your vitamin D (22 ng/mL) is below optimal (40-60). Consider 2000-5000 IU D3 daily."
   - "Your omega-6:3 ratio (12:1) is high. Target <4:1. Increase fish/flax, reduce seed oils."

2. **Cross-feature insights**: Combine data from multiple features
   - Sleep + calories: "On days you sleep <7h, you eat 18% more calories"
   - Fasting + weight: "Your weight trends down during weeks with >5 fasting sessions"
   - Supplements + biomarkers: "Your vitamin D improved from 22 to 45 ng/mL since starting D3 supplementation"

3. **Supplement suggestions**: Based on deficiencies
   - Low vitamin D -> suggest D3
   - High inflammation (CRP) -> suggest omega-3, curcumin
   - Low magnesium -> suggest magnesium glycinate

### Rule Format

```dart
class InsightRule {
  final String biomarker;
  final double optimalMin;
  final double optimalMax;
  final String belowMessage;
  final String aboveMessage;
  final String? supplementSuggestion;
}
```

Rules are hardcoded from peer-reviewed sources. Future enhancement: RAG-powered with Claude API.

### UI

- Stats page: "Longevity Insights" expandable card
- Each insight is a dismissible card with icon, message, and optional action
- Insights are prioritized: red (urgent) > yellow (improvement) > green (positive reinforcement)
- "No insights yet" state when insufficient biomarker data

## New Files / Collections

### New Files

- `lib/core/services/longevity_insights_service.dart`
- `lib/core/utils/calc/optimal_range_data.dart` (lookup table of biomarker optimal ranges)
- `lib/features/stats/presentation/widgets/longevity_insights_card.dart`
- `lib/features/stats/presentation/widgets/insight_tile.dart`

### No New Collections

Reads from existing BiometricRecord, SleepRecord, Intake, SupplementLog collections.

## Modified Files

- Stats page -- add Longevity Insights card section
- Biomarker detail views -- show optimal range alongside normal range
- `optimal_range_calc.dart` (from Feature E) -- extend with full longevity-optimal dataset

## Checkpoint

- Enter biomarker values (e.g., fasting glucose 92, vitamin D 22)
- Longevity Insights card shows actionable recommendations
- Insights are color-coded by priority (red/yellow/green)
- Cross-feature insights appear when enough multi-feature data exists
