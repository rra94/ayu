import 'package:opennutritracker/core/db/entities/mindfulness_session_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class MindfulnessDataSource {
  final Box<MindfulnessSessionOB> _box;

  MindfulnessDataSource(this._box);

  Future<void> addSession(MindfulnessSessionOB session) async {
    _box.put(session);
  }

  Future<void> deleteSession(int id) async {
    _box.remove(id);
  }

  Future<List<MindfulnessSessionOB>> getSessionsThisWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final query = _box
        .query(MindfulnessSessionOB_.dateTime
            .greaterOrEqual(start.millisecondsSinceEpoch))
        .order(MindfulnessSessionOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<List<MindfulnessSessionOB>> getRecentSessions({int limit = 20}) async {
    final query = _box.query()
      ..order(MindfulnessSessionOB_.dateTime, flags: Order.descending);
    final built = query.build();
    final results = built.find();
    built.close();
    return results.take(limit).toList();
  }
}
