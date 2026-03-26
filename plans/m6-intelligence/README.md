# M6: Intelligence + Polish

## Overview

The final milestone adds nutritional intelligence (glycemic load, omega ratios, net carbs), weekly review digests, and the DailySummaryEntity that aggregates all daily data into a single structure ready for future AI coaching.

## Dependencies

- All previous milestones (M0-M5) complete
- Full data pipeline available: nutrients, biomarkers, sleep, fasting, supplements, HealthKit

## Features

| ID | Feature | Description |
|----|---------|-------------|
| W  | Glycemic + Omega + Net Carbs | Net carb calculation, omega-6:3 ratio tracking, GI/GL estimation |
| Y  | Weekly Review Digest | Sunday summary of wins, areas to improve, and week-over-week trends |
| N  | Daily Summary Entity | Aggregates ALL daily data into a single entity for future AI coaching |

## New Feature Modules

```
lib/core/services/
  daily_summary_service.dart    # DailySummaryEntity aggregation
lib/core/utils/calc/
  glycemic_calc.dart            # GI/GL lookup and calculation
lib/features/stats/presentation/widgets/
  weekly_review_widget.dart     # Weekly digest UI
```

## Checkpoint

DailySummaryEntity correctly aggregates all daily data. Glycemic load and omega ratios display on Stats. Weekly review shows wins, improvements, and trends. Pattern suggestions improve with usage history.
