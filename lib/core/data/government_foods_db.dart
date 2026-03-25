import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class GovernmentFoodsDB {
  static List<MealEntity>? _cnfFoods;
  static List<MealEntity>? _cofidFoods;
  static List<MealEntity>? _ausnutFoods;
  static bool _loaded = false;

  /// Load all government food databases from assets (lazy, once)
  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _cnfFoods = await _loadAsset('assets/data/cnf_foods.json', 'CNF');
    _cofidFoods = await _loadAsset('assets/data/cofid_foods.json', 'COFID');
    _ausnutFoods = await _loadAsset('assets/data/ausnut_foods.json', 'AUSNUT');
    _loaded = true;
  }

  static Future<List<MealEntity>> _loadAsset(
      String path, String source) async {
    try {
      final jsonStr = await rootBundle.loadString(path);
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((item) => MealEntity(
                code: null,
                name: item['name'] as String,
                url: null,
                mealQuantity: '100',
                mealUnit: 'g',
                servingQuantity: null,
                servingUnit: null,
                servingSize: null,
                source: MealSourceEntity.custom,
                nutriments: MealNutrimentsEntity(
                  energyKcal100: (item['kcal'] as num).toDouble(),
                  carbohydrates100: (item['carbs'] as num).toDouble(),
                  fat100: (item['fat'] as num).toDouble(),
                  proteins100: (item['protein'] as num).toDouble(),
                  sugars100: null,
                  saturatedFat100: null,
                  fiber100: null,
                  sodium100: null,
                ),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search all government databases
  static Future<List<MealEntity>> search(String query) async {
    if (query.isEmpty) return [];
    await _ensureLoaded();

    final lower = query.toLowerCase().trim();
    final results = <MealEntity>[];

    for (final db in [_cnfFoods, _cofidFoods, _ausnutFoods]) {
      if (db == null) continue;
      results.addAll(db.where((f) {
        final name = f.name?.toLowerCase() ?? '';
        return name.contains(lower) || lower.contains(name);
      }));
    }

    return results;
  }
}
