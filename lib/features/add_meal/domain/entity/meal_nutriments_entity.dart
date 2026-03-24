import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_const.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_food_nutriment_dto.dart';
import 'package:opennutritracker/features/add_meal/data/dto/off/off_product_nutriments_dto.dart';

class MealNutrimentsEntity extends Equatable {
  final double? energyKcal100;

  final double? carbohydrates100;
  final double? fat100;
  final double? proteins100;
  final double? sugars100;
  final double? saturatedFat100;
  final double? fiber100;

  // Micronutrients - Minerals (per 100g, in mg unless noted)
  final double? sodium100;
  final double? potassium100;
  final double? calcium100;
  final double? iron100;
  final double? magnesium100;
  final double? phosphorus100;
  final double? zinc100;
  final double? copper100;
  final double? manganese100;
  final double? selenium100; // in mcg

  // Micronutrients - Vitamins (per 100g)
  final double? vitaminA100; // in mcg RAE
  final double? vitaminC100; // in mg
  final double? vitaminD100; // in mcg
  final double? vitaminE100; // in mg
  final double? vitaminK100; // in mcg
  final double? thiamine100; // B1, in mg
  final double? riboflavin100; // B2, in mg
  final double? niacin100; // B3, in mg
  final double? pantothenicAcid100; // B5, in mg
  final double? vitaminB6100; // in mg
  final double? folate100; // B9, in mcg
  final double? vitaminB12100; // in mcg

  // Extended lipid profile
  final double? monoFat100;
  final double? polyFat100;
  final double? transFat100;
  final double? omega3100; // ALA + EPA + DHA combined
  final double? omega6100;
  final double? sugarAlcohols100;

  // Amino acids (per 100g, in g)
  final double? leucine100;
  final double? isoleucine100;
  final double? valine100;
  final double? lysine100;
  final double? methionine100;
  final double? phenylalanine100;
  final double? threonine100;
  final double? tryptophan100;
  final double? histidine100;

  // Other
  final double? cholesterol100; // in mg
  final double? addedSugars100; // in g

  double? get energyPerUnit => _getValuePerUnit(energyKcal100);

  double? get carbohydratesPerUnit => _getValuePerUnit(carbohydrates100);

  double? get fatPerUnit => _getValuePerUnit(fat100);

  double? get proteinsPerUnit => _getValuePerUnit(proteins100);

  const MealNutrimentsEntity({
    required this.energyKcal100,
    required this.carbohydrates100,
    required this.fat100,
    required this.proteins100,
    required this.sugars100,
    required this.saturatedFat100,
    required this.fiber100,
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
    this.monoFat100,
    this.polyFat100,
    this.transFat100,
    this.omega3100,
    this.omega6100,
    this.sugarAlcohols100,
    this.leucine100,
    this.isoleucine100,
    this.valine100,
    this.lysine100,
    this.methionine100,
    this.phenylalanine100,
    this.threonine100,
    this.tryptophan100,
    this.histidine100,
    this.cholesterol100,
    this.addedSugars100,
  });

  factory MealNutrimentsEntity.empty() => const MealNutrimentsEntity(
      energyKcal100: null,
      carbohydrates100: null,
      fat100: null,
      proteins100: null,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null);

  factory MealNutrimentsEntity.fromMealNutrimentsDBO(
      MealNutrimentsDBO nutriments) {
    return MealNutrimentsEntity(
      energyKcal100: nutriments.energyKcal100,
      carbohydrates100: nutriments.carbohydrates100,
      fat100: nutriments.fat100,
      proteins100: nutriments.proteins100,
      sugars100: nutriments.sugars100,
      saturatedFat100: nutriments.saturatedFat100,
      fiber100: nutriments.fiber100,
      sodium100: nutriments.sodium100,
      potassium100: nutriments.potassium100,
      calcium100: nutriments.calcium100,
      iron100: nutriments.iron100,
      magnesium100: nutriments.magnesium100,
      phosphorus100: nutriments.phosphorus100,
      zinc100: nutriments.zinc100,
      copper100: nutriments.copper100,
      manganese100: nutriments.manganese100,
      selenium100: nutriments.selenium100,
      vitaminA100: nutriments.vitaminA100,
      vitaminC100: nutriments.vitaminC100,
      vitaminD100: nutriments.vitaminD100,
      vitaminE100: nutriments.vitaminE100,
      vitaminK100: nutriments.vitaminK100,
      thiamine100: nutriments.thiamine100,
      riboflavin100: nutriments.riboflavin100,
      niacin100: nutriments.niacin100,
      pantothenicAcid100: nutriments.pantothenicAcid100,
      vitaminB6100: nutriments.vitaminB6100,
      folate100: nutriments.folate100,
      vitaminB12100: nutriments.vitaminB12100,
      cholesterol100: nutriments.cholesterol100,
      addedSugars100: nutriments.addedSugars100,
    );
  }

  factory MealNutrimentsEntity.fromOffNutriments(
      OFFProductNutrimentsDTO offNutriments) {
    // 1. OFF product nutriments can either be String, int, double or null
    // 2. Extension function asDoubleOrNull does not work on a dynamic data
    // type, so cast to it Object?
    return MealNutrimentsEntity(
      energyKcal100:
          (offNutriments.energy_kcal_100g as Object?).asDoubleOrNull(),
      carbohydrates100:
          (offNutriments.carbohydrates_100g as Object?).asDoubleOrNull(),
      fat100: (offNutriments.fat_100g as Object?).asDoubleOrNull(),
      proteins100: (offNutriments.proteins_100g as Object?).asDoubleOrNull(),
      sugars100: (offNutriments.sugars_100g as Object?).asDoubleOrNull(),
      saturatedFat100:
          (offNutriments.saturated_fat_100g as Object?).asDoubleOrNull(),
      fiber100: (offNutriments.fiber_100g as Object?).asDoubleOrNull(),
      sodium100: (offNutriments.sodium_100g as Object?).asDoubleOrNull(),
      potassium100: (offNutriments.potassium_100g as Object?).asDoubleOrNull(),
      calcium100: (offNutriments.calcium_100g as Object?).asDoubleOrNull(),
      iron100: (offNutriments.iron_100g as Object?).asDoubleOrNull(),
      magnesium100: (offNutriments.magnesium_100g as Object?).asDoubleOrNull(),
      phosphorus100:
          (offNutriments.phosphorus_100g as Object?).asDoubleOrNull(),
      zinc100: (offNutriments.zinc_100g as Object?).asDoubleOrNull(),
      copper100: (offNutriments.copper_100g as Object?).asDoubleOrNull(),
      manganese100: (offNutriments.manganese_100g as Object?).asDoubleOrNull(),
      selenium100: (offNutriments.selenium_100g as Object?).asDoubleOrNull(),
      vitaminA100: (offNutriments.vitamin_a_100g as Object?).asDoubleOrNull(),
      vitaminC100: (offNutriments.vitamin_c_100g as Object?).asDoubleOrNull(),
      vitaminD100: (offNutriments.vitamin_d_100g as Object?).asDoubleOrNull(),
      vitaminE100: (offNutriments.vitamin_e_100g as Object?).asDoubleOrNull(),
      vitaminK100: null, // OFF does not provide vitamin K
      thiamine100: (offNutriments.vitamin_b1_100g as Object?).asDoubleOrNull(),
      riboflavin100:
          (offNutriments.vitamin_b2_100g as Object?).asDoubleOrNull(),
      niacin100: (offNutriments.vitamin_pp_100g as Object?).asDoubleOrNull(),
      pantothenicAcid100:
          (offNutriments.pantothenic_acid_100g as Object?).asDoubleOrNull(),
      vitaminB6100: (offNutriments.vitamin_b6_100g as Object?).asDoubleOrNull(),
      folate100: (offNutriments.vitamin_b9_100g as Object?).asDoubleOrNull(),
      vitaminB12100:
          (offNutriments.vitamin_b12_100g as Object?).asDoubleOrNull(),
      cholesterol100:
          (offNutriments.cholesterol_100g as Object?).asDoubleOrNull(),
      addedSugars100: null, // OFF does not provide added sugars
    );
  }

  factory MealNutrimentsEntity.fromFDCNutriments(
      List<FDCFoodNutrimentDTO> fdcNutriment) {
    // FDC Food nutriments can have different values for Energy [Energy,
    // Energy (Atwater General Factors), Energy (Atwater Specific Factors)]
    final energyTotal = fdcNutriment
            .firstWhereOrNull(
                (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalKcalId)
            ?.amount ??
        fdcNutriment
            .firstWhereOrNull((nutriment) =>
                nutriment.nutrientId == FDCConst.fdcKcalAtwaterGeneralId)
            ?.amount ??
        fdcNutriment
            .firstWhereOrNull((nutriment) =>
                nutriment.nutrientId == FDCConst.fdcKcalAtwaterSpecificId)
            ?.amount;

    final carbsTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalCarbsId)
        ?.amount;

    final fatTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalFatId)
        ?.amount;

    final proteinsTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalProteinsId)
        ?.amount;

    final sugarTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalSugarId)
        ?.amount;

    final saturatedFatTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalSaturatedFatId)
        ?.amount;

    final fiberTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalDietaryFiberId)
        ?.amount;

    // Micronutrients
    final sodiumTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcSodiumId)
        ?.amount;
    final potassiumTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcPotassiumId)
        ?.amount;
    final calciumTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcCalciumId)
        ?.amount;
    final ironTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcIronId)
        ?.amount;
    final magnesiumTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcMagnesiumId)
        ?.amount;
    final phosphorusTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcPhosphorusId)
        ?.amount;
    final zincTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcZincId)
        ?.amount;
    final copperTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcCopperId)
        ?.amount;
    final manganeseTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcManganeseId)
        ?.amount;
    final seleniumTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcSeleniumId)
        ?.amount;
    final vitaminATotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcVitaminAId)
        ?.amount;
    final vitaminCTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcVitaminCId)
        ?.amount;
    final vitaminDTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcVitaminDId)
        ?.amount;
    final vitaminETotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcVitaminEId)
        ?.amount;
    final vitaminKTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcVitaminKId)
        ?.amount;
    final thiamineTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcThiamineId)
        ?.amount;
    final riboflavinTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcRiboflavinId)
        ?.amount;
    final niacinTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcNiacinId)
        ?.amount;
    final pantothenicAcidTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcPantothenicAcidId)
        ?.amount;
    final vitaminB6Total = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcVitaminB6Id)
        ?.amount;
    final folateTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcFolateId)
        ?.amount;
    final vitaminB12Total = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcVitaminB12Id)
        ?.amount;
    final cholesterolTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcCholesterolId)
        ?.amount;
    final addedSugarsTotal = fdcNutriment
        .firstWhereOrNull(
            (n) => n.nutrientId == FDCConst.fdcAddedSugarsId)
        ?.amount;

    // Extended lipid
    double? _fdc(int id) => fdcNutriment.firstWhereOrNull((n) => n.nutrientId == id)?.amount;
    final monoFat = _fdc(FDCConst.fdcMonoFatId);
    final polyFat = _fdc(FDCConst.fdcPolyFatId);
    final transFat = _fdc(FDCConst.fdcTransFatId);
    final omega3ALA = _fdc(FDCConst.fdcOmega3ALAId);
    final omega3EPA = _fdc(FDCConst.fdcOmega3EPAId);
    final omega3DHA = _fdc(FDCConst.fdcOmega3DHAId);
    final omega3 = (omega3ALA != null || omega3EPA != null || omega3DHA != null)
        ? (omega3ALA ?? 0) + (omega3EPA ?? 0) + (omega3DHA ?? 0)
        : null;
    final omega6 = _fdc(FDCConst.fdcOmega6Id);
    final sugarAlcohols = _fdc(FDCConst.fdcSugarAlcoholsId);

    // Amino acids
    final leucine = _fdc(FDCConst.fdcLeucineId);
    final isoleucine = _fdc(FDCConst.fdcIsoleucineId);
    final valine = _fdc(FDCConst.fdcValineId);
    final lysine = _fdc(FDCConst.fdcLysineId);
    final methionine = _fdc(FDCConst.fdcMethionineId);
    final phenylalanine = _fdc(FDCConst.fdcPhenylalanineId);
    final threonine = _fdc(FDCConst.fdcThreonineId);
    final tryptophan = _fdc(FDCConst.fdcTryptophanId);
    final histidine = _fdc(FDCConst.fdcHistidineId);

    return MealNutrimentsEntity(
      energyKcal100: energyTotal,
      carbohydrates100: carbsTotal,
      fat100: fatTotal,
      proteins100: proteinsTotal,
      sugars100: sugarTotal,
      saturatedFat100: saturatedFatTotal,
      fiber100: fiberTotal,
      sodium100: sodiumTotal,
      potassium100: potassiumTotal,
      calcium100: calciumTotal,
      iron100: ironTotal,
      magnesium100: magnesiumTotal,
      phosphorus100: phosphorusTotal,
      zinc100: zincTotal,
      copper100: copperTotal,
      manganese100: manganeseTotal,
      selenium100: seleniumTotal,
      vitaminA100: vitaminATotal,
      vitaminC100: vitaminCTotal,
      vitaminD100: vitaminDTotal,
      vitaminE100: vitaminETotal,
      vitaminK100: vitaminKTotal,
      thiamine100: thiamineTotal,
      riboflavin100: riboflavinTotal,
      niacin100: niacinTotal,
      pantothenicAcid100: pantothenicAcidTotal,
      vitaminB6100: vitaminB6Total,
      folate100: folateTotal,
      vitaminB12100: vitaminB12Total,
      monoFat100: monoFat,
      polyFat100: polyFat,
      transFat100: transFat,
      omega3100: omega3,
      omega6100: omega6,
      sugarAlcohols100: sugarAlcohols,
      leucine100: leucine,
      isoleucine100: isoleucine,
      valine100: valine,
      lysine100: lysine,
      methionine100: methionine,
      phenylalanine100: phenylalanine,
      threonine100: threonine,
      tryptophan100: tryptophan,
      histidine100: histidine,
      cholesterol100: cholesterolTotal,
      addedSugars100: addedSugarsTotal,
    );
  }

  static double? _getValuePerUnit(double? valuePer100) {
    if (valuePer100 != null) {
      return valuePer100 / 100;
    } else {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        energyKcal100,
        carbohydrates100,
        fat100,
        proteins100,
        sugars100,
        saturatedFat100,
        fiber100,
        sodium100,
        potassium100,
        calcium100,
        iron100,
        magnesium100,
        phosphorus100,
        zinc100,
        copper100,
        manganese100,
        selenium100,
        vitaminA100,
        vitaminC100,
        vitaminD100,
        vitaminE100,
        vitaminK100,
        thiamine100,
        riboflavin100,
        niacin100,
        pantothenicAcid100,
        vitaminB6100,
        folate100,
        vitaminB12100,
        cholesterol100,
        addedSugars100,
      ];
}
