import 'package:opennutritracker/core/domain/entity/daily_summary_entity.dart';

class LongevityScoreResult {
  final int overallScore; // 0-100
  final Map<String, _SubScore> subScores;

  LongevityScoreResult({required this.overallScore, required this.subScores});

  String get grade {
    if (overallScore >= 90) return 'A+';
    if (overallScore >= 80) return 'A';
    if (overallScore >= 70) return 'B';
    if (overallScore >= 60) return 'C';
    if (overallScore >= 50) return 'D';
    return 'F';
  }
}

class _SubScore {
  final String name;
  final int score; // 0-100
  final String detail;

  _SubScore({required this.name, required this.score, required this.detail});
}

class LongevityScoreService {
  /// Compute a longevity score from today's summary.
  static LongevityScoreResult compute(DailySummaryEntity summary) {
    final scores = <String, _SubScore>{};

    // 1. Nutrition quality (calorie adherence + fiber + low sugar)
    int nutritionScore = 50;
    if (summary.totalCalories != null && summary.calorieGoal != null) {
      final ratio = summary.totalCalories! / summary.calorieGoal!;
      if (ratio >= 0.8 && ratio <= 1.1) nutritionScore += 20;
      else if (ratio >= 0.6 && ratio <= 1.3) nutritionScore += 10;
    }
    if (summary.fiberG != null && summary.fiberG! >= 25) nutritionScore += 15;
    if (summary.netCarbsG != null && summary.dailyGlycemicLoad != null) {
      if (summary.dailyGlycemicLoad! < 80) nutritionScore += 15;
    }
    scores['nutrition'] = _SubScore(
      name: 'Nutrition',
      score: nutritionScore.clamp(0, 100),
      detail: summary.totalCalories != null
          ? '${summary.totalCalories!.round()} kcal'
          : 'No meals logged',
    );

    // 2. Sleep score
    int sleepScore = 0;
    if (summary.sleepDurationHours != null) {
      final hours = summary.sleepDurationHours!;
      if (hours >= 7 && hours <= 9) sleepScore = 100;
      else if (hours >= 6) sleepScore = 70;
      else sleepScore = 30;
      if (summary.sleepQuality != null) {
        sleepScore = (sleepScore * 0.7 + summary.sleepQuality! * 6).round();
      }
    }
    scores['sleep'] = _SubScore(
      name: 'Sleep',
      score: sleepScore.clamp(0, 100),
      detail: summary.sleepDurationHours != null
          ? '${summary.sleepDurationHours!.toStringAsFixed(1)}h'
          : 'Not logged',
    );

    // 3. Activity score (based on what we have)
    int activityScore = 0;
    if (summary.habitsCompleted != null && summary.habitsTotal != null) {
      final pct = summary.habitsTotal! > 0
          ? summary.habitsCompleted! / summary.habitsTotal!
          : 0.0;
      activityScore = (pct * 60).round();
    }
    if (summary.mindfulnessMinutes != null && summary.mindfulnessMinutes! > 0) {
      activityScore += 20;
    }
    if (summary.eatingWindowHours != null && summary.eatingWindowHours! <= 8) {
      activityScore += 20;
    }
    scores['activity'] = _SubScore(
      name: 'Activity & Habits',
      score: activityScore.clamp(0, 100),
      detail: '${summary.habitsCompleted ?? 0}/${summary.habitsTotal ?? 0} habits',
    );

    // 4. Gut health score
    int gutScore = 100;
    if (summary.gutHealthFlagCount != null) {
      gutScore = (100 - summary.gutHealthFlagCount! * 15).clamp(0, 100);
    }
    scores['gut'] = _SubScore(
      name: 'Gut Health',
      score: gutScore,
      detail: summary.gutHealthFlagCount != null
          ? '${summary.gutHealthFlagCount} flags'
          : 'Clean',
    );

    // 5. Fasting score
    int fastingScore = 0;
    if (summary.fastingWindowHours != null) {
      if (summary.fastingWindowHours! >= 16) fastingScore = 100;
      else if (summary.fastingWindowHours! >= 14) fastingScore = 80;
      else if (summary.fastingWindowHours! >= 12) fastingScore = 50;
    }
    scores['fasting'] = _SubScore(
      name: 'Fasting',
      score: fastingScore,
      detail: summary.fastingWindowHours != null
          ? '${summary.fastingWindowHours!.toStringAsFixed(1)}h'
          : 'No fast',
    );

    // 6. Supplement adherence
    int suppScore = 0;
    if (summary.supplementsTaken != null && summary.supplementsTotal != null &&
        summary.supplementsTotal! > 0) {
      suppScore = (summary.supplementsTaken! / summary.supplementsTotal! * 100).round();
    }
    scores['supplements'] = _SubScore(
      name: 'Supplements',
      score: suppScore.clamp(0, 100),
      detail: '${summary.supplementsTaken ?? 0}/${summary.supplementsTotal ?? 0}',
    );

    // Overall = weighted average
    final weights = {
      'nutrition': 25,
      'sleep': 25,
      'activity': 15,
      'gut': 15,
      'fasting': 10,
      'supplements': 10,
    };

    double totalWeighted = 0;
    int totalWeight = 0;
    for (final entry in scores.entries) {
      final w = weights[entry.key] ?? 10;
      totalWeighted += entry.value.score * w;
      totalWeight += w;
    }

    final overall = totalWeight > 0 ? (totalWeighted / totalWeight).round() : 0;

    return LongevityScoreResult(
      overallScore: overall.clamp(0, 100),
      subScores: scores,
    );
  }
}
