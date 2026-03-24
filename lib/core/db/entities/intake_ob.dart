import 'package:objectbox/objectbox.dart';

@Entity()
class IntakeOB {
  @Id()
  int id = 0;

  @Unique()
  String intakeId;

  String unit;
  double amount;

  /// 0=breakfast, 1=lunch, 2=dinner, 3=snack
  int intakeType;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  // ---------------------------------------------------------------------------
  // Meal fields (flattened from MealDBO)
  // ---------------------------------------------------------------------------
  String? code;
  String? name;
  String? brands;
  String? thumbnailImageUrl;
  String? mainImageUrl;
  String? url;
  String? mealQuantity;
  String? mealUnit;
  double? servingQuantity;
  String? servingUnit;
  String? servingSize;

  /// 0=unknown, 1=custom, 2=off, 3=fdc
  int mealSource;

  // ---------------------------------------------------------------------------
  // Nutriments fields (flattened from MealNutrimentsDBO)
  // ---------------------------------------------------------------------------
  double? energyKcal100;
  double? carbohydrates100;
  double? fat100;
  double? proteins100;
  double? sugars100;
  double? saturatedFat100;
  double? fiber100;

  // Micronutrients - Minerals
  double? sodium100;
  double? potassium100;
  double? calcium100;
  double? iron100;
  double? magnesium100;
  double? phosphorus100;
  double? zinc100;
  double? copper100;
  double? manganese100;
  double? selenium100;

  // Micronutrients - Vitamins
  double? vitaminA100;
  double? vitaminC100;
  double? vitaminD100;
  double? vitaminE100;
  double? vitaminK100;
  double? thiamine100;
  double? riboflavin100;
  double? niacin100;
  double? pantothenicAcid100;
  double? vitaminB6100;
  double? folate100;
  double? vitaminB12100;

  // Other
  double? cholesterol100;
  double? addedSugars100;

  // Gut health fields
  List<String>? additivesTags;
  String? ingredientsText;

  // Favorites
  bool isFavorite;

  IntakeOB({
    this.id = 0,
    required this.intakeId,
    required this.unit,
    required this.amount,
    required this.intakeType,
    required this.dateTime,
    this.code,
    this.name,
    this.brands,
    this.thumbnailImageUrl,
    this.mainImageUrl,
    this.url,
    this.mealQuantity,
    this.mealUnit,
    this.servingQuantity,
    this.servingUnit,
    this.servingSize,
    this.mealSource = 0,
    this.energyKcal100,
    this.carbohydrates100,
    this.fat100,
    this.proteins100,
    this.sugars100,
    this.saturatedFat100,
    this.fiber100,
    this.sodium100,
    this.potassium100,
    this.calcium100,
    this.iron100,
    this.magnesium100,
    this.phosphorus100,
    this.zinc100,
    this.copper100,
    this.manganese100,
    this.selenium100,
    this.vitaminA100,
    this.vitaminC100,
    this.vitaminD100,
    this.vitaminE100,
    this.vitaminK100,
    this.thiamine100,
    this.riboflavin100,
    this.niacin100,
    this.pantothenicAcid100,
    this.vitaminB6100,
    this.folate100,
    this.vitaminB12100,
    this.cholesterol100,
    this.addedSugars100,
    this.additivesTags,
    this.ingredientsText,
    this.isFavorite = false,
  });
}
