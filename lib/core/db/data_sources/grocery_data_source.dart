import 'package:opennutritracker/core/db/entities/grocery_item_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class GroceryDataSource {
  final Box<GroceryItemOB> _box;

  GroceryDataSource(this._box);

  Future<void> addItem(GroceryItemOB item) async {
    _box.put(item);
  }

  Future<void> addItems(List<GroceryItemOB> items) async {
    _box.putMany(items);
  }

  Future<void> deleteItem(int id) async {
    _box.remove(id);
  }

  Future<void> markConsumed(int id) async {
    final item = _box.get(id);
    if (item != null) {
      item.consumed = true;
      _box.put(item);
    }
  }

  Future<List<GroceryItemOB>> getUnconsumed() async {
    final query = _box
        .query(GroceryItemOB_.consumed.equals(false))
        .order(GroceryItemOB_.purchaseDate, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<List<GroceryItemOB>> getExpiringSoon() async {
    final all = await getUnconsumed();
    return all.where((item) => item.isExpiringSoon && !item.isExpired).toList();
  }

  Future<List<GroceryItemOB>> getByStore(String store) async {
    final query = _box
        .query(GroceryItemOB_.store.equals(store))
        .order(GroceryItemOB_.purchaseDate, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<List<String>> getStoreHistory() async {
    final all = _box.getAll();
    return all
        .where((i) => i.store != null && i.store!.isNotEmpty)
        .map((i) => i.store!)
        .toSet()
        .toList();
  }

  Future<Map<String, int>> getCategoryBreakdown() async {
    final unconsumed = await getUnconsumed();
    final counts = <String, int>{};
    for (final item in unconsumed) {
      final cat = item.category ?? 'other';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }
}
