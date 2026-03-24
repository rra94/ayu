import 'package:opennutritracker/core/db/entities/supplement_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class SupplementDataSource {
  final Box<SupplementOB> _supplementBox;
  final Box<SupplementLogOB> _logBox;

  SupplementDataSource(this._supplementBox, this._logBox);

  Future<void> addSupplement(SupplementOB supplement) async {
    _supplementBox.put(supplement);
  }

  Future<void> updateSupplement(SupplementOB supplement) async {
    _supplementBox.put(supplement);
  }

  Future<void> deleteSupplement(int id) async {
    _supplementBox.remove(id);
  }

  Future<List<SupplementOB>> getAllActive() async {
    final query = _supplementBox
        .query(SupplementOB_.isActive.equals(true))
        .order(SupplementOB_.sortOrder)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> toggleLog(int supplementId, DateTime date, bool taken) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _logBox
        .query(SupplementLogOB_.supplementId.equals(supplementId).and(
            SupplementLogOB_.dateTime.betweenDate(startOfDay, endOfDay)))
        .build();
    final existing = query.findFirst();
    query.close();

    if (existing != null) {
      existing.taken = taken;
      _logBox.put(existing);
    } else {
      _logBox.put(SupplementLogOB(
        supplementId: supplementId,
        taken: taken,
        dateTime: date,
      ));
    }
  }

  Future<Set<int>> getTakenIdsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _logBox
        .query(SupplementLogOB_.dateTime.betweenDate(startOfDay, endOfDay).and(
            SupplementLogOB_.taken.equals(true)))
        .build();
    final results = query.find();
    query.close();
    return results.map((l) => l.supplementId).toSet();
  }

  Future<List<SupplementLogOB>> getLogsForDateRange(
      DateTime start, DateTime end) async {
    final query = _logBox
        .query(SupplementLogOB_.dateTime.betweenDate(start, end))
        .build();
    final results = query.find();
    query.close();
    return results;
  }
}
