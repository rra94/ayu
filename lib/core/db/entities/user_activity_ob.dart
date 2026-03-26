import 'package:objectbox/objectbox.dart';

@Entity()
class UserActivityOB {
  @Id()
  int id = 0;

  @Unique()
  String activityId;

  double duration;
  double burnedKcal;

  @Property(type: PropertyType.date)
  DateTime date;

  // ---------------------------------------------------------------------------
  // Physical activity fields (flattened)
  // ---------------------------------------------------------------------------
  String activityCode;
  String specificActivity;
  String description;
  double mets;
  List<String> tags;

  /// 0=bicycling, 1=conditioning, 2=dancing, 3=running, 4=sport, 5=water, 6=winter
  int activityType;

  UserActivityOB({
    this.id = 0,
    required this.activityId,
    required this.duration,
    required this.burnedKcal,
    required this.date,
    required this.activityCode,
    required this.specificActivity,
    this.description = '',
    required this.mets,
    this.tags = const [],
    required this.activityType,
  });
}
