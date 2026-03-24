import 'package:opennutritracker/core/domain/entity/daily_summary_entity.dart';

class WeeklyReviewItem {
  final String text;
  final bool isWin; // true = win, false = area to improve
  final String? trend; // "up", "down", "same" for week-over-week

  WeeklyReviewItem({required this.text, required this.isWin, this.trend});
}

class WeeklyReviewResult {
  final List<WeeklyReviewItem> wins;
  final List<WeeklyReviewItem> improvements;
  final Map<String, String> trends; // metric -> "up"/"down"/"same"
  final double? avgCalories;
  final double? avgSleep;
  final double? weightChange;

  WeeklyReviewResult({
    required this.wins,
    required this.improvements,
    required this.trends,
    this.avgCalories,
    this.avgSleep,
    this.weightChange,
  });
}

class WeeklyReviewService {
  static WeeklyReviewResult generate(
    List<DailySummaryEntity> thisWeek,
    List<DailySummaryEntity> lastWeek,
  ) {
    final wins = <WeeklyReviewItem>[];
    final improvements = <WeeklyReviewItem>[];
    final trends = <String, String>{};

    final daysWithMeals = thisWeek.where((d) => d.totalCalories != null).length;
    final totalDays = thisWeek.length;

    // Logging consistency
    if (daysWithMeals >= 5) {
      wins.add(WeeklyReviewItem(
          text: 'Logged meals $daysWithMeals/$totalDays days', isWin: true));
    } else if (daysWithMeals < 3) {
      improvements.add(WeeklyReviewItem(
          text: 'Only logged meals $daysWithMeals/$totalDays days',
          isWin: false));
    }

    // Calorie tracking
    final calDays = thisWeek.where(
        (d) => d.totalCalories != null && d.calorieGoal != null);
    if (calDays.isNotEmpty) {
      final onTarget = calDays.where((d) {
        final diff = d.totalCalories! - d.calorieGoal!;
        return diff >= -1000 && diff <= 500;
      }).length;
      if (onTarget >= calDays.length * 0.6) {
        wins.add(WeeklyReviewItem(
            text: 'Hit calorie target $onTarget/${calDays.length} days',
            isWin: true));
      } else {
        improvements.add(WeeklyReviewItem(
            text: 'Calorie target hit only $onTarget/${calDays.length} days',
            isWin: false));
      }
    }

    // Sleep
    final sleepDays =
        thisWeek.where((d) => d.sleepDurationHours != null).toList();
    if (sleepDays.isNotEmpty) {
      final avgSleep = sleepDays
              .map((d) => d.sleepDurationHours!)
              .reduce((a, b) => a + b) /
          sleepDays.length;
      final good = sleepDays.where((d) => d.sleepDurationHours! >= 7).length;
      if (good >= sleepDays.length * 0.6) {
        wins.add(WeeklyReviewItem(
            text: 'Slept 7+ hours $good/${sleepDays.length} nights',
            isWin: true));
      } else {
        improvements.add(WeeklyReviewItem(
            text: 'Avg sleep ${avgSleep.toStringAsFixed(1)}h (target: 7-8h)',
            isWin: false));
      }

      // Week-over-week sleep
      final lastSleepDays =
          lastWeek.where((d) => d.sleepDurationHours != null).toList();
      if (lastSleepDays.isNotEmpty) {
        final lastAvg = lastSleepDays
                .map((d) => d.sleepDurationHours!)
                .reduce((a, b) => a + b) /
            lastSleepDays.length;
        final delta = avgSleep - lastAvg;
        trends['sleep'] = delta > 0.2 ? 'up' : delta < -0.2 ? 'down' : 'same';
      }
    }

    // Supplements
    final suppDays = thisWeek.where(
        (d) => d.supplementsTotal != null && d.supplementsTotal! > 0);
    if (suppDays.isNotEmpty) {
      final fullDays =
          suppDays.where((d) => d.supplementsTaken == d.supplementsTotal).length;
      if (fullDays >= suppDays.length * 0.6) {
        wins.add(WeeklyReviewItem(
            text: 'Completed all supplements $fullDays/${suppDays.length} days',
            isWin: true));
      } else {
        improvements.add(WeeklyReviewItem(
            text: 'Missed supplements ${suppDays.length - fullDays} days',
            isWin: false));
      }
    }

    // Habits
    final habitDays =
        thisWeek.where((d) => d.habitsTotal != null && d.habitsTotal! > 0);
    if (habitDays.isNotEmpty) {
      final fullDays =
          habitDays.where((d) => d.habitsCompleted == d.habitsTotal).length;
      if (fullDays >= habitDays.length * 0.6) {
        wins.add(WeeklyReviewItem(
            text: 'Completed all habits $fullDays/${habitDays.length} days',
            isWin: true));
      }
    }

    // Gut health
    final gutDays = thisWeek.where(
        (d) => d.gutHealthFlagCount != null && d.gutHealthFlagCount! > 0);
    final cleanDays = daysWithMeals - gutDays.length;
    if (cleanDays >= daysWithMeals * 0.6 && daysWithMeals > 0) {
      wins.add(WeeklyReviewItem(
          text: 'Clean eating $cleanDays/$daysWithMeals days', isWin: true));
    } else if (gutDays.length >= 3) {
      improvements.add(WeeklyReviewItem(
          text: 'Gut-harmful items flagged ${gutDays.length} days',
          isWin: false));
    }

    // Weight trend
    final thisWeights =
        thisWeek.where((d) => d.weightKG != null).map((d) => d.weightKG!);
    final lastWeights =
        lastWeek.where((d) => d.weightKG != null).map((d) => d.weightKG!);
    double? weightChange;
    if (thisWeights.isNotEmpty && lastWeights.isNotEmpty) {
      weightChange = thisWeights.last - lastWeights.last;
      trends['weight'] = weightChange > 0.3
          ? 'up'
          : weightChange < -0.3
              ? 'down'
              : 'same';
    }

    // Average calories
    double? avgCalories;
    if (calDays.isNotEmpty) {
      avgCalories = calDays
              .map((d) => d.totalCalories!)
              .reduce((a, b) => a + b) /
          calDays.length;
    }

    return WeeklyReviewResult(
      wins: wins,
      improvements: improvements,
      trends: trends,
      avgCalories: avgCalories,
      avgSleep: sleepDays.isNotEmpty
          ? sleepDays
                  .map((d) => d.sleepDurationHours!)
                  .reduce((a, b) => a + b) /
              sleepDays.length
          : null,
      weightChange: weightChange,
    );
  }
}
