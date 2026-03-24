/// Suggests specific foods to fill micronutrient gaps.
/// Food data sourced from USDA FDC + bioavailability research.
class FoodSuggestion {
  final String food;
  final String amount;
  final double nutrientMg;
  final double bioavailableMg;
  final String? note;

  const FoodSuggestion({
    required this.food,
    required this.amount,
    required this.nutrientMg,
    required this.bioavailableMg,
    this.note,
  });
}

class NutrientGap {
  final String nutrient;
  final String unit;
  final double consumed;
  final double rda;
  final double pctRda;
  final List<FoodSuggestion> suggestions;
  final String? absorptionTip;

  NutrientGap({
    required this.nutrient,
    required this.consumed,
    required this.rda,
    required this.suggestions,
    this.unit = 'mg',
    this.absorptionTip,
  }) : pctRda = rda > 0 ? (consumed / rda * 100) : 100;

  double get gap => (rda - consumed).clamp(0, double.infinity);
}

class NutrientRecommendationService {
  /// Returns nutrients below 80% RDA with food suggestions.
  /// [gender]: 0=male, 1=female. [age]: years.
  static List<NutrientGap> getRecommendations({
    required Map<String, double> dailyTotals,
    required int gender,
    required int age,
  }) {
    final gaps = <NutrientGap>[];

    for (final entry in _nutrientData.entries) {
      final key = entry.key;
      final data = entry.value;
      final consumed = dailyTotals[key] ?? 0;
      final rda = gender == 1 ? data.rdaFemale : data.rdaMale;

      final pct = rda > 0 ? consumed / rda * 100 : 100;
      if (pct < 80) {
        gaps.add(NutrientGap(
          nutrient: data.name,
          unit: data.unit,
          consumed: consumed,
          rda: rda,
          suggestions: data.foods,
          absorptionTip: data.absorptionTip,
        ));
      }
    }

    // Sort by lowest %RDA first
    gaps.sort((a, b) => a.pctRda.compareTo(b.pctRda));
    return gaps;
  }

  static const Map<String, _NutrientInfo> _nutrientData = {
    'iron': _NutrientInfo(
      name: 'Iron',
      unit: 'mg',
      rdaMale: 8,
      rdaFemale: 18,
      absorptionTip:
          'Pair with vitamin C (bell pepper, orange) to boost absorption 2-6x. Avoid tea/coffee within 1h of iron-rich meals.',
      foods: [
        FoodSuggestion(food: 'Beef liver', amount: '3 oz', nutrientMg: 6.5, bioavailableMg: 1.6),
        FoodSuggestion(food: 'Lentils + lemon', amount: '1 cup', nutrientMg: 3.3, bioavailableMg: 0.66, note: 'Add vitamin C to triple absorption'),
        FoodSuggestion(food: 'Spinach', amount: '1 cup cooked', nutrientMg: 3.6, bioavailableMg: 0.18, note: 'Only 5% absorbed — use for other nutrients, not iron'),
        FoodSuggestion(food: 'Dark chocolate 70%+', amount: '1 oz', nutrientMg: 3.4, bioavailableMg: 0.34),
        FoodSuggestion(food: 'Pumpkin seeds', amount: '1 oz', nutrientMg: 2.5, bioavailableMg: 0.25),
      ],
    ),
    'calcium': _NutrientInfo(
      name: 'Calcium',
      unit: 'mg',
      rdaMale: 1000,
      rdaFemale: 1000,
      absorptionTip:
          'Vitamin D boosts calcium absorption ~30%. Kale is 49% bioavailable vs spinach at 5%.',
      foods: [
        FoodSuggestion(food: 'Yogurt', amount: '1 cup', nutrientMg: 300, bioavailableMg: 90),
        FoodSuggestion(food: 'Sardines (with bones)', amount: '3 oz', nutrientMg: 325, bioavailableMg: 97),
        FoodSuggestion(food: 'Kale', amount: '1 cup cooked', nutrientMg: 94, bioavailableMg: 46, note: '49% bioavailable — better than spinach'),
        FoodSuggestion(food: 'Fortified orange juice', amount: '1 cup', nutrientMg: 350, bioavailableMg: 105),
        FoodSuggestion(food: 'Cheese (cheddar)', amount: '1 oz', nutrientMg: 200, bioavailableMg: 60),
      ],
    ),
    'vitaminD': _NutrientInfo(
      name: 'Vitamin D',
      unit: 'mcg',
      rdaMale: 15,
      rdaFemale: 15,
      absorptionTip:
          'Fat-soluble — take with a fatty meal. 10-15 min midday sun produces ~250mcg.',
      foods: [
        FoodSuggestion(food: 'Salmon', amount: '3 oz', nutrientMg: 14.2, bioavailableMg: 11.4),
        FoodSuggestion(food: 'Sardines', amount: '3 oz', nutrientMg: 4.1, bioavailableMg: 3.3),
        FoodSuggestion(food: 'Egg yolk', amount: '1 large', nutrientMg: 1.1, bioavailableMg: 0.88),
        FoodSuggestion(food: 'Fortified milk', amount: '1 cup', nutrientMg: 3.0, bioavailableMg: 2.4),
        FoodSuggestion(food: 'D3 supplement', amount: '2000 IU', nutrientMg: 50, bioavailableMg: 40, note: 'Take with fat for best absorption'),
      ],
    ),
    'magnesium': _NutrientInfo(
      name: 'Magnesium',
      unit: 'mg',
      rdaMale: 420,
      rdaFemale: 320,
      absorptionTip:
          'Glycinate and citrate forms absorb better than oxide. Vitamin D helps.',
      foods: [
        FoodSuggestion(food: 'Pumpkin seeds', amount: '1 oz', nutrientMg: 156, bioavailableMg: 62),
        FoodSuggestion(food: 'Almonds', amount: '1 oz', nutrientMg: 80, bioavailableMg: 32),
        FoodSuggestion(food: 'Spinach', amount: '1 cup cooked', nutrientMg: 78, bioavailableMg: 31),
        FoodSuggestion(food: 'Dark chocolate 70%+', amount: '1 oz', nutrientMg: 65, bioavailableMg: 26),
        FoodSuggestion(food: 'Black beans', amount: '1 cup', nutrientMg: 60, bioavailableMg: 24),
      ],
    ),
    'zinc': _NutrientInfo(
      name: 'Zinc',
      unit: 'mg',
      rdaMale: 11,
      rdaFemale: 8,
      absorptionTip:
          'Animal sources are 2x more bioavailable. Soaking beans/grains reduces phytates.',
      foods: [
        FoodSuggestion(food: 'Oysters', amount: '3 oz', nutrientMg: 74, bioavailableMg: 26, note: 'Highest zinc food source'),
        FoodSuggestion(food: 'Beef', amount: '3 oz', nutrientMg: 5.0, bioavailableMg: 1.75),
        FoodSuggestion(food: 'Pumpkin seeds', amount: '1 oz', nutrientMg: 2.2, bioavailableMg: 0.55),
        FoodSuggestion(food: 'Chickpeas', amount: '1 cup', nutrientMg: 1.3, bioavailableMg: 0.26),
      ],
    ),
    'vitaminC': _NutrientInfo(
      name: 'Vitamin C',
      unit: 'mg',
      rdaMale: 90,
      rdaFemale: 75,
      absorptionTip:
          '85% absorbed at <200mg. Split large doses for better uptake. Cooking destroys ~50%.',
      foods: [
        FoodSuggestion(food: 'Bell pepper (red)', amount: '1 medium', nutrientMg: 152, bioavailableMg: 129),
        FoodSuggestion(food: 'Orange', amount: '1 medium', nutrientMg: 70, bioavailableMg: 60),
        FoodSuggestion(food: 'Kiwi', amount: '1 medium', nutrientMg: 64, bioavailableMg: 54),
        FoodSuggestion(food: 'Broccoli (raw)', amount: '1 cup', nutrientMg: 81, bioavailableMg: 69),
        FoodSuggestion(food: 'Strawberries', amount: '1 cup', nutrientMg: 89, bioavailableMg: 76),
      ],
    ),
    'vitaminB12': _NutrientInfo(
      name: 'Vitamin B12',
      unit: 'mcg',
      rdaMale: 2.4,
      rdaFemale: 2.4,
      absorptionTip:
          '~50% absorbed from food. Absorption requires intrinsic factor. Antacids reduce it.',
      foods: [
        FoodSuggestion(food: 'Clams', amount: '3 oz', nutrientMg: 84, bioavailableMg: 42),
        FoodSuggestion(food: 'Salmon', amount: '3 oz', nutrientMg: 4.8, bioavailableMg: 2.4),
        FoodSuggestion(food: 'Nutritional yeast', amount: '1 tbsp', nutrientMg: 2.4, bioavailableMg: 1.2),
        FoodSuggestion(food: 'Eggs', amount: '2 large', nutrientMg: 1.1, bioavailableMg: 0.55),
      ],
    ),
    'folate': _NutrientInfo(
      name: 'Folate',
      unit: 'mcg',
      rdaMale: 400,
      rdaFemale: 400,
      absorptionTip:
          'Food folate is ~50% bioavailable. Vitamin C improves absorption. Alcohol impairs it.',
      foods: [
        FoodSuggestion(food: 'Beef liver', amount: '3 oz', nutrientMg: 215, bioavailableMg: 107),
        FoodSuggestion(food: 'Lentils', amount: '1 cup', nutrientMg: 179, bioavailableMg: 90),
        FoodSuggestion(food: 'Spinach', amount: '1 cup cooked', nutrientMg: 131, bioavailableMg: 65),
        FoodSuggestion(food: 'Asparagus', amount: '1 cup', nutrientMg: 89, bioavailableMg: 45),
        FoodSuggestion(food: 'Avocado', amount: '1/2', nutrientMg: 59, bioavailableMg: 30),
      ],
    ),
    'potassium': _NutrientInfo(
      name: 'Potassium',
      unit: 'mg',
      rdaMale: 3400,
      rdaFemale: 2600,
      absorptionTip: 'Potassium is ~85% absorbed. Most people get only 50% of RDA.',
      foods: [
        FoodSuggestion(food: 'Sweet potato', amount: '1 medium', nutrientMg: 541, bioavailableMg: 460),
        FoodSuggestion(food: 'Banana', amount: '1 medium', nutrientMg: 422, bioavailableMg: 359),
        FoodSuggestion(food: 'Lentils', amount: '1 cup', nutrientMg: 370, bioavailableMg: 315),
        FoodSuggestion(food: 'Salmon', amount: '3 oz', nutrientMg: 326, bioavailableMg: 277),
        FoodSuggestion(food: 'Yogurt', amount: '1 cup', nutrientMg: 380, bioavailableMg: 323),
      ],
    ),
  };
}

class _NutrientInfo {
  final String name;
  final String unit;
  final double rdaMale;
  final double rdaFemale;
  final String absorptionTip;
  final List<FoodSuggestion> foods;

  const _NutrientInfo({
    required this.name,
    required this.unit,
    required this.rdaMale,
    required this.rdaFemale,
    required this.absorptionTip,
    required this.foods,
  });
}
