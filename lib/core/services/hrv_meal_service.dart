import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/db/entities/sleep_record_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

class HrvMealResult {
  final double earlyDinnerAvgHrv;
  final double lateDinnerAvgHrv;
  final int earlyCount;
  final int lateCount;
  final int totalNights;

  HrvMealResult({
    required this.earlyDinnerAvgHrv,
    required this.lateDinnerAvgHrv,
    required this.earlyCount,
    required this.lateCount,
    required this.totalNights,
  });

  bool get hasEnoughData => totalNights >= 14 && earlyCount >= 5 && lateCount >= 5;

  double get percentDifference {
    if (lateDinnerAvgHrv == 0) return 0;
    return ((earlyDinnerAvgHrv - lateDinnerAvgHrv) / lateDinnerAvgHrv * 100);
  }

  String get insightText {
    if (!hasEnoughData) {
      return 'Tracking HRV vs. meal timing... $totalNights/14 nights recorded.';
    }
    final pct = percentDifference.abs().toStringAsFixed(0);
    if (earlyDinnerAvgHrv > lateDinnerAvgHrv) {
      return 'Your overnight HRV averages ${earlyDinnerAvgHrv.round()} ms on early-dinner nights vs ${lateDinnerAvgHrv.round()} ms on late-dinner nights ($pct% higher with early dinner).';
    }
    return 'No significant difference found between early and late dinner nights (${earlyDinnerAvgHrv.round()} vs ${lateDinnerAvgHrv.round()} ms).';
  }
}

class HrvMealService {
  /// Correlate overnight HRV with last meal timing.
  /// Early dinner = last meal >= 3h before bed.
  /// Late dinner = last meal < 3h before bed.
  static HrvMealResult? compute({
    required List<BiomarkerRecordOB> hrvRecords,
    required List<SleepRecordOB> sleepRecords,
    required List<IntakeEntity> allIntakes,
  }) {
    if (hrvRecords.isEmpty || sleepRecords.isEmpty || allIntakes.isEmpty) {
      return null;
    }

    // Group HRV by date
    final hrvByDate = <String, double>{};
    for (final r in hrvRecords) {
      if (r.type == 'hrv_sdnn') {
        hrvByDate[_dayKey(r.dateTime)] = r.value;
      }
    }

    // Group last meal time by date
    final lastMealByDate = <String, DateTime>{};
    for (final intake in allIntakes) {
      final key = _dayKey(intake.dateTime);
      final existing = lastMealByDate[key];
      if (existing == null || intake.dateTime.isAfter(existing)) {
        lastMealByDate[key] = intake.dateTime;
      }
    }

    // Match nights: for each sleep record, get prev day's last meal + next morning HRV
    final earlyHrvs = <double>[];
    final lateHrvs = <double>[];

    for (final sleep in sleepRecords) {
      final bedDate = sleep.bedTime;
      final wakeDate = sleep.wakeTime;

      // Last meal on the bed day
      final mealKey = _dayKey(bedDate);
      final lastMeal = lastMealByDate[mealKey];
      if (lastMeal == null) continue;

      // HRV for the wake day (overnight measurement)
      final hrvKey = _dayKey(wakeDate);
      final hrv = hrvByDate[hrvKey];
      if (hrv == null) continue;

      // Gap between last meal and bedtime
      final gapHours = bedDate.difference(lastMeal).inMinutes / 60.0;

      if (gapHours >= 3) {
        earlyHrvs.add(hrv);
      } else {
        lateHrvs.add(hrv);
      }
    }

    final totalNights = earlyHrvs.length + lateHrvs.length;
    if (totalNights == 0) return null;

    final earlyAvg = earlyHrvs.isEmpty
        ? 0.0
        : earlyHrvs.reduce((a, b) => a + b) / earlyHrvs.length;
    final lateAvg = lateHrvs.isEmpty
        ? 0.0
        : lateHrvs.reduce((a, b) => a + b) / lateHrvs.length;

    return HrvMealResult(
      earlyDinnerAvgHrv: earlyAvg,
      lateDinnerAvgHrv: lateAvg,
      earlyCount: earlyHrvs.length,
      lateCount: lateHrvs.length,
      totalNights: totalNights,
    );
  }

  static String _dayKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
