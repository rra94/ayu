import 'package:opennutritracker/core/db/entities/caffeine_log_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class CaffeineDataSource {
  final Box<CaffeineLogOB> _box;

  CaffeineDataSource(this._box);

  Future<void> addLog(CaffeineLogOB log) async {
    _box.put(log);
  }

  Future<CaffeineLogOB?> getLastCaffeine() async {
    final query = _box.query()
      ..order(CaffeineLogOB_.dateTime, flags: Order.descending);
    final built = query.build();
    final result = built.findFirst();
    built.close();
    return result;
  }

  Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final query = _box
        .query(CaffeineLogOB_.dateTime.betweenDate(start, end))
        .build();
    final results = query.find();
    query.close();
    return results.fold<double>(0, (sum, l) => sum + l.amountMg);
  }

  /// Get today's individual logs for display/deletion
  Future<List<CaffeineLogOB>> getTodayLogs() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final query = _box
        .query(CaffeineLogOB_.dateTime.betweenDate(start, end))
        .order(CaffeineLogOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> deleteLog(int id) async {
    _box.remove(id);
  }

  /// Clear all caffeine logs
  Future<void> clearAll() async {
    _box.removeAll();
  }

  Future<void> pruneOlderThan(DateTime cutoff) async {
    final query = _box.query(CaffeineLogOB_.dateTime.lessThan(cutoff.millisecondsSinceEpoch)).build();
    final old = query.find();
    query.close();
    if (old.isNotEmpty) _box.removeMany(old.map((e) => e.id).toList());
  }

  /// Hours since last caffeine intake
  Future<double?> hoursSinceLastCaffeine() async {
    final last = await getLastCaffeine();
    if (last == null) return null;
    return DateTime.now().difference(last.dateTime).inMinutes / 60.0;
  }
}
