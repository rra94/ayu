import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

class AllergenAlert {
  final String allergen;
  final String displayName;
  final bool isTrace; // trace vs confirmed ingredient
  final String severity; // high, medium, low

  AllergenAlert({
    required this.allergen,
    required this.displayName,
    this.isTrace = false,
    this.severity = 'high',
  });
}

class AllergenService {
  /// Common allergens with display names (FDA Big 9 + extras)
  static const _allergenNames = {
    'en:gluten': 'Gluten',
    'en:wheat': 'Wheat',
    'en:milk': 'Dairy',
    'en:eggs': 'Eggs',
    'en:fish': 'Fish',
    'en:crustaceans': 'Shellfish',
    'en:molluscs': 'Molluscs',
    'en:peanuts': 'Peanuts',
    'en:nuts': 'Tree Nuts',
    'en:soybeans': 'Soy',
    'en:sesame-seeds': 'Sesame',
    'en:celery': 'Celery',
    'en:mustard': 'Mustard',
    'en:lupin': 'Lupin',
    'en:sulphur-dioxide-and-sulphites': 'Sulfites',
  };

  /// Name-based detection for ingredients text
  static const _ingredientKeywords = {
    'wheat': 'Gluten',
    'gluten': 'Gluten',
    'milk': 'Dairy',
    'cream': 'Dairy',
    'butter': 'Dairy',
    'cheese': 'Dairy',
    'whey': 'Dairy',
    'casein': 'Dairy',
    'lactose': 'Dairy',
    'egg': 'Eggs',
    'peanut': 'Peanuts',
    'almond': 'Tree Nuts',
    'walnut': 'Tree Nuts',
    'cashew': 'Tree Nuts',
    'pecan': 'Tree Nuts',
    'pistachio': 'Tree Nuts',
    'hazelnut': 'Tree Nuts',
    'macadamia': 'Tree Nuts',
    'soy': 'Soy',
    'soya': 'Soy',
    'sesame': 'Sesame',
    'shrimp': 'Shellfish',
    'crab': 'Shellfish',
    'lobster': 'Shellfish',
    'fish': 'Fish',
    'anchov': 'Fish',
    'sardine': 'Fish',
    'sulfite': 'Sulfites',
    'sulphite': 'Sulfites',
  };

  /// User's configured allergens (stored as Set of display names)
  static Set<String> _userAllergens = {};

  static void setUserAllergens(Set<String> allergens) {
    _userAllergens = allergens;
  }

  static Set<String> get userAllergens => _userAllergens;

  static List<String> get allAllergenNames =>
      _allergenNames.values.toSet().toList()..sort();

  /// Check a meal for allergens. Returns alerts for user's configured allergens.
  static List<AllergenAlert> checkMeal(MealEntity meal) {
    if (_userAllergens.isEmpty) return [];

    final alerts = <AllergenAlert>[];
    final found = <String>{};

    // Check OFF allergen tags
    // OFF products may have allergens_tags field — we'd need to add it to the DTO
    // For now, check ingredients text
    final ingredients = (meal.ingredientsText ?? '').toLowerCase();

    if (ingredients.isNotEmpty) {
      for (final entry in _ingredientKeywords.entries) {
        if (ingredients.contains(entry.key) &&
            _userAllergens.contains(entry.value) &&
            !found.contains(entry.value)) {
          found.add(entry.value);
          alerts.add(AllergenAlert(
            allergen: entry.key,
            displayName: entry.value,
            severity: 'high',
          ));
        }
      }
    }

    // Check product name as backup
    final name = (meal.name ?? '').toLowerCase();
    for (final entry in _ingredientKeywords.entries) {
      if (name.contains(entry.key) &&
          _userAllergens.contains(entry.value) &&
          !found.contains(entry.value)) {
        found.add(entry.value);
        alerts.add(AllergenAlert(
          allergen: entry.key,
          displayName: entry.value,
          severity: 'medium',
        ));
      }
    }

    // Check additives tags for hidden allergens
    final additives = meal.additivesTags;
    if (additives != null) {
      for (final tag in additives) {
        final lower = tag.toLowerCase();
        final allergenName = _allergenNames[lower];
        if (allergenName != null &&
            _userAllergens.contains(allergenName) &&
            !found.contains(allergenName)) {
          found.add(allergenName);
          alerts.add(AllergenAlert(
            allergen: tag,
            displayName: allergenName,
            severity: 'high',
          ));
        }
      }
    }

    return alerts;
  }
}
