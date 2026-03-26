class RDACalc {
  /// Returns daily recommended values based on gender, age, and body weight.
  /// Values from NIH Dietary Reference Intakes.
  /// Gender: 0=male, 1=female. Age in years.
  /// [weightKg]: body weight for protein scaling (0.8 g/kg RDA).
  ///   Falls back to reference weight (70 kg male / 57.5 kg female) if null.
  /// [totalKcalGoal]: daily calorie target for macro scaling. Defaults to 2000.
  static Map<String, double> getDailyTargets({
    required int gender,
    required int age,
    double? weightKg,
    double totalKcalGoal = 2000,
  }) {
    final isMale = gender == 0;

    // Protein: 0.8 g/kg body weight (RDA minimum), clamped to safe range.
    // Reference weights: 70 kg male, 57.5 kg female (NIH).
    final effectiveWeight = weightKg ?? (isMale ? 70.0 : 57.5);
    final proteinTarget = (effectiveWeight * 0.8).clamp(46.0, 200.0);

    return {
      'sodium': 2300, // mg
      'potassium': isMale ? 3400 : 2600, // mg
      'calcium': age >= 51 ? 1200 : 1000, // mg
      'iron': (isMale || age >= 51) ? 8 : 18, // mg
      'magnesium': isMale ? 420 : 320, // mg
      'phosphorus': 700, // mg
      'zinc': isMale ? 11 : 8, // mg
      'copper': 0.9, // mg
      'manganese': isMale ? 2.3 : 1.8, // mg
      'selenium': 55, // mcg
      'vitaminA': isMale ? 900 : 700, // mcg RAE
      'vitaminC': isMale ? 90 : 75, // mg
      'vitaminD': age >= 71 ? 20 : 15, // mcg
      'vitaminE': 15, // mg
      'vitaminK': isMale ? 120 : 90, // mcg
      'thiamine': isMale ? 1.2 : 1.1, // mg
      'riboflavin': isMale ? 1.3 : 1.1, // mg
      'niacin': isMale ? 16 : 14, // mg
      'pantothenicAcid': 5, // mg
      'vitaminB6': age >= 51 ? 1.7 : 1.3, // mg
      'folate': 400, // mcg
      'vitaminB12': 2.4, // mcg
      'cholesterol': 300, // mg (not an RDA, but daily limit)
      'addedSugars': 25, // g (WHO recommendation)
      'fiber': isMale ? 38 : 25, // g
      // Macro profiles
      'fat': (totalKcalGoal * 0.35 / 9), // g (35% of calories)
      'saturatedFat': (totalKcalGoal * 0.10 / 9), // g (limit, <10% of calories)
      'carbs': (totalKcalGoal * 0.55 / 4), // g (55% of calories)
      'protein': proteinTarget, // g (0.8 g/kg body weight)
    };
  }
}
