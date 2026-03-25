import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/eco_score_data_source.dart';
import 'package:opennutritracker/core/db/entities/eco_score_ob.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
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
          final result = await _searchProductUseCase
              .searchOFFProductsByString(_searchString);
          final config = await _getConfigUsecase.getConfig();

          // Auto-cache eco-scores from OFF search results
          _cacheEcoScores(result);

          emit(ProductsLoadedState(
              products: result, usesImperialUnits: config.usesImperialUnits));
        } catch (error) {
          log.severe(error);
          emit(ProductsFailedState());
        }
      }
    });
    on<RefreshProductsEvent>((event, emit) async {
      emit(ProductsLoadingState());
      try {
        final result = await _searchProductUseCase
            .searchOFFProductsByString(_searchString);

        // Auto-cache eco-scores from OFF search results
        _cacheEcoScores(result);

        emit(ProductsLoadedState(products: result));
      } catch (error) {
        log.severe(error);
        emit(ProductsFailedState());
      }
    });
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
