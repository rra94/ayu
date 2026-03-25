import 'dart:math';

import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/entities/saved_location_ob.dart';
import 'package:objectbox/objectbox.dart';

class SavedLocationDataSource {
  final log = Logger('SavedLocationDataSource');
  final Box<SavedLocationOB> _box;

  SavedLocationDataSource(this._box);

  Future<void> addLocation(SavedLocationOB location) async {
    log.fine('Adding saved location: ${location.label}');
    _box.put(location);
  }

  Future<List<SavedLocationOB>> getAll() async {
    return _box.getAll();
  }

  Future<SavedLocationOB?> findNearby(double lat, double lon, double radiusM) async {
    final all = _box.getAll();
    for (final loc in all) {
      final distanceM = sqrt(pow(loc.lat - lat, 2) + pow(loc.lon - lon, 2)) * 111000;
      if (distanceM < radiusM) {
        return loc;
      }
    }
    return null;
  }

  Future<void> incrementVisitCount(int id) async {
    final location = _box.get(id);
    if (location != null) {
      location.visitCount++;
      _box.put(location);
    }
  }
}
