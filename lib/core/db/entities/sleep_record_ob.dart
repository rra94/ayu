import 'package:objectbox/objectbox.dart';

@Entity()
class SleepRecordOB {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime bedTime;

  @Property(type: PropertyType.date)
  DateTime wakeTime;

  /// Quality score 1-5
  int qualityScore;

  String? notes;

  /// "manual" or "healthkit"
  String source;

  /// Minutes in each sleep stage (from HealthKit)
  double? deepSleepMin;
  double? lightSleepMin;
  double? remSleepMin;
  double? awakeMin;

  SleepRecordOB({
    this.id = 0,
    required this.bedTime,
    required this.wakeTime,
    this.qualityScore = 3,
    this.notes,
    this.source = 'manual',
    this.deepSleepMin,
    this.lightSleepMin,
    this.remSleepMin,
    this.awakeMin,
  });

  double get durationHours =>
      wakeTime.difference(bedTime).inMinutes / 60.0;

  /// Computed sleep efficiency: (total - awake) / total * 100
  double get sleepEfficiency {
    final total = durationHours * 60;
    if (total <= 0) return 0;
    return ((total - (awakeMin ?? 0)) / total * 100).clamp(0, 100);
  }

  /// Sleep score 0-100 based on duration + stages + efficiency
  double get sleepScore {
    double score = 0;
    // Duration: 7-9h is optimal (max 40 points)
    final hours = durationHours;
    if (hours >= 7 && hours <= 9) {
      score += 40;
    } else if (hours >= 6) {
      score += 30;
    } else if (hours >= 5) {
      score += 20;
    } else {
      score += 10;
    }

    // Deep sleep: 15-25% is optimal (max 25 points)
    final totalMin = hours * 60;
    if (totalMin > 0 && deepSleepMin != null) {
      final deepPct = deepSleepMin! / totalMin * 100;
      if (deepPct >= 15 && deepPct <= 25) {
        score += 25;
      } else if (deepPct >= 10) {
        score += 15;
      } else {
        score += 5;
      }
    } else {
      score += 12; // unknown, give average
    }

    // REM: 20-25% is optimal (max 20 points)
    if (totalMin > 0 && remSleepMin != null) {
      final remPct = remSleepMin! / totalMin * 100;
      if (remPct >= 20 && remPct <= 25) {
        score += 20;
      } else if (remPct >= 15) {
        score += 12;
      } else {
        score += 5;
      }
    } else {
      score += 10;
    }

    // Efficiency (max 15 points)
    final eff = sleepEfficiency;
    if (eff >= 90) {
      score += 15;
    } else if (eff >= 80) {
      score += 10;
    } else {
      score += 5;
    }

    return score.clamp(0, 100);
  }
}
