import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/utils/calc/biological_age_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class BioAgeTrendPoint {
  final DateTime date;
  final double bioAge;
  final double chronoAge;

  BioAgeTrendPoint({
    required this.date,
    required this.bioAge,
    required this.chronoAge,
  });

  double get delta => bioAge - chronoAge; // negative = younger than actual age
}

class BioAgeTrendService {
  static final _log = Logger('BioAgeTrendService');

  /// Compute bio age at multiple time points from historical biomarker data.
  /// Groups biomarkers by date clusters (within 7 days = same test session).
  static Future<List<BioAgeTrendPoint>> getTrend() async {
    final bioDs = locator<BiomarkerDataSource>();
    final allRecords = await bioDs.getAllRecords();
    if (allRecords.isEmpty) return [];

    // Group records into test sessions (records within 7 days of each other)
    final sessions = <DateTime, Map<String, double>>{};
    for (final record in allRecords) {
      // Find or create session
      DateTime? sessionDate;
      for (final existing in sessions.keys) {
        if (record.dateTime.difference(existing).inDays.abs() <= 7) {
          sessionDate = existing;
          break;
        }
      }
      sessionDate ??= record.dateTime;
      sessions.putIfAbsent(sessionDate, () => {});
      sessions[sessionDate]![record.type] = record.value;
    }

    // Compute bio age for each session that has enough markers
    final points = <BioAgeTrendPoint>[];
    for (final entry in sessions.entries) {
      final markers = entry.value;
      // Need at least 3 of the 9 Levine markers for a meaningful estimate
      final levineKeys = BiologicalAgeCalc.requiredMarkers;
      final available = levineKeys.where((k) => markers.containsKey(k)).length;
      if (available < 3) continue;

      try {
        final result = BiologicalAgeCalc.computePhenoAge(markers, 30); // TODO: get actual chrono age from user profile
        if (result != null) {
          points.add(BioAgeTrendPoint(
            date: entry.key,
            bioAge: result.phenotypicAge,
            chronoAge: 30, // TODO: get actual age
          ));
        }
      } catch (e) {
        _log.warning('Failed to compute bio age for session ${entry.key}: $e');
      }
    }

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  /// Project bio age trend into the future.
  /// Returns projected bio age 6 months from now based on current trajectory.
  static Future<String?> getProjection() async {
    final trend = await getTrend();
    if (trend.length < 2) return null;

    final first = trend.first;
    final last = trend.last;
    final monthsBetween = last.date.difference(first.date).inDays / 30;
    if (monthsBetween < 1) return null;

    final deltaChange = last.delta - first.delta; // change in bio-chrono gap
    final ratePerMonth = deltaChange / monthsBetween;

    final projected6m = last.delta + (ratePerMonth * 6);

    if (ratePerMonth < -0.1) {
      return 'Your biological age is improving — projected ${projected6m.toStringAsFixed(1)} years ${projected6m < 0 ? "younger" : "older"} in 6 months if you keep this up.';
    } else if (ratePerMonth > 0.1) {
      return 'Your biological age is trending older — review sleep, nutrition, and stress management.';
    } else {
      return 'Biological age is stable. Consistent habits are maintaining your health.';
    }
  }
}
