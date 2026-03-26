import 'package:objectbox/objectbox.dart';

@Entity()
class WaterRecordOB {
  @Id()
  int id = 0;

  double amountML;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  WaterRecordOB({this.id = 0, required this.amountML, required this.dateTime});
}
