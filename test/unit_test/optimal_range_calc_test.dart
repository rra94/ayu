import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/optimal_range_calc.dart';

void main() {
  group('OptimalRangeCalc', () {
    test('has all major biomarker categories', () {
      final categories = OptimalRangeCalc.getByCategory();
      expect(categories.keys, containsAll([
        'Metabolic', 'Lipids', 'Inflammation', 'Blood', 'Hormonal',
        'Longevity', 'Fitness', 'Body',
      ]));
    });

    test('getDefinition returns known biomarker', () {
      final def = OptimalRangeCalc.getDefinition('fasting_glucose');
      expect(def, isNotNull);
      expect(def!.name, 'Fasting Glucose');
      expect(def.unit, 'mg/dL');
    });

    test('getDefinition returns null for unknown', () {
      expect(OptimalRangeCalc.getDefinition('nonexistent'), isNull);
    });

    test('getRating returns 2 for optimal value', () {
      final def = OptimalRangeCalc.getDefinition('fasting_glucose')!;
      expect(def.getRating(80), 2); // 80 is in optimal 72-85
    });

    test('getRating returns 1 for normal-not-optimal', () {
      final def = OptimalRangeCalc.getDefinition('fasting_glucose')!;
      expect(def.getRating(95), 1); // 95 is normal (70-100) but not optimal
    });

    test('getRating returns 0 for out of range', () {
      final def = OptimalRangeCalc.getDefinition('fasting_glucose')!;
      expect(def.getRating(110), 0); // 110 is above normal range
    });

    test('has body measurement biomarkers', () {
      expect(OptimalRangeCalc.getDefinition('waist'), isNotNull);
      expect(OptimalRangeCalc.getDefinition('bicep'), isNotNull);
      expect(OptimalRangeCalc.getDefinition('vo2_max'), isNotNull);
    });

    test('all biomarkers have valid ranges', () {
      for (final b in OptimalRangeCalc.biomarkers) {
        expect(b.normalLow, lessThanOrEqualTo(b.normalHigh),
            reason: '${b.key} normalLow should be <= normalHigh');
        expect(b.optimalLow, greaterThanOrEqualTo(b.normalLow),
            reason: '${b.key} optimalLow should be >= normalLow');
        expect(b.optimalHigh, lessThanOrEqualTo(b.normalHigh),
            reason: '${b.key} optimalHigh should be <= normalHigh');
      }
    });
  });
}
