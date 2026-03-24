import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class BiomarkerDataSource {
  final Box<BiomarkerRecordOB> _box;

  BiomarkerDataSource(this._box);

  Future<void> addRecord(BiomarkerRecordOB record) async {
    _box.put(record);
  }

  Future<void> deleteRecord(int id) async {
    _box.remove(id);
  }

  Future<List<BiomarkerRecordOB>> getAllRecords() async {
    final query = _box.query()
      ..order(BiomarkerRecordOB_.dateTime, flags: Order.descending);
    final built = query.build();
    final results = built.find();
    built.close();
    return results;
  }

  Future<List<BiomarkerRecordOB>> getRecordsByType(String type) async {
    final query = _box
        .query(BiomarkerRecordOB_.type.equals(type))
        .order(BiomarkerRecordOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  /// Get the latest value for each biomarker type
  Future<Map<String, BiomarkerRecordOB>> getLatestByType() async {
    final all = await getAllRecords();
    final latest = <String, BiomarkerRecordOB>{};
    for (final record in all) {
      if (!latest.containsKey(record.type)) {
        latest[record.type] = record;
      }
    }
    return latest;
  }
}
