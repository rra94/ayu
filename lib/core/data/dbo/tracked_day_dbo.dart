import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';

part 'tracked_day_dbo.g.dart';


@JsonSerializable()
class TrackedDayDBO {
  DateTime day;
  double calorieGoal;
  double caloriesTracked;
  double? carbsGoal;
  double? carbsTracked;
  double? fatGoal;
  double? fatTracked;
  double? proteinGoal;
  double? proteinTracked;

  TrackedDayDBO(
      {required this.day,
      required this.calorieGoal,
      required this.caloriesTracked,
      this.carbsGoal,
      this.carbsTracked,
      this.fatGoal,
      this.fatTracked,
      this.proteinGoal,
      this.proteinTracked});

  factory TrackedDayDBO.fromTrackedDayEntity(TrackedDayEntity entity) {
    return TrackedDayDBO(
        day: entity.day,
        calorieGoal: entity.calorieGoal,
        caloriesTracked: entity.caloriesTracked,
        carbsGoal: entity.carbsGoal,
        carbsTracked: entity.carbsTracked,
        fatGoal: entity.fatGoal,
        fatTracked: entity.fatTracked,
        proteinGoal: entity.proteinGoal,
        proteinTracked: entity.proteinTracked);
  }

  factory TrackedDayDBO.fromJson(Map<String, dynamic> json) =>
      _$TrackedDayDBOFromJson(json);

  Map<String, dynamic> toJson() => _$TrackedDayDBOToJson(this);
}
