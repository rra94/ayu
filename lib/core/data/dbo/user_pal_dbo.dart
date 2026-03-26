import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';


enum UserPALDBO {
  sedentary,
  lowActive,
  active,
  veryActive;

  factory UserPALDBO.fromUserPALEntity(UserPALEntity palEntity) {
    UserPALDBO palDBO;
    switch (palEntity) {
      case UserPALEntity.sedentary:
        palDBO = UserPALDBO.sedentary;
        break;
      case UserPALEntity.lowActive:
        palDBO = UserPALDBO.lowActive;
        break;
      case UserPALEntity.active:
        palDBO = UserPALDBO.active;
        break;
      case UserPALEntity.veryActive:
        palDBO = UserPALDBO.veryActive;
        break;
    }
    return palDBO;
  }
}
