import 'package:opennutritracker/core/db/entities/sleep_record_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class SleepDataSource {
  final Box<SleepRecordOB> _box;

  SleepDataSource(this._box);

  Future<void> addRecord(SleepRecordOB record) async {
    _box.put(record);
  }

  Future<void> deleteRecord(int id) async {
    _box.remove(id);
  }

  Future<List<SleepRecordOB>> getRecords({int limit = 30}) async {
    final query = _box.query()
      ..order(SleepRecordOB_.wakeTime, flags: Order.descending);
    final built = query.build();
    final results = built.find();
    built.close();
    return results.take(limit).toList();
  }

  Future<SleepRecordOB?> getLastNight() async {
    final query = _box.query()
      ..order(SleepRecordOB_.wakeTime, flags: Order.descending);
    final built = query.build();
    final result = built.findFirst();
    built.close();
    return result;
  }
}
