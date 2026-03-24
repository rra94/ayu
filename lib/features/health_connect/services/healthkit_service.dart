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
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  static const _permissions = [
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

      // Process sleep
      imported += await _syncSleep(dataPoints
          .where((d) => d.type == HealthDataType.SLEEP_ASLEEP)
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
    // Group sleep segments by night (same calendar date for wake time)
    // For simplicity, take the earliest and latest sleep timestamps per night
    final nights = <String, List<HealthDataPoint>>{};
    for (final point in points) {
      final wakeDate = point.dateTo;
      final key = '${wakeDate.year}-${wakeDate.month}-${wakeDate.day}';
      nights.putIfAbsent(key, () => []).add(point);
    }

    int count = 0;
    for (final entry in nights.entries) {
      final segments = entry.value;
      final bedTime = segments
          .map((s) => s.dateFrom)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final wakeTime = segments
          .map((s) => s.dateTo)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      await ds.addRecord(SleepRecordOB(
        bedTime: bedTime,
        wakeTime: wakeTime,
        qualityScore: 3, // default; user can edit
        source: 'healthkit',
      ));
      count++;
    }
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
