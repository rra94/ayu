import 'package:opennutritracker/core/db/entities/symptom_log_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class SymptomDataSource {
  final Box<SymptomLogOB> _box;

  SymptomDataSource(this._box);

  Future<void> addLog(SymptomLogOB log) async {
    _box.put(log);
  }

  Future<void> deleteLog(int id) async {
    _box.remove(id);
  }

  Future<List<SymptomLogOB>> getAllLogs() async {
    final query = _box.query()
      ..order(SymptomLogOB_.dateTime, flags: Order.descending);
    final built = query.build();
    final results = built.find();
    built.close();
    return results;
  }

  Future<List<SymptomLogOB>> getLogsByDateRange(
      DateTime start, DateTime end) async {
    final query = _box
        .query(SymptomLogOB_.dateTime.betweenDate(start, end))
        .order(SymptomLogOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }
}
