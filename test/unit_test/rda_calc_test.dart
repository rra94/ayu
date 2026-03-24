import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/rda_calc.dart';

void main() {
  group('RDACalc', () {
    test('returns targets for male', () {
      final targets = RDACalc.getDailyTargets(gender: 0, age: 30);
      expect(targets['potassium'], 3400);
      expect(targets['iron'], 8);
      expect(targets['protein'], 56);
      expect(targets['calcium'], 1000);
    });

    test('returns targets for female', () {
      final targets = RDACalc.getDailyTargets(gender: 1, age: 30);
      expect(targets['potassium'], 2600);
      expect(targets['iron'], 18);
      expect(targets['protein'], 46);
    });

    test('all expected nutrients are present', () {
      final targets = RDACalc.getDailyTargets(gender: 0, age: 30);
      expect(targets.keys, containsAll([
        'sodium', 'potassium', 'calcium', 'iron', 'magnesium',
        'zinc', 'vitaminC', 'vitaminD', 'vitaminB12', 'folate',
        'fiber', 'fat', 'carbs', 'protein',
      ]));
    });

    test('all values are positive', () {
      final targets = RDACalc.getDailyTargets(gender: 0, age: 30);
      for (final entry in targets.entries) {
        expect(entry.value, greaterThan(0),
            reason: '${entry.key} should be > 0');
      }
    });

    test('age affects vitamin B6 target', () {
      final young = RDACalc.getDailyTargets(gender: 0, age: 30);
      final old = RDACalc.getDailyTargets(gender: 0, age: 55);
      expect(old['vitaminB6'], greaterThan(young['vitaminB6']!));
    });
  });
}
