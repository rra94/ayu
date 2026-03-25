import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/eco_score_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class EcoScoreDataSource {
  final log = Logger('EcoScoreDataSource');
  final Box<EcoScoreOB> _box;

  EcoScoreDataSource(this._box);

  /// Insert or update an eco-score record by productKey.
  Future<void> upsert(EcoScoreOB record) async {
    final query =
        _box.query(EcoScoreOB_.productKey.equals(record.productKey)).build();
    final existing = query.findFirst();
    query.close();

    if (existing != null) {
      record.id = existing.id;
    }
    _box.put(record);
  }

  /// Lookup a single eco-score by barcode/key.
  Future<EcoScoreOB?> getByProductKey(String key) async {
    final query = _box.query(EcoScoreOB_.productKey.equals(key)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  /// Return all stored eco-scores.
  Future<List<EcoScoreOB>> getAll() async {
    return _box.getAll();
  }

  /// Bulk lookup: return a map of productKey -> EcoScoreOB for the given keys.
  Future<Map<String, EcoScoreOB>> getByKeys(List<String> keys) async {
    final map = <String, EcoScoreOB>{};
    for (final key in keys) {
      final query = _box.query(EcoScoreOB_.productKey.equals(key)).build();
      final result = query.findFirst();
      query.close();
      if (result != null) {
        map[key] = result;
      }
    }
    return map;
  }
}
