import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/eco_score_data_source.dart';
import 'package:opennutritracker/core/db/entities/eco_score_ob.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';

part 'products_event.dart';

part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final log = Logger('ProductsBloc');

  final SearchProductsUseCase _searchProductUseCase;
  final GetConfigUsecase _getConfigUsecase;

  String _searchString = "";

  ProductsBloc(this._searchProductUseCase, this._getConfigUsecase)
      : super(ProductsInitial()) {
    on<LoadProductsEvent>((event, emit) async {
      if (event.searchString != _searchString) {
        _searchString = event.searchString;
        emit(ProductsLoadingState());
        try {
          final results = await _cascadeSearch(_searchString);
          final config = await _getConfigUsecase.getConfig();
          _cacheEcoScores(results);
          emit(ProductsLoadedState(
              products: results, usesImperialUnits: config.usesImperialUnits));
        } catch (error) {
          log.severe(error);
          emit(ProductsFailedState());
        }
      }
    });
    on<RefreshProductsEvent>((event, emit) async {
      emit(ProductsLoadingState());
      try {
        final results = await _cascadeSearch(_searchString);
        _cacheEcoScores(results);
        emit(ProductsLoadedState(products: results));
      } catch (error) {
        log.severe(error);
        emit(ProductsFailedState());
      }
    });
  }

  /// Cascade search: OFF → USDA FDC → previously logged foods
  Future<List<MealEntity>> _cascadeSearch(String query) async {
    if (query.isEmpty) return [];

    // 1. Try OFF first
    List<MealEntity> results = [];
    try {
      results = await _searchProductUseCase.searchOFFProductsByString(query);
    } catch (e) {
      log.info('OFF search failed, trying FDC: $e');
    }

    // 2. If OFF returned few results, supplement with USDA FDC
    if (results.length < 3) {
      try {
        final fdcResults = await _searchProductUseCase.searchFDCFoodByString(query);
        // Deduplicate by name (case-insensitive)
        final existingNames = results.map((r) => r.name?.toLowerCase()).toSet();
        for (final fdc in fdcResults) {
          if (!existingNames.contains(fdc.name?.toLowerCase())) {
            results.add(fdc);
          }
        }
      } catch (e) {
        log.info('FDC search also failed: $e');
      }
    }

    // 3. Search previously logged foods (local history)
    try {
      final getIntake = locator<GetIntakeUsecase>();
      final allIntakes = await getIntake.getAllIntakes();
      final queryLower = query.toLowerCase();
      final seen = results.map((r) => r.name?.toLowerCase()).toSet();

      final localMatches = allIntakes
          .where((i) =>
              i.meal.name != null &&
              i.meal.name!.toLowerCase().contains(queryLower) &&
              !seen.contains(i.meal.name!.toLowerCase()))
          .map((i) => i.meal)
          .toSet() // deduplicate by reference
          .take(5)
          .toList();

      results.addAll(localMatches);
    } catch (e) {
      log.info('Local search failed: $e');
    }

    return results;
  }

  void _cacheEcoScores(List<MealEntity> products) {
    final ecoDs = locator<EcoScoreDataSource>();
    for (final p in products) {
      if (p.ecoscoreGrade != null && p.ecoscoreScore != null && p.code != null) {
        ecoDs.upsert(EcoScoreOB(
          productKey: p.code!,
          productName: p.name ?? '',
          grade: p.ecoscoreGrade!,
          score: p.ecoscoreScore!,
          source: 'off',
          highQuality: true,
          updatedAt: DateTime.now(),
        ));
      }
    }
  }
}
