import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class GutHealthDataSource {
  final log = Logger('GutHealthDataSource');
  final Box<GutHealthItemOB> _gutHealthBox;

  GutHealthDataSource(this._gutHealthBox);

  Future<int> addItem(GutHealthItemOB item) async {
    log.fine('Adding gut health item: ${item.name}');
    return _gutHealthBox.put(item);
  }

  Future<List<GutHealthItemOB>> getItemsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _gutHealthBox
        .query(
            GutHealthItemOB_.dateTime.greaterOrEqualDate(startOfDay).and(
            GutHealthItemOB_.dateTime.lessThanDate(endOfDay)))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> deleteItem(int id) async {
    log.fine('Deleting gut health item $id');
    _gutHealthBox.remove(id);
  }

  Future<List<GutHealthItemOB>> getManualItemsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _gutHealthBox
        .query(GutHealthItemOB_.dateTime
            .greaterOrEqualDate(startOfDay).and(
            GutHealthItemOB_.dateTime.lessThanDate(endOfDay))
            .and(GutHealthItemOB_.isAutoFlagged.equals(false)))
        .build();
    final results = query.find();
    query.close();
    return results;
  }
}
