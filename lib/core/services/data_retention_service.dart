import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/activity_snapshot_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/eco_score_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/pressure_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/search_history_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/food_cache_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class DataRetentionService {
  static final _log = Logger('DataRetentionService');

  /// Prune old sensor data. Call once on app start.
  static Future<void> pruneOldData() async {
    try {
      final cutoff90 = DateTime.now().subtract(const Duration(days: 90));
      final cutoff30 = DateTime.now().subtract(const Duration(days: 30));

      await locator<ActivitySnapshotDataSource>().pruneOlderThan(cutoff90);
      await locator<LocationVisitDataSource>().pruneOlderThan(cutoff30);
      await locator<PressureDataSource>().pruneOlderThan(cutoff90);
      await locator<EcoScoreDataSource>().pruneStale(
        DateTime.now().subtract(const Duration(days: 180)),
      );
      await locator<SearchHistoryDataSource>().prune();
      await locator<FoodCacheDataSource>().prune();

      // Prune historical logs (keep 1 year)
      final cutoff365 = DateTime.now().subtract(const Duration(days: 365));
      try { await locator<CaffeineDataSource>().pruneOlderThan(cutoff365); } catch (_) {}
      try { await locator<SymptomDataSource>().pruneOlderThan(cutoff365); } catch (_) {}
      try { await locator<SleepDataSource>().pruneOlderThan(cutoff365); } catch (_) {}

      _log.info('Data retention pruning complete');
    } catch (e) {
      _log.warning('Data retention pruning failed: $e');
    }
  }
}
