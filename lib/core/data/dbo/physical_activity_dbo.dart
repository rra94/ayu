import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';

part 'physical_activity_dbo.g.dart';


/// A physical activity with it's measured MET value by the
/// '2011 Compendium of Physical Activities'
/// https://pubmed.ncbi.nlm.nih.gov/21681120/
/// by Ainsworth et al.
@JsonSerializable()
class PhysicalActivityDBO {
  final String code;
  final String specificActivity;
  final String description;
  final double mets;

  final List<String> tags;

  final PhysicalActivityTypeDBO type;

  PhysicalActivityDBO(this.code, this.specificActivity, this.description,
      this.mets, this.tags, this.type);

  factory PhysicalActivityDBO.fromPhysicalActivityEntity(
      PhysicalActivityEntity entity) {
    return PhysicalActivityDBO(
        entity.code,
        entity.specificActivity,
        entity.description,
        entity.mets,
        entity.tags,
        PhysicalActivityTypeDBO.fromPhysicalActivityTypeEntity(entity.type));
  }

  factory PhysicalActivityDBO.fromJson(Map<String, dynamic> json) =>
      _$PhysicalActivityDBOFromJson(json);

  Map<String, dynamic> toJson() => _$PhysicalActivityDBOToJson(this);
}

enum PhysicalActivityTypeDBO {
  bicycling,
  conditioningExercise,
  dancing,
  running,
  sport,
  waterActivities,
  winterActivities;

  factory PhysicalActivityTypeDBO.fromPhysicalActivityTypeEntity(
      PhysicalActivityTypeEntity entityType) {
    PhysicalActivityTypeDBO typeDBO;
    switch (entityType) {
      case PhysicalActivityTypeEntity.bicycling:
        typeDBO = PhysicalActivityTypeDBO.bicycling;
        break;
      case PhysicalActivityTypeEntity.conditioningExercise:
        typeDBO = PhysicalActivityTypeDBO.conditioningExercise;
        break;
      case PhysicalActivityTypeEntity.dancing:
        typeDBO = PhysicalActivityTypeDBO.dancing;
        break;
      case PhysicalActivityTypeEntity.running:
        typeDBO = PhysicalActivityTypeDBO.running;
        break;
      case PhysicalActivityTypeEntity.sport:
        typeDBO = PhysicalActivityTypeDBO.sport;
        break;
      case PhysicalActivityTypeEntity.waterActivities:
        typeDBO = PhysicalActivityTypeDBO.waterActivities;
        break;
      case PhysicalActivityTypeEntity.winterActivities:
        typeDBO = PhysicalActivityTypeDBO.winterActivities;
        break;
    }
    return typeDBO;
  }
}
