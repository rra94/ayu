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

  SleepRecordOB({
    this.id = 0,
    required this.bedTime,
    required this.wakeTime,
    this.qualityScore = 3,
    this.notes,
    this.source = 'manual',
  });

  double get durationHours =>
      wakeTime.difference(bedTime).inMinutes / 60.0;
}
