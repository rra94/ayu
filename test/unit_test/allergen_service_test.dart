import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/allergen_service.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  group('AllergenService', () {
    setUp(() async {
      await AllergenService.setUserAllergens({'Dairy', 'Gluten', 'Peanuts'});
    });

    test('no alerts when no allergens configured', () async {
      await AllergenService.setUserAllergens({});
      final meal = _createMeal('Cheese Pizza', 'Contains milk, wheat flour');
      final alerts = await AllergenService.checkMeal(meal);
      expect(alerts, isEmpty);
    });

    test('detects dairy from ingredients', () async {
      final meal = _createMeal('Protein Bar', 'whey protein, milk chocolate');
      final alerts = await AllergenService.checkMeal(meal);
      expect(alerts.any((a) => a.displayName == 'Dairy'), isTrue);
    });

    test('detects gluten from ingredients', () async {
      final meal = _createMeal('Bread', 'wheat flour, water, yeast');
      final alerts = await AllergenService.checkMeal(meal);
      expect(alerts.any((a) => a.displayName.contains('Wheat') ||
          a.displayName.contains('Gluten')), isTrue);
    });

    test('detects peanuts from product name', () async {
      final meal = _createMeal('Peanut Butter Cups', '');
      final alerts = await AllergenService.checkMeal(meal);
      expect(alerts.any((a) => a.displayName == 'Peanuts'), isTrue);
    });

    test('no duplicate alerts for same allergen', () async {
      final meal = _createMeal('Milk Chocolate Shake', 'milk, cream, lactose');
      final alerts = await AllergenService.checkMeal(meal);
      final dairyAlerts = alerts.where((a) => a.displayName == 'Dairy');
      expect(dairyAlerts.length, 1);
    });

    test('ignores allergens not in user list', () async {
      await AllergenService.setUserAllergens({'Gluten'});
      final meal = _createMeal('Shrimp Tempura', 'shrimp, wheat flour');
      final alerts = await AllergenService.checkMeal(meal);
      expect(alerts.any((a) => a.displayName == 'Shellfish'), isFalse);
      expect(alerts.any((a) => a.displayName == 'Gluten'), isTrue);
    });

    test('allAllergenNames returns sorted list', () {
      final names = AllergenService.allAllergenNames;
      expect(names, isNotEmpty);
      for (int i = 1; i < names.length; i++) {
        expect(names[i].compareTo(names[i - 1]), greaterThanOrEqualTo(0));
      }
    });
  });
}

MealEntity _createMeal(String name, String ingredients) {
  return MealEntity(
    code: 'test',
    name: name,
    url: null,
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: null,
    servingUnit: null,
    servingSize: null,
    source: MealSourceEntity.custom,
    ingredientsText: ingredients,
    nutriments: MealNutrimentsEntity.empty(),
  );
}
