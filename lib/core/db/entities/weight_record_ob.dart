import 'package:objectbox/objectbox.dart';

@Entity()
class WeightRecordOB {
  @Id()
  int id = 0;

  double weightKG;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  WeightRecordOB({
    this.id = 0,
    required this.weightKG,
    required this.dateTime,
  });
}
