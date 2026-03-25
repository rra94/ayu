import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/env.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class CalorieNinjaDataSource {
  static final _log = Logger('CalorieNinjaDataSource');
  static const _baseUrl = 'https://api.calorieninjas.com/v1/nutrition';

  /// Search for food nutrition using natural language.
  /// Supports queries like "chicken breast", "2 eggs and toast", etc.
  static Future<List<MealEntity>> search(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}');
      final response = await http.get(uri, headers: {
        'X-Api-Key': Env.calorieNinjaApiKey,
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        _log.warning('CalorieNinjas returned ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body);
      final items = data['items'] as List? ?? [];

      return items.map((item) {
        final servingG = (item['serving_size_g'] as num?)?.toDouble() ?? 100;
        // Normalize to per-100g
        final factor = servingG > 0 ? 100 / servingG : 1.0;

        return MealEntity(
          code: null,
          name: _capitalize(item['name'] as String? ?? query),
          url: null,
          mealQuantity: '${servingG.round()}',
          mealUnit: 'g',
          servingQuantity: servingG,
          servingUnit: 'g',
          servingSize: '${servingG.round()}g',
          source: MealSourceEntity.custom,
          nutriments: MealNutrimentsEntity(
            energyKcal100:
                ((item['calories'] as num?)?.toDouble() ?? 0) * factor,
            fat100:
                ((item['fat_total_g'] as num?)?.toDouble() ?? 0) * factor,
            saturatedFat100:
                ((item['fat_saturated_g'] as num?)?.toDouble() ?? 0) * factor,
            proteins100:
                ((item['protein_g'] as num?)?.toDouble() ?? 0) * factor,
            carbohydrates100:
                ((item['carbohydrates_total_g'] as num?)?.toDouble() ?? 0) *
                    factor,
            sugars100:
                ((item['sugar_g'] as num?)?.toDouble() ?? 0) * factor,
            fiber100:
                ((item['fiber_g'] as num?)?.toDouble() ?? 0) * factor,
            sodium100:
                ((item['sodium_mg'] as num?)?.toDouble() ?? 0) * factor,
          ),
        );
      }).toList();
    } catch (e) {
      _log.warning('CalorieNinjas search failed: $e');
      return [];
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) =>
      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}'
    ).join(' ');
  }
}
