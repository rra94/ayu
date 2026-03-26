import 'package:opennutritracker/core/db/entities/weight_record_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class WeightDataSource {
  final Box<WeightRecordOB> _box;

  WeightDataSource(this._box);

  Future<void> addRecord(WeightRecordOB record) async {
    _box.put(record);
  }

  Future<void> deleteRecord(int id) async {
    _box.remove(id);
  }

  Future<List<WeightRecordOB>> getAllRecords() async {
    final query = _box.query()
      ..order(WeightRecordOB_.dateTime);
    final built = query.build();
    final results = built.find();
    built.close();
    return results;
  }

  Future<WeightRecordOB?> getLatestRecord() async {
    final query = _box.query()
      ..order(WeightRecordOB_.dateTime, flags: Order.descending);
    final built = query.build();
    final result = built.findFirst();
    built.close();
    return result;
  }
}
