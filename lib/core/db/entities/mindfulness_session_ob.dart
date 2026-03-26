import 'package:objectbox/objectbox.dart';

@Entity()
class MindfulnessSessionOB {
  @Id()
  int id = 0;

  /// 0=nsdr, 1=meditation, 2=breathwork, 3=yoga_nidra, 4=custom
  int type;

  int durationMinutes;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  MindfulnessSessionOB({
    this.id = 0,
    required this.type,
    required this.durationMinutes,
    required this.dateTime,
  });

  static const typeNames = ['NSDR', 'Meditation', 'Breathwork', 'Yoga Nidra', 'Custom'];
  static const defaultDurations = [10, 20, 5, 30, 10];

  String get typeName =>
      type >= 0 && type < typeNames.length ? typeNames[type] : 'Custom';
}
