import 'package:objectbox/objectbox.dart';

@Entity()
class HabitLogOB {
  @Id()
  int id = 0;

  int habitId; // references HabitOB.id

  @Property(type: PropertyType.date)
  DateTime dateTime;

  bool completed;

  HabitLogOB({
    this.id = 0,
    required this.habitId,
    required this.dateTime,
    this.completed = false,
  });
}
