import 'package:objectbox/objectbox.dart';

@Entity()
class StoolLogOB {
  @Id()
  int id = 0;

  /// Bristol Stool Scale type (1-7)
  int type;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  String? notes;

  StoolLogOB({
    this.id = 0,
    required this.type,
    required this.dateTime,
    this.notes,
  });
}
