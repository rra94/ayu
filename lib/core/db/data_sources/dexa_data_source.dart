import 'package:opennutritracker/core/db/entities/dexa_scan_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class DexaDataSource {
  final Box<DexaScanOB> _box;

  DexaDataSource(this._box);

  Future<void> addScan(DexaScanOB scan) async {
    _box.put(scan);
  }

  Future<void> deleteScan(int id) async {
    _box.remove(id);
  }

  Future<List<DexaScanOB>> getAllScans() async {
    final query = _box.query()
      ..order(DexaScanOB_.scanDate, flags: Order.descending);
    final built = query.build();
    final results = built.find();
    built.close();
    return results;
  }
}
