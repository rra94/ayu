import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/services/bioavailability_service.dart';

import '../fixture/meal_entity_fixtures.dart';

void main() {
  group('BioavailabilityService', () {
    test('empty intakes returns empty results', () {
      final results = BioavailabilityService.computeAll([]);
      expect(results, isEmpty);
    });

    test('iron absorption is between 2-35%', () {
      final intakes = [MealEntityFixtures.createIntakeWithNutrients(iron100: 10.0)];
      final results = BioavailabilityService.computeAll(intakes);
      final iron = results.where((r) => r.nutrient == 'Iron').firstOrNull;
      if (iron != null) {
        expect(iron.absorptionPct, greaterThanOrEqualTo(2.0));
        expect(iron.absorptionPct, lessThanOrEqualTo(35.0));
        expect(iron.absorbedMg, lessThan(iron.consumedMg));
      }
    });

    test('vitamin C enhances iron absorption', () {
      final withoutC = [MealEntityFixtures.createIntakeWithNutrients(
        iron100: 10.0, vitaminC100: 0, fiber100: 0, amount: 100,
      )];
      final withC = [MealEntityFixtures.createIntakeWithNutrients(
        iron100: 10.0, vitaminC100: 50.0, fiber100: 0, amount: 100,
      )];

      final resultsWithout = BioavailabilityService.computeAll(withoutC);
      final resultsWith = BioavailabilityService.computeAll(withC);

      final ironWithout = resultsWithout.where((r) => r.nutrient == 'Iron').firstOrNull;
      final ironWith = resultsWith.where((r) => r.nutrient == 'Iron').firstOrNull;

      expect(ironWithout, isNotNull);
      expect(ironWith, isNotNull);
      expect(ironWith!.absorptionPct, greaterThan(ironWithout!.absorptionPct));
    });

    test('calcium absorption is between 5-40%', () {
      final intakes = [MealEntityFixtures.createIntakeWithNutrients(calcium100: 300.0)];
      final results = BioavailabilityService.computeAll(intakes);
      final calcium = results.where((r) => r.nutrient == 'Calcium').firstOrNull;
      if (calcium != null) {
        expect(calcium.absorptionPct, greaterThanOrEqualTo(5.0));
        expect(calcium.absorptionPct, lessThanOrEqualTo(40.0));
      }
    });
  });
}
