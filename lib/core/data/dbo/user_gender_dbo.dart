import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';


enum UserGenderDBO {
  male,
  female;

  factory UserGenderDBO.fromUserGenderEntity(UserGenderEntity genderEntity) {
    UserGenderDBO gender;
    switch (genderEntity) {
      case UserGenderEntity.male:
        gender = UserGenderDBO.male;
        break;
      case UserGenderEntity.female:
        gender = UserGenderDBO.female;
        break;
    }
    return gender;
  }
}
