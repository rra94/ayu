import 'package:objectbox/objectbox.dart';

@Entity()
class UserOB {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime birthday;

  double heightCM;
  double weightKG;

  /// 0=male, 1=female
  int gender;

  /// 0=lose, 1=maintain, 2=gain
  int goal;

  /// 0=sedentary, 1=lowActive, 2=active, 3=veryActive
  int pal;

  UserOB({
    this.id = 0,
    required this.birthday,
    required this.heightCM,
    required this.weightKG,
    required this.gender,
    required this.goal,
    required this.pal,
  });
}
