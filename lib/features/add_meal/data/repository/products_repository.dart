import 'package:logging/logging.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/fdc_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/off_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/sp_fdc_data_source.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/scanner/data/product_not_found_exception.dart';

class ProductsRepository {
  final log = Logger('ProductsRepository');
  final OFFDataSource _offDataSource;
  final FDCDataSource _fdcDataSource;
  final SpFdcDataSource _spBackendDataSource;

  ProductsRepository(
      this._offDataSource, this._fdcDataSource, this._spBackendDataSource);

  Future<List<MealEntity>> getOFFProductsByString(String searchString) async {
    final offWordResponse =
        await _offDataSource.fetchSearchWordResults(searchString);

    final products = offWordResponse.products
        .map((offProduct) => MealEntity.fromOFFProduct(offProduct))
        .toList();

    return products;
  }

  Future<List<MealEntity>> getFDCFoodsByString(String searchString) async {
    final fdcWordResponse =
        await _fdcDataSource.fetchSearchWordResults(searchString);
    final products = fdcWordResponse.foods
        .map((food) => MealEntity.fromFDCFood(food))
        .toList();
    return products;
  }

  Future<List<MealEntity>> getSupabaseFDCFoodsByString(
      String searchString) async {
    final spFdcWordResponse =
        await _spBackendDataSource.fetchSearchWordResults(searchString);
    final products = spFdcWordResponse
        .map((foodItem) => MealEntity.fromSpFDCFood(foodItem))
        .toList();
    return products;
  }

  /// Search by barcode: try OFF first, then fall back to FDC Branded database.
  Future<MealEntity> getProductByBarcode(String barcode) async {
    // Try Open Food Facts first
    try {
      final productResponse = await _offDataSource.fetchBarcodeResults(barcode);
      return MealEntity.fromOFFProduct(productResponse.product);
    } catch (offError) {
      log.info('OFF barcode lookup failed ($offError), trying FDC fallback');
    }

    // Fallback: USDA FDC Branded database (supports UPC/GTIN barcodes)
    try {
      final fdcResponse = await _fdcDataSource.fetchBarcodeResults(barcode);
      if (fdcResponse.foods.isNotEmpty) {
        log.info('Found product in FDC: ${fdcResponse.foods.first.description}');
        return MealEntity.fromFDCFood(fdcResponse.foods.first);
      }
    } catch (fdcError) {
      log.info('FDC barcode lookup also failed ($fdcError)');
    }

    // Both sources failed
    return Future.error(ProductNotFoundException);
  }

  @Deprecated('Use getProductByBarcode which includes FDC fallback')
  Future<MealEntity> getOFFProductByBarcode(String barcode) async {
    return getProductByBarcode(barcode);
  }
}
