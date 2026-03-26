import 'package:opennutritracker/core/db/entities/stool_log_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class StoolDataSource {
  final Box<StoolLogOB> _box;

  StoolDataSource(this._box);

  Future<void> addLog(StoolLogOB log) async {
    _box.put(log);
  }

  Future<void> deleteLog(int id) async {
    _box.remove(id);
  }

  Future<List<StoolLogOB>> getLogsByDateRange(
      DateTime start, DateTime end) async {
    final query = _box
        .query(StoolLogOB_.dateTime.betweenDate(start, end))
        .order(StoolLogOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<List<StoolLogOB>> getLast30Days() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return getLogsByDateRange(start, now);
  }
}
