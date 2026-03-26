import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';


enum UserWeightGoalDBO {
  loseWeight,
  maintainWeight,
  gainWeight;

  factory UserWeightGoalDBO.fromUserWeightGoalEntity(
      UserWeightGoalEntity goalEntity) {
    UserWeightGoalDBO weightGoalDBO;
    switch (goalEntity) {
      case UserWeightGoalEntity.loseWeight:
        weightGoalDBO = UserWeightGoalDBO.loseWeight;
        break;
      case UserWeightGoalEntity.maintainWeight:
        weightGoalDBO = UserWeightGoalDBO.maintainWeight;
        break;
      case UserWeightGoalEntity.gainWeight:
        weightGoalDBO = UserWeightGoalDBO.gainWeight;
        break;
    }
    return weightGoalDBO;
  }
}
