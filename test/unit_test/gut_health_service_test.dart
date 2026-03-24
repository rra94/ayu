import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/gut_health_service.dart';

import '../fixture/meal_entity_fixtures.dart';

void main() {
  group('GutHealthService', () {
    final service = GutHealthService();

    test('empty intakes returns empty flags', () {
      final result = service.flagFromIntakes([]);
      expect(result, isEmpty);
    });

    test('high sugar food is flagged', () {
      final intakes = [
        MealEntityFixtures.createIntakeWithNutrients(
          energyKcal100: 400,
          amount: 1,
        ),
      ];
      // Default sugar in fixture is 5g/100g, below 15g threshold
      final result = service.flagFromIntakes(intakes);
      final sugarFlags = result.where((r) => r.category == 'high_sugar');
      expect(sugarFlags, isEmpty); // 5g < 15g threshold
    });

    test('food with many additives flagged as ultra-processed', () {
      final intakes = [
        MealEntityFixtures.createIntakeWithAdditives(
          name: 'Chips',
          additives: ['en:e150d', 'en:e621', 'en:e211', 'en:e322', 'en:e471', 'en:e951'],
        ),
      ];
      final result = service.flagFromIntakes(intakes);
      final upfFlags = result.where((r) => r.category == 'ultra_processed');
      expect(upfFlags, isNotEmpty);
    });

    test('known UPF keyword is flagged', () {
      final intakes = [
        MealEntityFixtures.createIntakeWithAdditives(
          name: 'Doritos Cool Ranch',
          additives: [],
        ),
      ];
      final result = service.flagFromIntakes(intakes);
      final upfFlags = result.where((r) => r.category == 'ultra_processed');
      expect(upfFlags, isNotEmpty);
    });

    test('additive e407 flagged as emulsifier', () {
      final intakes = [
        MealEntityFixtures.createIntakeWithAdditives(
          name: 'Ice Cream',
          additives: ['en:e407'],
        ),
      ];
      final result = service.flagFromIntakes(intakes);
      final emulsifierFlags = result.where((r) => r.category == 'emulsifier');
      expect(emulsifierFlags, isNotEmpty);
    });

    test('multiple additives in same category grouped', () {
      final intakes = [
        MealEntityFixtures.createIntakeWithAdditives(
          name: 'Processed Food',
          additives: ['en:e433', 'en:e466', 'en:e407'], // 3 emulsifiers
        ),
      ];
      final result = service.flagFromIntakes(intakes);
      final emulsifierFlags = result.where((r) => r.category == 'emulsifier');
      // Should be 1 grouped flag, not 3 separate
      expect(emulsifierFlags.length, 1);
      expect(emulsifierFlags.first.name, contains('3 emulsifiers'));
    });
  });
}
