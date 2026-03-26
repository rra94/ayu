import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';


enum IntakeTypeDBO {
  breakfast,
  lunch,
  dinner,
  snack;

  factory IntakeTypeDBO.fromIntakeTypeEntity(IntakeTypeEntity entityType) {
    IntakeTypeDBO intakeDBOType;
    switch (entityType) {
      case IntakeTypeEntity.breakfast:
        intakeDBOType = IntakeTypeDBO.breakfast;
        break;
      case IntakeTypeEntity.lunch:
        intakeDBOType = IntakeTypeDBO.lunch;
        break;
      case IntakeTypeEntity.dinner:
        intakeDBOType = IntakeTypeDBO.dinner;
        break;
      case IntakeTypeEntity.snack:
        intakeDBOType = IntakeTypeDBO.snack;
        break;
    }
    return intakeDBOType;
  }
}
