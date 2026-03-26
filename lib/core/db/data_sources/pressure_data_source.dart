import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/pressure_reading_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class PressureDataSource {
  final log = Logger('PressureDataSource');
  final Box<PressureReadingOB> _box;

  PressureDataSource(this._box);

  Future<void> addReading(PressureReadingOB reading) async {
    log.fine('Adding pressure reading: ${reading.pressureKPa} kPa');
    _box.put(reading);
  }

  Future<List<PressureReadingOB>> getTodayReadings() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _box
        .query(PressureReadingOB_.dateTime.greaterOrEqualDate(startOfDay).and(
            PressureReadingOB_.dateTime.lessThanDate(endOfDay)))
        .order(PressureReadingOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<List<PressureReadingOB>> getReadingsForDateRange(
      DateTime start, DateTime end) async {
    final query = _box
        .query(PressureReadingOB_.dateTime.betweenDate(start, end))
        .order(PressureReadingOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> pruneOlderThan(DateTime cutoff) async {
    log.fine('Pruning pressure readings older than $cutoff');
    final query =
        _box.query(PressureReadingOB_.dateTime.lessThan(cutoff.millisecondsSinceEpoch)).build();
    final ids = query.findIds();
    query.close();
    _box.removeMany(ids);
  }
}
