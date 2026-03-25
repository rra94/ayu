import 'package:objectbox/objectbox.dart';

@Entity()
class ActivitySnapshotOB {
  @Id()
  int id = 0;

  /// stationary, walking, running, cycling, automotive, unknown
  String activityType;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  ActivitySnapshotOB({
    this.id = 0,
    required this.activityType,
    required this.dateTime,
  });
}
