import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class FastingDataSource {
  final Box<FastingSessionOB> _box;

  FastingDataSource(this._box);

  Future<void> saveSession(FastingSessionOB session) async {
    _box.put(session);
  }

  Future<void> deleteSession(int id) async {
    _box.remove(id);
  }

  Future<FastingSessionOB?> getActiveSession() async {
    final query = _box
        .query(FastingSessionOB_.endTime.isNull())
        .order(FastingSessionOB_.startTime, flags: Order.descending)
        .build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<List<FastingSessionOB>> getAllSessions() async {
    final query = _box.query()
        .order(FastingSessionOB_.startTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<List<FastingSessionOB>> getCompletedSessions({int limit = 30}) async {
    final query = _box
        .query(FastingSessionOB_.endTime.notNull())
        .order(FastingSessionOB_.startTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results.take(limit).toList();
  }
}
