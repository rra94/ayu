import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class MealEntityFixtures {
  static final mealOne = MealEntity(
      code: "1",
      name: null,
      url: null,
      mealQuantity: null,
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: 'g',
      servingSize: '2 Tbsp (32 g)',
      nutriments: MealNutrimentsEntity.empty(),
      source: MealSourceEntity.custom);
  static final mealTwo = MealEntity(
      code: "2",
      name: null,
      url: null,
      mealQuantity: null,
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: 'g',
      servingSize: '2 Tbsp (32 g)',
      nutriments: MealNutrimentsEntity.empty(),
      source: MealSourceEntity.custom);
  static final mealThree = MealEntity(
      code: "3",
      name: null,
      url: null,
      mealQuantity: null,
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: 'g',
      servingSize: '2 Tbsp (32 g)',
      nutriments: MealNutrimentsEntity.empty(),
      source: MealSourceEntity.custom);

  /// Create an IntakeEntity with specific nutrient values for testing
  static IntakeEntity createIntakeWithNutrients({
    double? iron100,
    double? calcium100,
    double? vitaminC100,
    double? vitaminD100,
    double? zinc100,
    double? magnesium100,
    double? fiber100,
    double? fat100,
    double? energyKcal100,
    double amount = 1.0,
  }) {
    return IntakeEntity(
      id: 'test-${DateTime.now().microsecondsSinceEpoch}',
      unit: 'g',
      amount: amount,
      type: IntakeTypeEntity.lunch,
      dateTime: DateTime.now(),
      meal: MealEntity(
        code: 'test',
        name: 'Test Food',
        url: null,
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: null,
        servingUnit: null,
        servingSize: null,
        source: MealSourceEntity.custom,
        nutriments: MealNutrimentsEntity(
          energyKcal100: energyKcal100 ?? 200,
          carbohydrates100: 20,
          fat100: fat100 ?? 10,
          proteins100: 15,
          sugars100: 5,
          saturatedFat100: 3,
          fiber100: fiber100 ?? 2,
          iron100: iron100,
          calcium100: calcium100,
          vitaminC100: vitaminC100,
          vitaminD100: vitaminD100,
          zinc100: zinc100,
          magnesium100: magnesium100,
        ),
      ),
    );
  }

  /// Create intakes spread across multiple days for streak testing
  static List<IntakeEntity> createMultiDayIntakes({
    required int days,
    required double kcalPerMeal,
    int startDaysAgo = -1,
  }) {
    final intakes = <IntakeEntity>[];
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final dayOffset = startDaysAgo == -1 ? days - 1 - i : startDaysAgo - i;
      final date = now.subtract(Duration(days: dayOffset));
      intakes.add(IntakeEntity(
        id: 'day-$i',
        unit: 'serving',
        amount: 1.0,
        type: IntakeTypeEntity.lunch,
        dateTime: date,
        meal: MealEntity(
          code: 'meal-$i',
          name: 'Meal Day $i',
          url: null,
          mealQuantity: '100',
          mealUnit: 'g',
          servingQuantity: null,
          servingUnit: null,
          servingSize: null,
          source: MealSourceEntity.custom,
          nutriments: MealNutrimentsEntity(
            energyKcal100: kcalPerMeal,
            carbohydrates100: 30,
            fat100: 10,
            proteins100: 20,
            sugars100: 5,
            saturatedFat100: 3,
            fiber100: 5,
          ),
        ),
      ));
    }
    return intakes;
  }
}