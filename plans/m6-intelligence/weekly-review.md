# Feature Y -- Weekly Review Digest

## What

A summary screen showing the past week's health wins, areas for improvement, trends, and week-over-week comparison. Automatically shown on Sunday, accessible anytime from Stats.

## Why

Daily tracking can feel like noise without periodic reflection. A weekly digest synthesizes 7 days of data into a clear "how did I do?" narrative that reinforces good habits and highlights blind spots.

## How

### Trigger

- Automatically shown as a modal/bottom sheet when the app is opened on Sunday (configurable day in Settings)
- Dismissible -- user can skip or snooze
- Always accessible via Stats tab: "Weekly Review" button

### Content Sections

**Wins** (positive reinforcement):
- "Hit fiber target 5/7 days"
- "Logged meals 6/7 days"
- "15-day clean streak!"
- "Slept 8+ hours 4 nights"
- "Completed all supplements 5/7 days"

**Areas to Improve** (non-judgmental, actionable):
- "Sodium was high 3 days (avg 3,200mg vs 2,300mg target)"
- "Missed supplements Tuesday and Thursday"
- "Eating window averaged 8.2h (target: 5h)"
- "Only 2.1L water average (target: 2.5L)"

**Trends** (directional):
- Weight change this week: +0.3 kg / -0.5 kg / stable
- Average calorie intake vs goal: 2,180 / 2,250 (97%)
- Average sleep duration: 7.4h

**Week-over-Week Comparison**:
- "Fiber intake improved 12% vs last week"
- "Sleep duration declined 0.3h vs last week"
- Arrows: up (improved), down (declined), horizontal (same)

### Data Source

Uses `DailySummaryService` to aggregate 7 days of DailySummaryEntity data. Compares current week (Mon-Sun) vs. previous week.

### Generation Logic

New file `lib/features/stats/services/weekly_review_service.dart`:
- Query 14 days of DailySummaryEntity (this week + last week)
- For each metric, compute: average, target hit count, week-over-week delta
- Categorize into wins (hit target >60% of days) and improvements (missed target >40% of days)
- Sort wins by streak/consistency, improvements by severity

## New Files / Collections

### New Files

- `lib/features/stats/services/weekly_review_service.dart`
- `lib/features/stats/presentation/widgets/weekly_review_widget.dart`
- `lib/features/stats/presentation/widgets/weekly_review_section.dart` (reusable section: wins, improvements, trends)
- `lib/features/stats/bloc/weekly_review_bloc.dart`
- `lib/features/stats/bloc/weekly_review_event.dart`
- `lib/features/stats/bloc/weekly_review_state.dart`

### No New Collections

Reads from DailySummaryEntity (aggregated by DailySummaryService from all existing collections).

## Modified Files

- Stats page -- add "Weekly Review" access button
- App startup logic -- check if Sunday + review not yet shown this week -> present modal
- Settings -- configure review day (default Sunday), enable/disable auto-show
- Config collection -- add lastWeeklyReviewShown (DateTime), weeklyReviewDay (int)

## Checkpoint

- Open app on Sunday -- weekly review modal appears with wins and improvements
- Dismiss and reopen -- does not show again until next week
- Access review anytime from Stats tab
- Week-over-week arrows show correct direction for each metric
- Review content matches actual logged data from the past 7 days
