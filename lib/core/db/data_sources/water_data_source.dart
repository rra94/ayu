import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/water_record_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class WaterDataSource {
  final log = Logger('WaterDataSource');
  final Box<WaterRecordOB> _waterBox;

  WaterDataSource(this._waterBox);

  Future<void> addWaterRecord(double amountML, DateTime dateTime) async {
    log.fine('Adding water record: ${amountML}ml');
    _waterBox.put(WaterRecordOB(amountML: amountML, dateTime: dateTime));
  }

  Future<List<WaterRecordOB>> getWaterByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _waterBox
        .query(WaterRecordOB_.dateTime.greaterOrEqualDate(startOfDay).and(
            WaterRecordOB_.dateTime.lessThanDate(endOfDay)))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<double> getTodayTotal() async {
    final today = DateTime.now();
    final records = await getWaterByDate(today);
    return records.fold<double>(0.0, (sum, r) => sum + r.amountML);
  }

  Future<void> deleteRecord(int id) async {
    log.fine('Deleting water record $id');
    _waterBox.remove(id);
  }

  Future<List<WaterRecordOB>> getAllRecords() async {
    return _waterBox.getAll();
  }
}
