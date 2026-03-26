import 'package:opennutritracker/core/db/entities/food_cache_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class FoodCacheDataSource {
  final Box<FoodCacheOB> _box;

  FoodCacheDataSource(this._box);

  /// Get cached results for a query + source. Returns null if not cached or stale.
  Future<FoodCacheOB?> get(String query, String source, {int maxAgeDays = 30}) async {
    final normalized = query.toLowerCase().trim();
    final q = _box
        .query(FoodCacheOB_.query.equals(normalized) &
            FoodCacheOB_.source.equals(source))
        .order(FoodCacheOB_.cachedAt, flags: Order.descending)
        .build();
    final result = q.findFirst();
    q.close();

    if (result == null) return null;

    // Check staleness
    if (DateTime.now().difference(result.cachedAt).inDays > maxAgeDays) {
      _box.remove(result.id); // expired
      return null;
    }

    // Increment hit count
    result.hitCount++;
    _box.put(result);
    return result;
  }

  /// Cache results for a query + source.
  Future<void> put(String query, String source, String resultsJson, int count) async {
    final normalized = query.toLowerCase().trim();

    // Remove old cache for same query+source
    final old = _box
        .query(FoodCacheOB_.query.equals(normalized) &
            FoodCacheOB_.source.equals(source))
        .build();
    final oldResults = old.find();
    old.close();
    if (oldResults.isNotEmpty) {
      _box.removeMany(oldResults.map((e) => e.id).toList());
    }

    _box.put(FoodCacheOB(
      query: normalized,
      source: source,
      resultsJson: resultsJson,
      resultCount: count,
      cachedAt: DateTime.now(),
    ));
  }

  /// Prune caches older than [days] or keep only top [keepTop] by hit count.
  Future<void> prune({int days = 30, int keepTop = 1000}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final staleQuery = _box
        .query(FoodCacheOB_.cachedAt.lessThan(cutoff.millisecondsSinceEpoch))
        .build();
    final stale = staleQuery.find();
    staleQuery.close();
    if (stale.isNotEmpty) {
      _box.removeMany(stale.map((e) => e.id).toList());
    }

    // Also cap total entries
    final all = _box.query()
        .order(FoodCacheOB_.hitCount, flags: Order.descending)
        .build();
    final allResults = all.find();
    all.close();
    if (allResults.length > keepTop) {
      final toRemove = allResults.sublist(keepTop).map((e) => e.id).toList();
      _box.removeMany(toRemove);
    }
  }
}
