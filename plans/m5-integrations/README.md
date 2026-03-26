# M5: Integrations

## Overview

The Integrations milestone connects the app to external data sources (Apple HealthKit) and surfaces data via iOS system-level widgets. It also introduces cross-feature correlation analysis (HRV vs. meal timing) and rule-based longevity insights.

## Dependencies

- M3 complete (Stats tab, biomarkers with optimal ranges)
- M4 complete (sleep, meal timing, fasting data available for correlation)

## Features

| ID | Feature | Description |
|----|---------|-------------|
| O  | Apple HealthKit | Sync weight, steps, workouts, sleep, heart rate from HealthKit |
| -  | HRV-Late-Meal Correlation | Correlate overnight HRV with late-meal timing |
| V  | Longevity Insights | Rule-based actionable insights from biomarker data |
| Z  | iOS Lock Screen Widget | WidgetKit widget showing daily metrics on Lock Screen |

## New Dependencies

```yaml
health: ^11.0.0
home_widget: ^0.7.0
```

## New Feature Modules

```
lib/features/
  health_connect/    # HealthKit sync
ios/
  NutriWidget/       # WidgetKit extension (SwiftUI)
```

## Checkpoint

HealthKit sync works on iPhone. HRV-meal correlation insight appears after 14+ data points. Lock Screen widget shows daily calorie gauge. Longevity insights surface on Stats page.
