import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:opennutritracker/core/db/entities/tracked_day_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class TrackedDayDataSourceOB {
  final log = Logger('TrackedDayDataSourceOB');
  final Box<TrackedDayOB> _trackedDayBox;

  TrackedDayDataSourceOB(this._trackedDayBox);

  Future<void> saveTrackedDay(TrackedDayDBO trackedDayDBO) async {
    log.fine('Updating tracked day in db');
    // Upsert: find existing row for the same day or insert new
    final existing = _findByDay(trackedDayDBO.day);
    final ob = _trackedDayDBOToOB(trackedDayDBO);
    if (existing != null) {
      ob.id = existing.id; // overwrite same row
    }
    _trackedDayBox.put(ob);
  }

  Future<void> saveAllTrackedDays(List<TrackedDayDBO> trackedDayDBOList) async {
    log.fine('Updating tracked days in db');
    final obs = <TrackedDayOB>[];
    for (final dbo in trackedDayDBOList) {
      final existing = _findByDay(dbo.day);
      final ob = _trackedDayDBOToOB(dbo);
      if (existing != null) {
        ob.id = existing.id;
      }
      obs.add(ob);
    }
    _trackedDayBox.putMany(obs);
  }

  Future<List<TrackedDayDBO>> getAllTrackedDays() async {
    return _trackedDayBox.getAll().map(_trackedDayOBToDBO).toList();
  }

  Future<TrackedDayDBO?> getTrackedDay(DateTime day) async {
    final ob = _findByDay(day);
    return ob != null ? _trackedDayOBToDBO(ob) : null;
  }

  Future<List<TrackedDayDBO>> getTrackedDaysInRange(
      DateTime start, DateTime end) async {
    final all = _trackedDayBox.getAll();
    return all
        .where((ob) => ob.day.isAfter(start) && ob.day.isBefore(end))
        .map(_trackedDayOBToDBO)
        .toList();
  }

  Future<bool> hasTrackedDay(DateTime day) async => _findByDay(day) != null;

  Future<void> updateDayCalorieGoal(DateTime day, double calorieGoal) async {
    log.fine('Updating tracked day total calories');
    final ob = _findByDay(day);
    if (ob != null) {
      ob.calorieGoal = calorieGoal;
      _trackedDayBox.put(ob);
    }
  }

  Future<void> increaseDayCalorieGoal(DateTime day, double amount) async {
    log.fine('Increasing tracked day total calories');
    final ob = _findByDay(day);
    if (ob != null) {
      ob.calorieGoal += amount;
      _trackedDayBox.put(ob);
    }
  }

  Future<void> reduceDayCalorieGoal(DateTime day, double amount) async {
    log.fine('Reducing tracked day total calories');
    final ob = _findByDay(day);
    if (ob != null) {
      ob.calorieGoal -= amount;
      _trackedDayBox.put(ob);
    }
  }

  Future<void> addDayCaloriesTracked(DateTime day, double addCalories) async {
    log.fine('Adding new tracked day calories');
    final ob = _findByDay(day);
    if (ob != null) {
      ob.caloriesTracked += addCalories;
      _trackedDayBox.put(ob);
    }
  }

  Future<void> decreaseDayCaloriesTracked(
      DateTime day, double addCalories) async {
    log.fine('Decreasing tracked day calories');
    final ob = _findByDay(day);
    if (ob != null) {
      ob.caloriesTracked -= addCalories;
      _trackedDayBox.put(ob);
    }
  }

  Future<void> updateDayMacroGoals(DateTime day,
      {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {
    log.fine('Updating tracked day macro goals');
    final ob = _findByDay(day);
    if (ob != null) {
      if (carbsGoal != null) ob.carbsGoal = carbsGoal;
      if (fatGoal != null) ob.fatGoal = fatGoal;
      if (proteinGoal != null) ob.proteinGoal = proteinGoal;
      _trackedDayBox.put(ob);
    }
  }

  Future<void> increaseDayMacroGoal(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Increasing tracked day macro goals');
    final ob = _findByDay(day);
    if (ob != null) {
      if (carbsAmount != null) {
        ob.carbsGoal = (ob.carbsGoal ?? 0) + carbsAmount;
      }
      if (fatAmount != null) {
        ob.fatGoal = (ob.fatGoal ?? 0) + fatAmount;
      }
      if (proteinAmount != null) {
        ob.proteinGoal = (ob.proteinGoal ?? 0) + proteinAmount;
      }
      _trackedDayBox.put(ob);
    }
  }

  Future<void> reduceDayMacroGoal(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Reducing tracked day macro goals');
    final ob = _findByDay(day);
    if (ob != null) {
      if (carbsAmount != null) {
        ob.carbsGoal = (ob.carbsGoal ?? 0) - carbsAmount;
      }
      if (fatAmount != null) {
        ob.fatGoal = (ob.fatGoal ?? 0) - fatAmount;
      }
      if (proteinAmount != null) {
        ob.proteinGoal = (ob.proteinGoal ?? 0) - proteinAmount;
      }
      _trackedDayBox.put(ob);
    }
  }

  Future<void> addDayMacroTracked(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Adding new tracked day macro');
    final ob = _findByDay(day);
    if (ob != null) {
      if (carbsAmount != null) {
        ob.carbsTracked = (ob.carbsTracked ?? 0) + carbsAmount;
      }
      if (fatAmount != null) {
        ob.fatTracked = (ob.fatTracked ?? 0) + fatAmount;
      }
      if (proteinAmount != null) {
        ob.proteinTracked = (ob.proteinTracked ?? 0) + proteinAmount;
      }
      _trackedDayBox.put(ob);
    }
  }

  Future<void> removeDayMacroTracked(DateTime day,
      {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {
    log.fine('Removing tracked day macro');
    final ob = _findByDay(day);
    if (ob != null) {
      if (carbsAmount != null) {
        ob.carbsTracked = (ob.carbsTracked ?? 0) - carbsAmount;
      }
      if (fatAmount != null) {
        ob.fatTracked = (ob.fatTracked ?? 0) - fatAmount;
      }
      if (proteinAmount != null) {
        ob.proteinTracked = (ob.proteinTracked ?? 0) - proteinAmount;
      }
      _trackedDayBox.put(ob);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Find the OB entity whose [day] matches the given date (same calendar day).
  TrackedDayOB? _findByDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final query =
        _trackedDayBox.query(TrackedDayOB_.day.greaterOrEqualDate(startOfDay).and(
            TrackedDayOB_.day.lessThanDate(endOfDay))).build();
    final result = query.findFirst();
    query.close();
    return result;
  }
}

// ---------------------------------------------------------------------------
// DBO <-> OB converters
// ---------------------------------------------------------------------------

TrackedDayOB _trackedDayDBOToOB(TrackedDayDBO dbo) {
  return TrackedDayOB(
    day: dbo.day,
    calorieGoal: dbo.calorieGoal,
    caloriesTracked: dbo.caloriesTracked,
    carbsGoal: dbo.carbsGoal,
    carbsTracked: dbo.carbsTracked,
    fatGoal: dbo.fatGoal,
    fatTracked: dbo.fatTracked,
    proteinGoal: dbo.proteinGoal,
    proteinTracked: dbo.proteinTracked,
  );
}

TrackedDayDBO _trackedDayOBToDBO(TrackedDayOB ob) {
  return TrackedDayDBO(
    day: ob.day,
    calorieGoal: ob.calorieGoal,
    caloriesTracked: ob.caloriesTracked,
    carbsGoal: ob.carbsGoal,
    carbsTracked: ob.carbsTracked,
    fatGoal: ob.fatGoal,
    fatTracked: ob.fatTracked,
    proteinGoal: ob.proteinGoal,
    proteinTracked: ob.proteinTracked,
  );
}
