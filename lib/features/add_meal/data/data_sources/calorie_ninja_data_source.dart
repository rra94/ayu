import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/food_cache_data_source.dart';
import 'package:opennutritracker/core/utils/env.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class CalorieNinjaDataSource {
  static final _log = Logger('CalorieNinjaDataSource');
  static const _baseUrl = 'https://api.calorieninjas.com/v1/nutrition';

  /// Search for food nutrition using natural language.
  /// Supports queries like "chicken breast", "2 eggs and toast", etc.
  static Future<List<MealEntity>> search(String query) async {
    // Check cache first
    final cacheDs = locator<FoodCacheDataSource>();
    final cached = await cacheDs.get(query, 'calorie_ninja');
    if (cached != null) {
      _log.fine('CalorieNinjas cache hit for "$query" (${cached.hitCount} hits)');
      try {
        final items = jsonDecode(cached.resultsJson) as List;
        return items.map((item) => _fromCacheJson(item)).toList();
      } catch (e) {
        _log.warning('Failed to deserialize cached CalorieNinjas results: $e');
        // Fall through to live API call
      }
    }

    try {
      final uri = Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}');
      final response = await http.get(uri, headers: {
        'X-Api-Key': Env.calorieNinjaApiKey,
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 429) {
        _log.warning('CalorieNinjas rate limited (429)');
        throw Exception('rate_limited');
      }
      if (response.statusCode != 200) {
        _log.warning('CalorieNinjas returned ${response.statusCode}');
        return [];
      }

      // Parse JSON off the main thread to avoid jank with large responses
      final results = await compute(_parseResponse, _ParseArgs(response.body, query));

      // Cache the results for future use
      if (results.isNotEmpty) {
        try {
          await cacheDs.put(query, 'calorie_ninja', jsonEncode(
            results.map((r) => {
              'name': r.name,
              'kcal': r.nutriments.energyKcal100,
              'fat': r.nutriments.fat100,
              'protein': r.nutriments.proteins100,
              'carbs': r.nutriments.carbohydrates100,
              'sugar': r.nutriments.sugars100,
              'fiber': r.nutriments.fiber100,
              'sodium': r.nutriments.sodium100,
              'saturatedFat': r.nutriments.saturatedFat100,
              'servingG': r.servingQuantity,
            }).toList(),
          ), results.length);
          _log.fine('Cached ${results.length} CalorieNinjas results for "$query"');
        } catch (e) {
          _log.warning('Failed to cache CalorieNinjas results: $e');
        }
      }

      return results;
    } catch (e) {
      _log.warning('CalorieNinjas search failed: $e');
      return [];
    }
  }

  /// Reconstruct a [MealEntity] from a cached JSON map.
  static MealEntity _fromCacheJson(dynamic item) {
    final servingG = (item['servingG'] as num?)?.toDouble() ?? 100.0;
    return MealEntity(
      code: null,
      name: item['name'] as String? ?? '',
      url: null,
      mealQuantity: '${servingG.round()}',
      mealUnit: 'g',
      servingQuantity: servingG,
      servingUnit: 'g',
      servingSize: '${servingG.round()}g',
      source: MealSourceEntity.custom,
      nutriments: MealNutrimentsEntity(
        energyKcal100: (item['kcal'] as num?)?.toDouble() ?? 0,
        fat100: (item['fat'] as num?)?.toDouble() ?? 0,
        saturatedFat100: (item['saturatedFat'] as num?)?.toDouble() ?? 0,
        proteins100: (item['protein'] as num?)?.toDouble() ?? 0,
        carbohydrates100: (item['carbs'] as num?)?.toDouble() ?? 0,
        sugars100: (item['sugar'] as num?)?.toDouble() ?? 0,
        fiber100: (item['fiber'] as num?)?.toDouble() ?? 0,
        sodium100: (item['sodium'] as num?)?.toDouble() ?? 0,
      ),
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) =>
      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}'
    ).join(' ');
  }
}

class _ParseArgs {
  final String body;
  final String query;
  _ParseArgs(this.body, this.query);
}

List<MealEntity> _parseResponse(_ParseArgs args) {
  final data = jsonDecode(args.body);
  final items = data['items'] as List? ?? [];

  return items.map((item) {
    final servingG = (item['serving_size_g'] as num?)?.toDouble() ?? 100;
    final factor = servingG > 0 ? 100 / servingG : 1.0;
    final name = item['name'] as String? ?? args.query;
    final capitalized = name.isEmpty
        ? name
        : name.split(' ').map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

    return MealEntity(
      code: null,
      name: capitalized,
      url: null,
      mealQuantity: '${servingG.round()}',
      mealUnit: 'g',
      servingQuantity: servingG,
      servingUnit: 'g',
      servingSize: '${servingG.round()}g',
      source: MealSourceEntity.custom,
      nutriments: MealNutrimentsEntity(
        energyKcal100: ((item['calories'] as num?)?.toDouble() ?? 0) * factor,
        fat100: ((item['fat_total_g'] as num?)?.toDouble() ?? 0) * factor,
        saturatedFat100: ((item['fat_saturated_g'] as num?)?.toDouble() ?? 0) * factor,
        proteins100: ((item['protein_g'] as num?)?.toDouble() ?? 0) * factor,
        carbohydrates100: ((item['carbohydrates_total_g'] as num?)?.toDouble() ?? 0) * factor,
        sugars100: ((item['sugar_g'] as num?)?.toDouble() ?? 0) * factor,
        fiber100: ((item['fiber_g'] as num?)?.toDouble() ?? 0) * factor,
        sodium100: ((item['sodium_mg'] as num?)?.toDouble() ?? 0) * factor,
      ),
    );
  }).toList();
}
