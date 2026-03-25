import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class HRVTrend {
  final double currentHRV;
  final double weekAvg;
  final double monthAvg;
  final String trend; // 'improving', 'declining', 'stable'
  final double recoveryScore; // 0-100 based on HRV relative to personal baseline

  HRVTrend({
    required this.currentHRV,
    required this.weekAvg,
    required this.monthAvg,
    required this.trend,
    required this.recoveryScore,
  });
}

class HRRecoveryResult {
  final double preWorkoutHR; // resting HR before workout
  final double peakHR; // max during workout
  final double oneMinRecovery; // HR drop in first minute post-workout
  final double twoMinRecovery; // HR drop in first 2 minutes
  final String fitnessLevel; // 'excellent', 'good', 'average', 'below_average'

  HRRecoveryResult({
    required this.preWorkoutHR,
    required this.peakHR,
    required this.oneMinRecovery,
    required this.twoMinRecovery,
    required this.fitnessLevel,
  });
}

class HRVAnalysisService {
  static final _log = Logger('HRVAnalysisService');

  /// Analyze HRV trends over time.
  /// Returns null if no HRV data is available.
  static Future<HRVTrend?> analyzeTrend() async {
    final bioDs = locator<BiomarkerDataSource>();
    final hrvRecords = await bioDs.getRecordsByType('hrv_sdnn');
    if (hrvRecords.isEmpty) return null;

    final now = DateTime.now();
    final currentHRV = hrvRecords.first.value;

    // Week average (last 7 days)
    final weekRecords = hrvRecords
        .where((r) => now.difference(r.dateTime).inDays <= 7)
        .toList();
    final weekAvg = weekRecords.isNotEmpty
        ? weekRecords.map((r) => r.value).reduce((a, b) => a + b) /
            weekRecords.length
        : currentHRV;

    // Month average (last 30 days)
    final monthRecords = hrvRecords
        .where((r) => now.difference(r.dateTime).inDays <= 30)
        .toList();
    final monthAvg = monthRecords.isNotEmpty
        ? monthRecords.map((r) => r.value).reduce((a, b) => a + b) /
            monthRecords.length
        : currentHRV;

    // Trend detection: compare most recent 3-day average against monthly baseline
    String trend = 'stable';
    if (weekRecords.length >= 3) {
      final recentAvg =
          weekRecords.take(3).map((r) => r.value).reduce((a, b) => a + b) / 3;
      if (recentAvg > monthAvg * 1.05) {
        trend = 'improving';
      } else if (recentAvg < monthAvg * 0.95) {
        trend = 'declining';
      }
    }

    // Recovery score: current HRV relative to personal monthly baseline.
    // Score is clamped 0–100; baseline maps to ~70.
    final baseline = monthAvg > 0 ? monthAvg : 1.0;
    final recoveryScore =
        ((currentHRV / baseline) * 70).clamp(0.0, 100.0).toDouble();

    _log.info(
        'HRV trend: current=$currentHRV weekAvg=$weekAvg monthAvg=$monthAvg '
        'trend=$trend recoveryScore=$recoveryScore');

    return HRVTrend(
      currentHRV: currentHRV,
      weekAvg: weekAvg,
      monthAvg: monthAvg,
      trend: trend,
      recoveryScore: recoveryScore,
    );
  }

  /// Analyze HR recovery using workout HR biomarkers where available,
  /// falling back to resting HR as a fitness proxy.
  static Future<HRRecoveryResult?> analyzeHRRecovery() async {
    final bioDs = locator<BiomarkerDataSource>();

    final hrRecords = await bioDs.getRecordsByType('resting_hr');
    final workoutRecords = await bioDs.getRecordsByType('workout_hr');

    if (hrRecords.isEmpty) return null;

    final restingHR = hrRecords.first.value;

    // If workout_hr records exist, compute peak and recovery drop
    if (workoutRecords.length >= 2) {
      final peak = workoutRecords
          .map((r) => r.value)
          .reduce((a, b) => a > b ? a : b);
      // workoutRecords are ordered newest-first; last entry is the post-workout reading
      final postWorkout = workoutRecords.last.value;
      final recovery = peak - postWorkout;

      String fitness;
      if (recovery > 40) {
        fitness = 'excellent';
      } else if (recovery > 30) {
        fitness = 'good';
      } else if (recovery > 20) {
        fitness = 'average';
      } else {
        fitness = 'below_average';
      }

      _log.info(
          'HR recovery: peak=$peak postWorkout=$postWorkout drop=$recovery fitness=$fitness');

      return HRRecoveryResult(
        preWorkoutHR: restingHR,
        peakHR: peak,
        oneMinRecovery: recovery,
        twoMinRecovery: recovery * 1.3, // linear estimate for 2-min window
        fitnessLevel: fitness,
      );
    }

    // Fallback: classify fitness from resting HR alone (well-established ranges)
    String fitness;
    if (restingHR < 55) {
      fitness = 'excellent';
    } else if (restingHR < 65) {
      fitness = 'good';
    } else if (restingHR < 75) {
      fitness = 'average';
    } else {
      fitness = 'below_average';
    }

    _log.info(
        'HR recovery (resting-HR fallback): restingHR=$restingHR fitness=$fitness');

    return HRRecoveryResult(
      preWorkoutHR: restingHR,
      peakHR: restingHR, // no separate workout peak available
      oneMinRecovery: 0,
      twoMinRecovery: 0,
      fitnessLevel: fitness,
    );
  }

  /// Derive a 1–5 stress level from HRV recovery score.
  /// 1 = low stress (high HRV), 5 = high stress (low HRV).
  /// Returns 3 (neutral/unknown) when no HRV data is present.
  static Future<int> getStressLevel() async {
    final trend = await analyzeTrend();
    if (trend == null) return 3;

    final score = trend.recoveryScore;
    if (score >= 80) return 1;
    if (score >= 65) return 2;
    if (score >= 50) return 3;
    if (score >= 35) return 4;
    return 5;
  }
}
