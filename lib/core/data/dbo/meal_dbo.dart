import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

part 'meal_dbo.g.dart';


@JsonSerializable()
class MealDBO {
  final String? code;
  final String? name;

  final String? brands;

  final String? thumbnailImageUrl;
  final String? mainImageUrl;

  final String? url;

  final String? mealQuantity;
  final String? mealUnit;
  final double? servingQuantity;
  final String? servingUnit;

  final String? servingSize;

  final MealSourceDBO source;

  final MealNutrimentsDBO nutriments;

  final List<String>? additivesTags;

  final String? ingredientsText;

  final String? ecoscoreGrade;
  final double? ecoscoreScore;

  MealDBO(
      {required this.code,
      required this.name,
      required this.brands,
      required this.thumbnailImageUrl,
      required this.mainImageUrl,
      required this.url,
      required this.mealQuantity,
      required this.mealUnit,
      required this.servingQuantity,
      required this.servingUnit,
      required this.servingSize,
      required this.nutriments,
      required this.source,
      this.additivesTags,
      this.ingredientsText,
      this.ecoscoreGrade,
      this.ecoscoreScore});

  factory MealDBO.fromMealEntity(MealEntity mealEntity) => MealDBO(
      code: mealEntity.code,
      name: mealEntity.name,
      brands: mealEntity.brands,
      thumbnailImageUrl: mealEntity.thumbnailImageUrl,
      mainImageUrl: mealEntity.mainImageUrl,
      url: mealEntity.url,
      mealQuantity: mealEntity.mealQuantity,
      mealUnit: mealEntity.mealUnit,
      servingQuantity: mealEntity.servingQuantity,
      servingUnit: mealEntity.servingUnit,
      servingSize: mealEntity.servingSize,
      nutriments:
          MealNutrimentsDBO.fromProductNutrimentsEntity(mealEntity.nutriments),
      source: MealSourceDBO.fromMealSourceEntity(mealEntity.source),
      additivesTags: mealEntity.additivesTags,
      ingredientsText: mealEntity.ingredientsText,
      ecoscoreGrade: mealEntity.ecoscoreGrade,
      ecoscoreScore: mealEntity.ecoscoreScore,
  );

  factory MealDBO.fromJson(Map<String, dynamic> json) =>
      _$MealDBOFromJson(json);

  Map<String, dynamic> toJson() => _$MealDBOToJson(this);
}

enum MealSourceDBO {
  unknown,
  custom,
  off,
  fdc;

  factory MealSourceDBO.fromMealSourceEntity(MealSourceEntity entity) {
    MealSourceDBO mealSourceDBO;
    switch (entity) {
      case MealSourceEntity.unknown:
        mealSourceDBO = MealSourceDBO.unknown;
        break;
      case MealSourceEntity.custom:
        mealSourceDBO = MealSourceDBO.custom;
        break;
      case MealSourceEntity.off:
        mealSourceDBO = MealSourceDBO.off;
        break;
      case MealSourceEntity.fdc:
        mealSourceDBO = MealSourceDBO.fdc;
        break;
    }
    return mealSourceDBO;
  }
}
