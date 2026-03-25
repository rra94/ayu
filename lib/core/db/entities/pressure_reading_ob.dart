import 'package:objectbox/objectbox.dart';

@Entity()
class PressureReadingOB {
  @Id()
  int id = 0;

  /// Absolute barometric pressure in kPa
  double pressureKPa;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  PressureReadingOB({
    this.id = 0,
    required this.pressureKPa,
    required this.dateTime,
  });
}
