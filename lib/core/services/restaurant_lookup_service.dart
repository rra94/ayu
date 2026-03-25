import 'package:logging/logging.dart';
import 'package:opennutritracker/core/services/receipt_parser_service.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class RestaurantLookupResult {
  final ReceiptItem item;
  final MealEntity? matchedMeal; // from OFF/USDA search
  final MealEntity? estimatedMeal; // category-based estimate
  final double confidence; // 0-1

  RestaurantLookupResult({
    required this.item,
    this.matchedMeal,
    this.estimatedMeal,
    required this.confidence,
  });

  MealEntity? get bestMatch => matchedMeal ?? estimatedMeal;
  bool get isEstimate => matchedMeal == null && estimatedMeal != null;
}

class RestaurantLookupService {
  static final _log = Logger('RestaurantLookupService');

  /// Look up nutrition for restaurant receipt items.
  /// Tries: 1) OFF search "{restaurant} {item}" 2) OFF search "{item}"
  /// 3) USDA FDC search 4) category estimate
  static Future<List<RestaurantLookupResult>> lookupItems(
    String? restaurantName,
    List<ReceiptItem> items,
  ) async {
    final searchUsecase = locator<SearchProductsUseCase>();
    final results = <RestaurantLookupResult>[];

    for (final item in items) {
      MealEntity? matched;
      double confidence = 0;

      // Try 1: Search with restaurant name for exact chain match
      if (restaurantName != null) {
        try {
          final query =
              '${restaurantName.split(' ').take(2).join(' ')} ${item.name}';
          _log.fine('Restaurant lookup try 1: "$query"');
          final offResults =
              await searchUsecase.searchOFFProductsByString(query);
          if (offResults.isNotEmpty) {
            matched = offResults.first;
            confidence = 0.8;
          }
        } catch (e) {
          _log.warning('OFF restaurant+item search failed: $e');
        }
      }

      // Try 2: Search just the item name via OFF
      if (matched == null) {
        try {
          _log.fine('Restaurant lookup try 2 (OFF): "${item.name}"');
          final offResults =
              await searchUsecase.searchOFFProductsByString(item.name);
          if (offResults.isNotEmpty) {
            matched = offResults.first;
            confidence = 0.6;
          }
        } catch (e) {
          _log.warning('OFF item search failed: $e');
        }
      }

      // Try 3: Search USDA FDC
      if (matched == null) {
        try {
          _log.fine('Restaurant lookup try 3 (FDC): "${item.name}"');
          final fdcResults =
              await searchUsecase.searchFDCFoodByString(item.name);
          if (fdcResults.isNotEmpty) {
            matched = fdcResults.first;
            confidence = 0.5;
          }
        } catch (e) {
          _log.warning('FDC item search failed: $e');
        }
      }

      // Fallback: Category-based estimate
      MealEntity? estimated;
      if (matched == null) {
        estimated = _estimateFromCategory(item.name);
        confidence = estimated != null ? 0.3 : 0;
      }

      results.add(RestaurantLookupResult(
        item: item,
        matchedMeal: matched,
        estimatedMeal: estimated,
        confidence: confidence,
      ));
    }

    return results;
  }

  /// Rough category-based nutrition estimate for common restaurant items.
  /// Values represent a typical single serving.
  static MealEntity? _estimateFromCategory(String name) {
    final lower = name.toLowerCase();

    // Common restaurant food categories with typical nutrition per serving
    final estimates = <String, Map<String, double>>{
      // Burgers & sandwiches
      'burger': {'kcal': 550, 'fat': 30, 'carbs': 40, 'protein': 25},
      'cheeseburger': {'kcal': 650, 'fat': 35, 'carbs': 42, 'protein': 30},
      'sandwich': {'kcal': 450, 'fat': 20, 'carbs': 45, 'protein': 22},
      'wrap': {'kcal': 400, 'fat': 15, 'carbs': 45, 'protein': 20},
      'sub': {'kcal': 500, 'fat': 22, 'carbs': 50, 'protein': 24},
      // Pizza
      'pizza': {'kcal': 300, 'fat': 12, 'carbs': 36, 'protein': 12},
      // Chicken
      'chicken': {'kcal': 450, 'fat': 20, 'carbs': 25, 'protein': 35},
      'nugget': {'kcal': 400, 'fat': 24, 'carbs': 28, 'protein': 18},
      'wing': {'kcal': 350, 'fat': 22, 'carbs': 10, 'protein': 28},
      'tender': {'kcal': 380, 'fat': 18, 'carbs': 22, 'protein': 30},
      // Mexican
      'burrito': {'kcal': 650, 'fat': 25, 'carbs': 75, 'protein': 30},
      'taco': {'kcal': 200, 'fat': 10, 'carbs': 18, 'protein': 10},
      'quesadilla': {'kcal': 500, 'fat': 28, 'carbs': 40, 'protein': 22},
      'bowl': {'kcal': 550, 'fat': 18, 'carbs': 60, 'protein': 30},
      // Asian
      'fried rice': {'kcal': 450, 'fat': 15, 'carbs': 60, 'protein': 12},
      'lo mein': {'kcal': 500, 'fat': 18, 'carbs': 65, 'protein': 15},
      'pad thai': {'kcal': 550, 'fat': 20, 'carbs': 70, 'protein': 18},
      'sushi': {'kcal': 350, 'fat': 8, 'carbs': 50, 'protein': 15},
      'ramen': {'kcal': 500, 'fat': 18, 'carbs': 55, 'protein': 20},
      'curry': {'kcal': 450, 'fat': 20, 'carbs': 40, 'protein': 22},
      // Salads
      'salad': {'kcal': 350, 'fat': 18, 'carbs': 25, 'protein': 20},
      'caesar': {'kcal': 400, 'fat': 25, 'carbs': 20, 'protein': 18},
      // Sides
      'fries': {'kcal': 380, 'fat': 18, 'carbs': 50, 'protein': 4},
      'fry': {'kcal': 380, 'fat': 18, 'carbs': 50, 'protein': 4},
      'onion ring': {'kcal': 350, 'fat': 20, 'carbs': 40, 'protein': 5},
      'mac': {'kcal': 400, 'fat': 22, 'carbs': 42, 'protein': 14},
      'mashed': {'kcal': 200, 'fat': 8, 'carbs': 30, 'protein': 4},
      'coleslaw': {'kcal': 150, 'fat': 10, 'carbs': 14, 'protein': 1},
      'rice': {'kcal': 200, 'fat': 1, 'carbs': 45, 'protein': 4},
      'soup': {'kcal': 200, 'fat': 8, 'carbs': 22, 'protein': 10},
      // Drinks
      'shake': {'kcal': 500, 'fat': 18, 'carbs': 75, 'protein': 10},
      'smoothie': {'kcal': 350, 'fat': 5, 'carbs': 65, 'protein': 8},
      'lemonade': {'kcal': 180, 'fat': 0, 'carbs': 46, 'protein': 0},
      'soda': {'kcal': 150, 'fat': 0, 'carbs': 39, 'protein': 0},
      'coffee': {'kcal': 5, 'fat': 0, 'carbs': 0, 'protein': 0},
      'latte': {'kcal': 190, 'fat': 7, 'carbs': 19, 'protein': 13},
      // Breakfast
      'pancake': {'kcal': 350, 'fat': 12, 'carbs': 50, 'protein': 8},
      'waffle': {'kcal': 400, 'fat': 15, 'carbs': 55, 'protein': 8},
      'omelette': {'kcal': 350, 'fat': 22, 'carbs': 4, 'protein': 24},
      'toast': {'kcal': 200, 'fat': 8, 'carbs': 26, 'protein': 6},
      'bagel': {'kcal': 300, 'fat': 3, 'carbs': 55, 'protein': 10},
      // Dessert
      'cake': {'kcal': 350, 'fat': 15, 'carbs': 50, 'protein': 4},
      'pie': {'kcal': 300, 'fat': 14, 'carbs': 42, 'protein': 3},
      'brownie': {'kcal': 350, 'fat': 18, 'carbs': 45, 'protein': 4},
      'cookie': {'kcal': 200, 'fat': 10, 'carbs': 28, 'protein': 2},
      'ice cream': {'kcal': 250, 'fat': 14, 'carbs': 28, 'protein': 4},
      // Steak & seafood
      'steak': {'kcal': 500, 'fat': 30, 'carbs': 0, 'protein': 50},
      'salmon': {'kcal': 350, 'fat': 18, 'carbs': 0, 'protein': 40},
      'shrimp': {'kcal': 250, 'fat': 8, 'carbs': 12, 'protein': 25},
      'fish': {'kcal': 350, 'fat': 15, 'carbs': 20, 'protein': 30},
    };

    for (final entry in estimates.entries) {
      if (lower.contains(entry.key)) {
        final n = entry.value;
        return MealEntity(
          code: null,
          name: '$name (estimated)',
          url: null,
          mealQuantity: '1',
          mealUnit: 'serving',
          servingQuantity: null,
          servingUnit: null,
          servingSize: '1 serving (estimated)',
          source: MealSourceEntity.custom,
          nutriments: MealNutrimentsEntity(
            energyKcal100: n['kcal'],
            carbohydrates100: n['carbs'],
            fat100: n['fat'],
            proteins100: n['protein'],
            sugars100: null,
            saturatedFat100: null,
            fiber100: null,
          ),
        );
      }
    }

    return null;
  }
}
