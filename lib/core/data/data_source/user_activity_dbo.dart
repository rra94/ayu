import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';

part 'user_activity_dbo.g.dart';


@JsonSerializable()
class UserActivityDBO {
  final String id;
  final double duration;
  final double burnedKcal;
  final DateTime date;

  final PhysicalActivityDBO physicalActivityDBO;

  UserActivityDBO(this.id, this.duration, this.burnedKcal, this.date,
      this.physicalActivityDBO);

  factory UserActivityDBO.fromUserActivityEntity(
      UserActivityEntity userActivityEntity) {
    return UserActivityDBO(
        userActivityEntity.id,
        userActivityEntity.duration,
        userActivityEntity.burnedKcal,
        userActivityEntity.date,
        PhysicalActivityDBO.fromPhysicalActivityEntity(
            userActivityEntity.physicalActivityEntity));
  }

  factory UserActivityDBO.fromJson(Map<String, dynamic> json) =>
      _$UserActivityDBOFromJson(json);

  Map<String, dynamic> toJson() => _$UserActivityDBOToJson(this);
}
