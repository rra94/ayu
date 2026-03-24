import 'package:opennutritracker/core/data/dbo/user_gender_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_pal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';


class UserDBO {
  DateTime birthday;
  double heightCM;
  double weightKG;
  UserGenderDBO gender;
  UserWeightGoalDBO goal;
  UserPALDBO pal;

  UserDBO(
      {required this.birthday,
      required this.heightCM,
      required this.weightKG,
      required this.gender,
      required this.goal,
      required this.pal});

  factory UserDBO.fromUserEntity(UserEntity entity) {
    return UserDBO(
        birthday: entity.birthday,
        heightCM: entity.heightCM,
        weightKG: entity.weightKG,
        gender: UserGenderDBO.fromUserGenderEntity(entity.gender),
        goal: UserWeightGoalDBO.fromUserWeightGoalEntity(entity.goal),
        pal: UserPALDBO.fromUserPALEntity(entity.pal));
  }
}
