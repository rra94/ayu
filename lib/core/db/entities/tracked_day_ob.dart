import 'package:objectbox/objectbox.dart';

@Entity()
class TrackedDayOB {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime day;

  double calorieGoal;
  double caloriesTracked;
  double? carbsGoal;
  double? carbsTracked;
  double? fatGoal;
  double? fatTracked;
  double? proteinGoal;
  double? proteinTracked;

  TrackedDayOB({
    this.id = 0,
    required this.day,
    required this.calorieGoal,
    required this.caloriesTracked,
    this.carbsGoal,
    this.carbsTracked,
    this.fatGoal,
    this.fatTracked,
    this.proteinGoal,
    this.proteinTracked,
  });
}
