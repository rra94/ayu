import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/activity_snapshot_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class ActivitySnapshotDataSource {
  final log = Logger('ActivitySnapshotDataSource');
  final Box<ActivitySnapshotOB> _box;

  ActivitySnapshotDataSource(this._box);

  Future<void> addSnapshot(ActivitySnapshotOB snapshot) async {
    log.fine('Adding activity snapshot: ${snapshot.activityType}');
    _box.put(snapshot);
  }

  Future<List<ActivitySnapshotOB>> getTodaySnapshots() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _box
        .query(ActivitySnapshotOB_.dateTime.greaterOrEqualDate(startOfDay).and(
            ActivitySnapshotOB_.dateTime.lessThanDate(endOfDay)))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<ActivitySnapshotOB?> getLatestActivity() async {
    final query = _box
        .query()
        .order(ActivitySnapshotOB_.dateTime, flags: Order.descending)
        .build();
    query.limit = 1;
    final results = query.find();
    query.close();
    return results.isEmpty ? null : results.first;
  }

  Future<void> pruneOlderThan(DateTime cutoff) async {
    log.fine('Pruning activity snapshots older than $cutoff');
    final query =
        _box.query(ActivitySnapshotOB_.dateTime.lessThan(cutoff.millisecondsSinceEpoch)).build();
    final ids = query.findIds();
    query.close();
    _box.removeMany(ids);
  }
}
