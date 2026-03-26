import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/common_foods_db.dart';
import 'package:opennutritracker/core/data/government_foods_db.dart';
import 'package:opennutritracker/core/services/gemini_food_vision_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/calorie_ninja_data_source.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';

class PhotoEnrichmentService {
  static final _log = Logger('PhotoEnrichmentService');

  /// Enrich Gemini-identified items with real nutrition data from databases.
  /// Uses the same cascade: Common Foods → Gov DBs → CalorieNinjas → OFF
  static Future<List<FoodPhotoItem>> enrichItems(
      List<FoodPhotoItem> items) async {
    final enriched = <FoodPhotoItem>[];

    for (final item in items) {
      MealEntity? matched;
      String source = 'gemini_estimate';

      // 1. Common foods DB (instant, in-memory)
      final commonResults = CommonFoodsDB.search(item.name);
      if (commonResults.isNotEmpty) {
        matched = commonResults.first;
        source = 'common_db';
      }

      // 2. Government DBs (asset files, good coverage)
      if (matched == null) {
        try {
          final govResults = await GovernmentFoodsDB.search(item.name);
          if (govResults.isNotEmpty) {
            matched = govResults.first;
            source = 'government_db';
          }
        } catch (e) {
          _log.warning('GovernmentFoodsDB search failed for "${item.name}": $e');
        }
      }

      // 3. CalorieNinjas (good generic food data, cached)
      if (matched == null) {
        try {
          final ninjaResults = await CalorieNinjaDataSource.search(item.name);
          if (ninjaResults.isNotEmpty) {
            matched = ninjaResults.first;
            source = 'calorie_ninja';
          }
        } catch (e) {
          _log.warning(
              'CalorieNinjaDataSource search failed for "${item.name}": $e');
        }
      }

      // 4. OpenFoodFacts
      if (matched == null) {
        try {
          final searchUsecase = locator<SearchProductsUseCase>();
          final offResults =
              await searchUsecase.searchOFFProductsByString(item.name);
          if (offResults.isNotEmpty) {
            matched = offResults.first;
            source = 'off';
          }
        } catch (e) {
          _log.warning('OFF search failed for "${item.name}": $e');
        }
      }

      if (matched != null) {
        // Scale database nutrition to Gemini's estimated grams
        final n = matched.nutriments;
        final factor = item.grams / 100.0;
        _log.fine(
            'Enriched "${item.name}" from $source (${item.grams}g × factor $factor)');
        enriched.add(FoodPhotoItem(
          name: item.name,
          grams: item.grams,
          kcal: (n.energyKcal100 ?? 0) * factor,
          protein: (n.proteins100 ?? 0) * factor,
          fat: (n.fat100 ?? 0) * factor,
          carbs: (n.carbohydrates100 ?? 0) * factor,
          matchedMeal: matched,
          source: source,
        ));
      } else {
        // No match found — keep zeros and mark as estimate
        _log.info(
            'No database match for "${item.name}", using Gemini estimate (no nutrition data)');
        enriched.add(FoodPhotoItem(
          name: item.name,
          grams: item.grams,
          kcal: item.kcal,
          protein: item.protein,
          fat: item.fat,
          carbs: item.carbs,
          matchedMeal: null,
          source: 'gemini_estimate',
        ));
      }
    }

    return enriched;
  }
}
