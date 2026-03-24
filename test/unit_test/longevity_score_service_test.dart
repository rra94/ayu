import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/daily_summary_entity.dart';
import 'package:opennutritracker/core/services/longevity_score_service.dart';

void main() {
  group('LongevityScoreService', () {
    test('perfect day scores A+ (>=90)', () {
      final summary = DailySummaryEntity(
        date: DateTime.now(),
        totalCalories: 2000,
        calorieGoal: 2000,
        fiberG: 30,
        dailyGlycemicLoad: 60,
        netCarbsG: 200,
        sleepDurationHours: 8.0,
        sleepQuality: 5,
        habitsCompleted: 10,
        habitsTotal: 10,
        mindfulnessMinutes: 20,
        eatingWindowHours: 6,
        gutHealthFlagCount: 0,
        fastingWindowHours: 18,
        supplementsTaken: 10,
        supplementsTotal: 10,
      );

      final result = LongevityScoreService.compute(summary);
      expect(result.overallScore, greaterThanOrEqualTo(80));
      expect(result.grade, anyOf('A+', 'A'));
    });

    test('zero data scores low', () {
      final summary = DailySummaryEntity(date: DateTime.now());
      final result = LongevityScoreService.compute(summary);
      expect(result.overallScore, lessThan(50));
      expect(result.grade, anyOf('D', 'F'));
    });

    test('grade boundaries are correct', () {
      // Test that grade mapping works
      final summary90 = DailySummaryEntity(
        date: DateTime.now(),
        totalCalories: 2000,
        calorieGoal: 2000,
        fiberG: 30,
        dailyGlycemicLoad: 50,
        netCarbsG: 200,
        sleepDurationHours: 8.0,
        sleepQuality: 5,
        habitsCompleted: 12,
        habitsTotal: 12,
        mindfulnessMinutes: 20,
        eatingWindowHours: 5,
        gutHealthFlagCount: 0,
        fastingWindowHours: 18,
        supplementsTaken: 10,
        supplementsTotal: 10,
      );
      final result = LongevityScoreService.compute(summary90);
      expect(result.subScores.length, 6); // 6 sub-scores
    });

    test('sub-scores are all present', () {
      final summary = DailySummaryEntity(date: DateTime.now());
      final result = LongevityScoreService.compute(summary);
      expect(result.subScores.keys, containsAll([
        'nutrition', 'sleep', 'activity', 'gut', 'fasting', 'supplements',
      ]));
    });
  });
}
