import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/supplement_detector.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  group('SupplementDetector', () {
    test('detects vitamin supplement', () {
      final meal = _createMeal('Vitamin D3 5000IU', 'NOW Foods');
      expect(SupplementDetector.isSupplement(meal), isTrue);
    });

    test('detects fish oil', () {
      final meal = _createMeal('Omega-3 Fish Oil 1000mg', 'Nordic Naturals');
      expect(SupplementDetector.isSupplement(meal), isTrue);
    });

    test('detects probiotic', () {
      final meal = _createMeal('Probiotic 50 Billion CFU', 'Garden of Life');
      expect(SupplementDetector.isSupplement(meal), isTrue);
    });

    test('detects protein powder', () {
      final meal = _createMeal('Whey Protein Isolate', 'Optimum Nutrition');
      expect(SupplementDetector.isSupplement(meal), isTrue);
    });

    test('does NOT detect regular food', () {
      final meal = _createMeal('Organic Bananas', 'Dole');
      expect(SupplementDetector.isSupplement(meal), isFalse);
    });

    test('does NOT detect snack', () {
      final meal = _createMeal('Dark Chocolate Bar', 'Lindt');
      expect(SupplementDetector.isSupplement(meal), isFalse);
    });

    test('detects creatine', () {
      final meal = _createMeal('Creatine Monohydrate', 'Thorne');
      expect(SupplementDetector.isSupplement(meal), isTrue);
    });

    test('detects ashwagandha', () {
      final meal = _createMeal('Ashwagandha KSM-66', 'Jarrow');
      expect(SupplementDetector.isSupplement(meal), isTrue);
    });
  });
}

MealEntity _createMeal(String name, String brand) => MealEntity(
  code: 'test', name: name, brands: brand, url: null,
  mealQuantity: '1', mealUnit: 'serving',
  servingQuantity: null, servingUnit: null, servingSize: null,
  source: MealSourceEntity.custom,
  nutriments: MealNutrimentsEntity.empty(),
);
