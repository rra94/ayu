import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/streak_service.dart';

import '../fixture/meal_entity_fixtures.dart';

void main() {
  group('StreakService', () {
    test('empty intakes returns zero streak', () {
      final result = StreakService.computeStreak([]);
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.monthlyCheatCount, 0);
    });

    test('consecutive clean days yield correct streak', () {
      final intakes = MealEntityFixtures.createMultiDayIntakes(
        days: 5, kcalPerMeal: 400,
      );
      final result = StreakService.computeStreak(intakes);
      expect(result.currentStreak, 5);
      expect(result.longestStreak, 5);
    });

    test('high calorie meal is flagged as cheat', () {
      // energyKcal100=900 with amount=100 = 900kcal total, over 800 threshold
      final intakes = MealEntityFixtures.createMultiDayIntakes(
        days: 1, kcalPerMeal: 900, startDaysAgo: 0,
      );
      // Override amount to 100 so totalKcal = 900
      final result = StreakService.computeStreak(intakes, calorieThreshold: 5);
      expect(result.monthlyCheatCount, greaterThan(0));
    });

    test('motivational text changes at thresholds', () {
      expect(
        StreakService.computeStreak(
          MealEntityFixtures.createMultiDayIntakes(days: 1, kcalPerMeal: 400),
        ).motivationalText,
        'Keep going!',
      );
      expect(
        StreakService.computeStreak(
          MealEntityFixtures.createMultiDayIntakes(days: 8, kcalPerMeal: 400),
        ).motivationalText,
        'Strong week!',
      );
      expect(
        StreakService.computeStreak(
          MealEntityFixtures.createMultiDayIntakes(days: 31, kcalPerMeal: 400),
        ).motivationalText,
        'Amazing discipline!',
      );
    });
  });
}
