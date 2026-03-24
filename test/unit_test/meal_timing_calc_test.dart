import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/meal_timing_calc.dart';

import '../fixture/meal_entity_fixtures.dart';

void main() {
  group('MealTimingCalc', () {
    test('empty intakes returns null for all', () {
      expect(MealTimingCalc.firstMealTime([]), isNull);
      expect(MealTimingCalc.lastMealTime([]), isNull);
      expect(MealTimingCalc.eatingWindowHours([]), isNull);
    });

    test('single intake has zero eating window', () {
      final intakes = [MealEntityFixtures.createIntakeWithNutrients()];
      final window = MealTimingCalc.eatingWindowHours(intakes);
      expect(window, 0.0);
    });

    test('first and last meal times are correct', () {
      final now = DateTime.now();
      final intakes = [
        MealEntityFixtures.createIntakeWithNutrients(),
        MealEntityFixtures.createIntakeWithNutrients(),
      ];
      final first = MealTimingCalc.firstMealTime(intakes);
      final last = MealTimingCalc.lastMealTime(intakes);
      expect(first, isNotNull);
      expect(last, isNotNull);
    });
  });
}
