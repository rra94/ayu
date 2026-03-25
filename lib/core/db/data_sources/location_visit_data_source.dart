import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/location_visit_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class LocationVisitDataSource {
  final log = Logger('LocationVisitDataSource');
  final Box<LocationVisitOB> _box;

  LocationVisitDataSource(this._box);

  Future<void> addVisit(LocationVisitOB visit) async {
    log.fine('Adding location visit: ${visit.label}');
    _box.put(visit);
  }

  Future<void> updateDeparture(int id, DateTime departure) async {
    final visit = _box.get(id);
    if (visit != null) {
      visit.departureTime = departure;
      _box.put(visit);
    }
  }

  Future<List<LocationVisitOB>> getRecentVisits({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final query = _box
        .query(LocationVisitOB_.arrivalTime.greaterThan(cutoff.millisecondsSinceEpoch))
        .order(LocationVisitOB_.arrivalTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<List<LocationVisitOB>> getVisitsByLabel(String label, {int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final query = _box
        .query(LocationVisitOB_.label.equals(label) &
            LocationVisitOB_.arrivalTime.greaterThan(cutoff.millisecondsSinceEpoch))
        .order(LocationVisitOB_.arrivalTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<int> getThisWeekGymCount() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final query = _box
        .query(LocationVisitOB_.label.equals('gym') &
            LocationVisitOB_.arrivalTime.greaterThan(weekStart.millisecondsSinceEpoch))
        .build();
    final count = query.count();
    query.close();
    return count;
  }

  Future<void> pruneOlderThan(DateTime cutoff) async {
    log.fine('Pruning location visits older than $cutoff');
    final query =
        _box.query(LocationVisitOB_.arrivalTime.lessThan(cutoff.millisecondsSinceEpoch)).build();
    final ids = query.findIds();
    query.close();
    _box.removeMany(ids);
  }
}
