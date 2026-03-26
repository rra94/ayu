import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/nutrient_synergy_service.dart';

void main() {
  group('NutrientSynergyService', () {
    test('iron + vitaminC is an enhancer', () {
      final tips = NutrientSynergyService.checkSynergies({
        'iron': true,
        'vitaminC': true,
      });
      expect(
          tips.any((t) =>
              t.type == 'enhancer' &&
              t.nutrientA == 'iron' &&
              t.nutrientB == 'vitaminC'),
          true);
    });

    test('calcium + iron is an inhibitor', () {
      final tips = NutrientSynergyService.checkSynergies({
        'calcium': true,
        'iron': true,
      });
      expect(tips.any((t) => t.type == 'inhibitor'), true);
    });

    test('vitaminD + calcium is an enhancer', () {
      final tips = NutrientSynergyService.checkSynergies({
        'vitaminD': true,
        'calcium': true,
      });
      expect(
          tips.any((t) => t.type == 'enhancer' && t.nutrientA == 'vitaminD'),
          true);
    });

    test('fat-soluble vitamins need fat', () {
      for (final v in ['vitaminA', 'vitaminD', 'vitaminE', 'vitaminK']) {
        final tips =
            NutrientSynergyService.checkSynergies({v: true, 'fat': true});
        expect(
            tips.any(
                (t) => t.type == 'enhancer' && t.message.contains('fat')),
            true,
            reason: '$v + fat');
      }
    });

    test('zinc + copper is an inhibitor', () {
      final tips = NutrientSynergyService.checkSynergies({
        'zinc': true,
        'copper': true,
      });
      expect(
          tips.any((t) =>
              t.type == 'inhibitor' &&
              t.nutrientA == 'zinc' &&
              t.nutrientB == 'copper'),
          true);
    });

    test('no matching nutrients returns empty', () {
      final tips = NutrientSynergyService.checkSynergies({
        'potassium': true,
      });
      expect(tips, isEmpty);
    });

    test('buildPresenceMap works correctly', () {
      final map = NutrientSynergyService.buildPresenceMap(
          iron: 5, calcium: 0, vitaminC: 2);
      expect(map['iron'], true);
      expect(map['calcium'], false);
      expect(map['vitaminC'], true);
      expect(map['zinc'], false);
    });
  });
}
