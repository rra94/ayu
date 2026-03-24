import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/glycemic_calc.dart';
import 'package:opennutritracker/core/utils/calc/glycemic_index_data.dart';

import '../fixture/meal_entity_fixtures.dart';

void main() {
  group('GlycemicIndexData', () {
    test('looks up known foods', () {
      expect(GlycemicIndexData.lookup('white rice'), 73);
      expect(GlycemicIndexData.lookup('banana'), 51);
      expect(GlycemicIndexData.lookup('chicken breast'), 0);
      expect(GlycemicIndexData.lookup('lentil soup'), 32);
    });

    test('returns null for unknown foods', () {
      expect(GlycemicIndexData.lookup('xyzfood123'), isNull);
    });

    test('case insensitive matching', () {
      expect(GlycemicIndexData.lookup('WHITE RICE'), 73);
      expect(GlycemicIndexData.lookup('Banana'), 51);
    });
  });

  group('GlycemicCalc', () {
    test('empty intakes returns zero GL', () {
      final result = GlycemicCalc.dailyGL([]);
      expect(result.glycemicLoad, 0);
      expect(result.matchedFoods, 0);
      expect(result.classification, 'Low');
    });

    test('daily GL classification thresholds', () {
      expect(GlycemicCalc.classifyMeal(5), 'Low');
      expect(GlycemicCalc.classifyMeal(15), 'Medium');
      expect(GlycemicCalc.classifyMeal(25), 'High');
    });

    test('net carbs calculation', () {
      expect(GlycemicCalc.netCarbs(totalCarbs100: 50, fiber100: 10), 40);
      expect(GlycemicCalc.netCarbs(totalCarbs100: 50, fiber100: null), 50);
      expect(GlycemicCalc.netCarbs(totalCarbs100: null, fiber100: 10), isNull);
      expect(GlycemicCalc.netCarbs(
        totalCarbs100: 50, fiber100: 10, sugarAlcohols100: 5,
      ), 35);
    });

    test('omega ratio calculation', () {
      expect(GlycemicCalc.omegaRatio(omega6Total: 12, omega3Total: 3), 4.0);
      expect(GlycemicCalc.omegaRatio(omega6Total: null, omega3Total: 3), isNull);
      expect(GlycemicCalc.omegaRatio(omega6Total: 12, omega3Total: 0), isNull);
    });

    test('omega ratio classification', () {
      expect(GlycemicCalc.classifyOmegaRatio(3), 'Optimal');
      expect(GlycemicCalc.classifyOmegaRatio(6), 'Moderate');
      expect(GlycemicCalc.classifyOmegaRatio(15), 'High');
    });
  });
}
