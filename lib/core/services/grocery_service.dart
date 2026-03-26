import 'package:opennutritracker/core/db/data_sources/grocery_data_source.dart';
import 'package:opennutritracker/core/db/entities/grocery_item_ob.dart';
import 'package:opennutritracker/core/services/receipt_parser_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class GroceryService {
  /// Convert receipt items to grocery items and save to DB.
  static Future<int> addFromReceipt(
    List<ReceiptItem> items, {
    String? store,
  }) async {
    final ds = locator<GroceryDataSource>();
    final groceries = <GroceryItemOB>[];

    for (final item in items) {
      if (item.category == 'non_food') continue;

      final category = GroceryItemOB.classifyCategory(item.name);
      groceries.add(GroceryItemOB(
        name: item.name,
        price: item.price,
        store: store,
        category: category,
        purchaseDate: DateTime.now(),
        shelfLifeDays: GroceryItemOB.estimateShelfLife(category),
      ));
    }

    if (groceries.isNotEmpty) {
      await ds.addItems(groceries);
    }
    return groceries.length;
  }

  /// Auto-add grocery item when a barcode is scanned for food
  static Future<void> addFromBarcode({
    required String name,
    String? brand,
    String? barcode,
    String? store,
  }) async {
    final ds = locator<GroceryDataSource>();
    final category = GroceryItemOB.classifyCategory(name);
    await ds.addItem(GroceryItemOB(
      name: name,
      brand: brand,
      barcode: barcode,
      store: store,
      category: category,
      purchaseDate: DateTime.now(),
      shelfLifeDays: GroceryItemOB.estimateShelfLife(category),
    ));
  }
}
