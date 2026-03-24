import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/intake_dbo.dart';
import 'package:opennutritracker/core/data/dbo/intake_type_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/core/db/entities/intake_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class IntakeDataSourceOB {
  final log = Logger('IntakeDataSourceOB');
  final Box<IntakeOB> _intakeBox;

  IntakeDataSourceOB(this._intakeBox);

  Future<void> addIntake(IntakeDBO intakeDBO) async {
    log.fine('Adding new intake item to db');
    _intakeBox.put(_intakeDBOToOB(intakeDBO));
  }

  Future<void> addAllIntakes(List<IntakeDBO> intakeDBOList) async {
    log.fine('Adding new intake items to db');
    _intakeBox.putMany(intakeDBOList.map(_intakeDBOToOB).toList());
  }

  Future<void> deleteIntakeFromId(String intakeId) async {
    log.fine('Deleting intake item from db');
    final query = _intakeBox.query(IntakeOB_.intakeId.equals(intakeId)).build();
    final results = query.find();
    query.close();
    for (final ob in results) {
      _intakeBox.remove(ob.id);
    }
  }

  Future<IntakeDBO?> updateIntake(
      String intakeId, Map<String, dynamic> fields) async {
    log.fine(
        'Updating intake $intakeId with fields ${fields.toString()} in db');
    final query = _intakeBox.query(IntakeOB_.intakeId.equals(intakeId)).build();
    final ob = query.findFirst();
    query.close();
    if (ob == null) {
      log.fine('Cannot update intake $intakeId as it is non existent');
      return null;
    }
    ob.amount = fields['amount'] ?? ob.amount;
    _intakeBox.put(ob);
    return _intakeOBToDBO(ob);
  }

  Future<IntakeDBO?> getIntakeById(String intakeId) async {
    final query = _intakeBox.query(IntakeOB_.intakeId.equals(intakeId)).build();
    final ob = query.findFirst();
    query.close();
    return ob != null ? _intakeOBToDBO(ob) : null;
  }

  Future<List<IntakeDBO>> getAllIntakes() async {
    return _intakeBox.getAll().map(_intakeOBToDBO).toList();
  }

  Future<List<IntakeDBO>> getAllIntakesByDate(
      IntakeTypeDBO intakeType, DateTime dateTime) async {
    final startOfDay =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    final query = _intakeBox
        .query(IntakeOB_.dateTime.betweenDate(startOfDay, endOfDay).and(
            IntakeOB_.intakeType.equals(intakeType.index)))
        .build();
    final results = query.find();
    query.close();
    return results.map(_intakeOBToDBO).toList();
  }

  Future<List<IntakeDBO>> getRecentlyAddedIntake({int number = 100}) async {
    final allOB = _intakeBox.getAll();
    final intakeList = allOB.map(_intakeOBToDBO).toList();

    //  sort list by date (newest first) and filter unique intake
    intakeList.sort((a, b) => (-1) * a.dateTime.compareTo(b.dateTime));

    final filterCodes = <String>{};
    final uniqueIntake = intakeList
        .where((intake) =>
            filterCodes.add(intake.meal.code ?? intake.meal.name ?? ""))
        .toList();

    return uniqueIntake.take(number).toList();
  }

  Future<List<IntakeDBO>> getFavorites() async {
    final query = _intakeBox
        .query(IntakeOB_.isFavorite.equals(true))
        .order(IntakeOB_.dateTime, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();

    // Deduplicate by meal code/name
    final seen = <String>{};
    final unique = results.where((ob) {
      final key = ob.code ?? ob.name ?? ob.id.toString();
      return seen.add(key);
    }).toList();

    return unique.take(20).map(_intakeOBToDBO).toList();
  }

  Future<void> toggleFavorite(String intakeId, bool value) async {
    final query = _intakeBox.query(IntakeOB_.intakeId.equals(intakeId)).build();
    final ob = query.findFirst();
    query.close();
    if (ob != null) {
      ob.isFavorite = value;
      _intakeBox.put(ob);
    }
  }
}

// ---------------------------------------------------------------------------
// DBO <-> OB converters
// ---------------------------------------------------------------------------

IntakeOB _intakeDBOToOB(IntakeDBO dbo) {
  return IntakeOB(
    intakeId: dbo.id,
    unit: dbo.unit,
    amount: dbo.amount,
    intakeType: dbo.type.index,
    dateTime: dbo.dateTime,
    code: dbo.meal.code,
    name: dbo.meal.name,
    brands: dbo.meal.brands,
    thumbnailImageUrl: dbo.meal.thumbnailImageUrl,
    mainImageUrl: dbo.meal.mainImageUrl,
    url: dbo.meal.url,
    mealQuantity: dbo.meal.mealQuantity,
    mealUnit: dbo.meal.mealUnit,
    servingQuantity: dbo.meal.servingQuantity,
    servingUnit: dbo.meal.servingUnit,
    servingSize: dbo.meal.servingSize,
    mealSource: dbo.meal.source.index,
    energyKcal100: dbo.meal.nutriments.energyKcal100,
    carbohydrates100: dbo.meal.nutriments.carbohydrates100,
    fat100: dbo.meal.nutriments.fat100,
    proteins100: dbo.meal.nutriments.proteins100,
    sugars100: dbo.meal.nutriments.sugars100,
    saturatedFat100: dbo.meal.nutriments.saturatedFat100,
    fiber100: dbo.meal.nutriments.fiber100,
    sodium100: dbo.meal.nutriments.sodium100,
    potassium100: dbo.meal.nutriments.potassium100,
    calcium100: dbo.meal.nutriments.calcium100,
    iron100: dbo.meal.nutriments.iron100,
    magnesium100: dbo.meal.nutriments.magnesium100,
    phosphorus100: dbo.meal.nutriments.phosphorus100,
    zinc100: dbo.meal.nutriments.zinc100,
    copper100: dbo.meal.nutriments.copper100,
    manganese100: dbo.meal.nutriments.manganese100,
    selenium100: dbo.meal.nutriments.selenium100,
    vitaminA100: dbo.meal.nutriments.vitaminA100,
    vitaminC100: dbo.meal.nutriments.vitaminC100,
    vitaminD100: dbo.meal.nutriments.vitaminD100,
    vitaminE100: dbo.meal.nutriments.vitaminE100,
    vitaminK100: dbo.meal.nutriments.vitaminK100,
    thiamine100: dbo.meal.nutriments.thiamine100,
    riboflavin100: dbo.meal.nutriments.riboflavin100,
    niacin100: dbo.meal.nutriments.niacin100,
    pantothenicAcid100: dbo.meal.nutriments.pantothenicAcid100,
    vitaminB6100: dbo.meal.nutriments.vitaminB6100,
    folate100: dbo.meal.nutriments.folate100,
    vitaminB12100: dbo.meal.nutriments.vitaminB12100,
    cholesterol100: dbo.meal.nutriments.cholesterol100,
    addedSugars100: dbo.meal.nutriments.addedSugars100,
    additivesTags: dbo.meal.additivesTags,
    ingredientsText: dbo.meal.ingredientsText,
  );
}

IntakeDBO _intakeOBToDBO(IntakeOB ob) {
  return IntakeDBO(
    id: ob.intakeId,
    unit: ob.unit,
    amount: ob.amount,
    type: IntakeTypeDBO.values[ob.intakeType],
    dateTime: ob.dateTime,
    meal: MealDBO(
      code: ob.code,
      name: ob.name,
      brands: ob.brands,
      thumbnailImageUrl: ob.thumbnailImageUrl,
      mainImageUrl: ob.mainImageUrl,
      url: ob.url,
      mealQuantity: ob.mealQuantity,
      mealUnit: ob.mealUnit,
      servingQuantity: ob.servingQuantity,
      servingUnit: ob.servingUnit,
      servingSize: ob.servingSize,
      source: MealSourceDBO.values[ob.mealSource],
      additivesTags: ob.additivesTags,
      ingredientsText: ob.ingredientsText,
      nutriments: MealNutrimentsDBO(
        energyKcal100: ob.energyKcal100,
        carbohydrates100: ob.carbohydrates100,
        fat100: ob.fat100,
        proteins100: ob.proteins100,
        sugars100: ob.sugars100,
        saturatedFat100: ob.saturatedFat100,
        fiber100: ob.fiber100,
        sodium100: ob.sodium100,
        potassium100: ob.potassium100,
        calcium100: ob.calcium100,
        iron100: ob.iron100,
        magnesium100: ob.magnesium100,
        phosphorus100: ob.phosphorus100,
        zinc100: ob.zinc100,
        copper100: ob.copper100,
        manganese100: ob.manganese100,
        selenium100: ob.selenium100,
        vitaminA100: ob.vitaminA100,
        vitaminC100: ob.vitaminC100,
        vitaminD100: ob.vitaminD100,
        vitaminE100: ob.vitaminE100,
        vitaminK100: ob.vitaminK100,
        thiamine100: ob.thiamine100,
        riboflavin100: ob.riboflavin100,
        niacin100: ob.niacin100,
        pantothenicAcid100: ob.pantothenicAcid100,
        vitaminB6100: ob.vitaminB6100,
        folate100: ob.folate100,
        vitaminB12100: ob.vitaminB12100,
        cholesterol100: ob.cholesterol100,
        addedSugars100: ob.addedSugars100,
      ),
    ),
  );
}
