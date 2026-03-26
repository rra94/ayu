import 'package:opennutritracker/core/db/entities/product_inventory_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class InventoryDataSource {
  final Box<ProductInventoryOB> _box;

  InventoryDataSource(this._box);

  Future<void> addProduct(ProductInventoryOB product) async {
    _box.put(product);
  }

  Future<void> updateProduct(ProductInventoryOB product) async {
    _box.put(product);
  }

  Future<void> deleteProduct(int id) async {
    _box.remove(id);
  }

  Future<List<ProductInventoryOB>> getAll() async {
    return _box.getAll();
  }

  Future<List<ProductInventoryOB>> getLowStock() async {
    final all = _box.getAll();
    return all.where((p) => p.isLow).toList();
  }

  /// Decrement usage for a product (called when habit is completed)
  Future<void> useProduct(int id) async {
    final product = _box.get(id);
    if (product != null && product.usesRemaining > 0) {
      product.usesRemaining--;
      _box.put(product);
    }
  }

  /// Reset product (new bottle purchased)
  Future<void> refill(int id) async {
    final product = _box.get(id);
    if (product != null) {
      product.usesRemaining = product.totalUses;
      product.startedDate = DateTime.now();
      _box.put(product);
    }
  }
}
