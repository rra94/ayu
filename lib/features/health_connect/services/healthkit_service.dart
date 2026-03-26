import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/weight_data_source.dart';
import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/db/entities/sleep_record_ob.dart';
import 'package:opennutritracker/core/db/entities/weight_record_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class HealthKitService {
  static final _log = Logger('HealthKitService');
  static final _health = Health();

  static const _types = [
    HealthDataType.WEIGHT,
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  static const _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Request HealthKit permissions. Returns true if authorized.
  static Future<bool> requestPermissions() async {
    try {
      final authorized = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      _log.info('HealthKit authorization: $authorized');
      return authorized;
    } catch (e) {
      _log.severe('HealthKit authorization failed: $e');
      return false;
    }
  }

  /// Check if HealthKit permissions are granted
  static Future<bool> hasPermissions() async {
    try {
      final result = await _health.hasPermissions(_types,
          permissions: _permissions);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// First-ever sync: pull 90 days of history to kickstart circadian profile,
  /// HRV baselines, and sleep score trends. Call once after permissions granted.
  static Future<SyncResult> syncInitial() async {
    _log.info('Running initial 90-day HealthKit backfill');
    return sync(days: 90);
  }

  /// Sync data from HealthKit for the last [days] days.
  static Future<SyncResult> sync({int days = 7}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    int imported = 0;

    try {
      final dataPoints = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: now,
      );

      _log.info('HealthKit returned ${dataPoints.length} data points');

      // Process weight
      imported += await _syncWeight(dataPoints
          .where((d) => d.type == HealthDataType.WEIGHT)
          .toList());

      // Process sleep (all stage types)
      imported += await _syncSleep(dataPoints
          .where((d) =>
              d.type == HealthDataType.SLEEP_ASLEEP ||
              d.type == HealthDataType.SLEEP_DEEP ||
              d.type == HealthDataType.SLEEP_LIGHT ||
              d.type == HealthDataType.SLEEP_REM ||
              d.type == HealthDataType.SLEEP_AWAKE)
          .toList());

      // Process heart rate (store as biomarker)
      imported += await _syncBiomarker(
        dataPoints
            .where((d) => d.type == HealthDataType.HEART_RATE)
            .toList(),
        'resting_hr',
        'bpm',
      );

      // Process HRV
      imported += await _syncBiomarker(
        dataPoints
            .where((d) =>
                d.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN)
            .toList(),
        'hrv_sdnn',
        'ms',
      );

      // Process active energy burned (store as daily biomarker)
      imported += await _syncBiomarker(
        dataPoints
            .where((d) => d.type == HealthDataType.ACTIVE_ENERGY_BURNED)
            .toList(),
        'active_energy',
        'kcal',
      );

      // Process steps
      imported += await _syncBiomarker(
        dataPoints
            .where((d) => d.type == HealthDataType.STEPS)
            .toList(),
        'steps',
        'count',
      );

      // Process workouts: extract peak HR within each workout window
      final workouts = dataPoints
          .where((d) => d.type == HealthDataType.WORKOUT)
          .toList();
      if (workouts.isNotEmpty) {
        _log.info('Found ${workouts.length} workouts from HealthKit');
        final hrPoints = dataPoints
            .where((d) => d.type == HealthDataType.HEART_RATE)
            .toList();
        imported += await _syncWorkoutHR(workouts, hrPoints);
      }

      return SyncResult(success: true, importedCount: imported);
    } catch (e) {
      _log.severe('HealthKit sync error: $e');
      return SyncResult(success: false, importedCount: imported, error: '$e');
    }
  }

  static Future<int> _syncWeight(List<HealthDataPoint> points) async {
    if (points.isEmpty) return 0;
    final ds = locator<WeightDataSource>();
    final existing = await ds.getAllRecords();
    final existingDates = existing
        .map((r) => '${r.dateTime.year}-${r.dateTime.month}-${r.dateTime.day}')
        .toSet();

    int count = 0;
    for (final point in points) {
      final dayKey =
          '${point.dateFrom.year}-${point.dateFrom.month}-${point.dateFrom.day}';
      if (existingDates.contains(dayKey)) continue;

      final value = (point.value as NumericHealthValue).numericValue;
      await ds.addRecord(WeightRecordOB(
        weightKG: value.toDouble(),
        dateTime: point.dateFrom,
      ));
      existingDates.add(dayKey);
      count++;
    }
    return count;
  }

  static Future<int> _syncSleep(List<HealthDataPoint> points) async {
    if (points.isEmpty) return 0;
    final ds = locator<SleepDataSource>();

    // Group all sleep segments by night (keyed on the wake date of each point)
    final nights = <String, List<HealthDataPoint>>{};
    for (final point in points) {
      final wakeDate = point.dateTo;
      final key = '${wakeDate.year}-${wakeDate.month}-${wakeDate.day}';
      nights.putIfAbsent(key, () => []).add(point);
    }

    int count = 0;
    for (final entry in nights.entries) {
      final segments = entry.value;

      // Determine bed/wake window across all segments for this night
      final bedTime = segments
          .map((s) => s.dateFrom)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final wakeTime = segments
          .map((s) => s.dateTo)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      // Sum stage durations in minutes
      double sumMinutes(HealthDataType type) => segments
          .where((s) => s.type == type)
          .fold<double>(
              0,
              (acc, s) =>
                  acc + s.dateTo.difference(s.dateFrom).inMinutes.toDouble());

      final deepMin = sumMinutes(HealthDataType.SLEEP_DEEP);
      final lightMin = sumMinutes(HealthDataType.SLEEP_LIGHT);
      final remMin = sumMinutes(HealthDataType.SLEEP_REM);
      final awakeMin = sumMinutes(HealthDataType.SLEEP_AWAKE);

      final hasStageData = deepMin > 0 || lightMin > 0 || remMin > 0;

      final record = SleepRecordOB(
        bedTime: bedTime,
        wakeTime: wakeTime,
        source: 'healthkit',
        deepSleepMin: hasStageData ? deepMin : null,
        lightSleepMin: hasStageData ? lightMin : null,
        remSleepMin: hasStageData ? remMin : null,
        awakeMin: awakeMin > 0 ? awakeMin : null,
      );

      // Auto-calculate quality score from sleepScore (map 0-100 to 1-5)
      final score = record.sleepScore;
      record.qualityScore = (score / 20).ceil().clamp(1, 5);

      await ds.addRecord(record);
      count++;
    }
    return count;
  }

  /// For each workout, find overlapping HR data points and store the peak
  /// as a 'workout_hr' biomarker keyed to the workout start date.
  static Future<int> _syncWorkoutHR(
    List<HealthDataPoint> workouts,
    List<HealthDataPoint> hrPoints,
  ) async {
    if (hrPoints.isEmpty) return 0;
    final ds = locator<BiomarkerDataSource>();
    int count = 0;

    for (final workout in workouts) {
      final workoutStart = workout.dateFrom;
      final workoutEnd = workout.dateTo;

      // Collect HR readings that fall within the workout window
      final overlapping = hrPoints.where((hr) {
        return !hr.dateFrom.isAfter(workoutEnd) &&
            !hr.dateTo.isBefore(workoutStart);
      }).toList();

      if (overlapping.isEmpty) continue;

      final peakHR = overlapping
          .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
          .reduce((a, b) => a > b ? a : b);

      await ds.addRecord(BiomarkerRecordOB(
        type: 'workout_hr',
        value: peakHR,
        unit: 'bpm',
        dateTime: workoutStart,
        source: 1, // auto from healthkit
      ));
      count++;
    }

    _log.info('Stored $count workout peak HR biomarkers');
    return count;
  }

  static Future<int> _syncBiomarker(
    List<HealthDataPoint> points,
    String type,
    String unit,
  ) async {
    if (points.isEmpty) return 0;
    final ds = locator<BiomarkerDataSource>();

    // Take daily average
    final dailyValues = <String, List<double>>{};
    for (final point in points) {
      final key =
          '${point.dateFrom.year}-${point.dateFrom.month}-${point.dateFrom.day}';
      final value = (point.value as NumericHealthValue).numericValue;
      dailyValues.putIfAbsent(key, () => []).add(value.toDouble());
    }

    int count = 0;
    for (final entry in dailyValues.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final parts = entry.key.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));

      await ds.addRecord(BiomarkerRecordOB(
        type: type,
        value: avg,
        unit: unit,
        dateTime: date,
        source: 1, // auto from healthkit
      ));
      count++;
    }
    return count;
  }
}

class SyncResult {
  final bool success;
  final int importedCount;
  final String? error;

  SyncResult({required this.success, required this.importedCount, this.error});
}
