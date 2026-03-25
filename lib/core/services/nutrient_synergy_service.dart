class SynergyTip {
  final String type; // 'enhancer' or 'inhibitor'
  final String nutrientA;
  final String nutrientB;
  final String message;
  final String? source;

  SynergyTip({
    required this.type,
    required this.nutrientA,
    required this.nutrientB,
    required this.message,
    this.source,
  });
}

class NutrientSynergyService {
  /// Given a meal's nutrient profile, return relevant synergy tips.
  /// nutrientPresence: map of nutrient name -> true if present in meal
  static List<SynergyTip> checkSynergies(Map<String, bool> nutrientPresence) {
    final tips = <SynergyTip>[];

    for (final rule in _rules) {
      final aPresent = nutrientPresence[rule.nutrientA] ?? false;
      final bPresent = nutrientPresence[rule.nutrientB] ?? false;
      if (aPresent && bPresent) {
        tips.add(rule);
      }
    }

    return tips;
  }

  /// Build nutrient presence map from meal nutriments.
  /// Check if values are non-null and > 0.
  static Map<String, bool> buildPresenceMap({
    double? iron,
    double? calcium,
    double? vitaminC,
    double? vitaminD,
    double? vitaminA,
    double? vitaminE,
    double? vitaminK,
    double? zinc,
    double? magnesium,
    double? potassium,
    double? fiber,
    double? fat,
    double? protein,
    double? vitaminB12,
    double? folate,
    double? copper,
    double? phosphorus,
    double? omega3,
  }) {
    return {
      'iron': (iron ?? 0) > 0,
      'calcium': (calcium ?? 0) > 0,
      'vitaminC': (vitaminC ?? 0) > 0,
      'vitaminD': (vitaminD ?? 0) > 0,
      'vitaminA': (vitaminA ?? 0) > 0,
      'vitaminE': (vitaminE ?? 0) > 0,
      'vitaminK': (vitaminK ?? 0) > 0,
      'zinc': (zinc ?? 0) > 0,
      'magnesium': (magnesium ?? 0) > 0,
      'potassium': (potassium ?? 0) > 0,
      'fiber': (fiber ?? 0) > 0,
      'fat': (fat ?? 0) > 0,
      'protein': (protein ?? 0) > 0,
      'vitaminB12': (vitaminB12 ?? 0) > 0,
      'folate': (folate ?? 0) > 0,
      'copper': (copper ?? 0) > 0,
      'phosphorus': (phosphorus ?? 0) > 0,
      'omega3': (omega3 ?? 0) > 0,
    };
  }

  static final _rules = <SynergyTip>[
    // Enhancers
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'iron',
        nutrientB: 'vitaminC',
        message: 'Vitamin C boosts iron absorption 2-6x',
        source: 'Hallberg 1989'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'vitaminD',
        nutrientB: 'calcium',
        message: 'Vitamin D enhances calcium absorption',
        source: 'Christakos 2011'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'vitaminA',
        nutrientB: 'fat',
        message: 'Fat-soluble vitamin A needs dietary fat for absorption'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'vitaminD',
        nutrientB: 'fat',
        message: 'Fat-soluble vitamin D needs dietary fat for absorption'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'vitaminE',
        nutrientB: 'fat',
        message: 'Fat-soluble vitamin E needs dietary fat for absorption'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'vitaminK',
        nutrientB: 'fat',
        message: 'Fat-soluble vitamin K needs dietary fat for absorption'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'vitaminD',
        nutrientB: 'magnesium',
        message: 'Magnesium activates vitamin D enzymes',
        source: 'Uwitonze 2018'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'vitaminB12',
        nutrientB: 'folate',
        message: 'B12 and folate work together in DNA synthesis'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'iron',
        nutrientB: 'protein',
        message:
            'Protein (especially from meat) enhances non-heme iron absorption'),
    SynergyTip(
        type: 'enhancer',
        nutrientA: 'zinc',
        nutrientB: 'protein',
        message: 'Protein enhances zinc bioavailability'),

    // Inhibitors
    SynergyTip(
        type: 'inhibitor',
        nutrientA: 'calcium',
        nutrientB: 'iron',
        message: 'Calcium inhibits iron absorption — take separately',
        source: 'Hallberg 1991'),
    SynergyTip(
        type: 'inhibitor',
        nutrientA: 'zinc',
        nutrientB: 'copper',
        message: 'High zinc inhibits copper absorption',
        source: 'Fischer 1984'),
    SynergyTip(
        type: 'inhibitor',
        nutrientA: 'calcium',
        nutrientB: 'zinc',
        message: 'High calcium can reduce zinc absorption'),
    SynergyTip(
        type: 'inhibitor',
        nutrientA: 'iron',
        nutrientB: 'zinc',
        message: 'Iron and zinc compete for absorption — take separately'),
    SynergyTip(
        type: 'inhibitor',
        nutrientA: 'fiber',
        nutrientB: 'iron',
        message: 'Fiber (phytates) can reduce iron absorption by 50-65%',
        source: 'Hurrell 2003'),
    SynergyTip(
        type: 'inhibitor',
        nutrientA: 'fiber',
        nutrientB: 'zinc',
        message: 'Fiber (phytates) can reduce zinc absorption'),
    SynergyTip(
        type: 'inhibitor',
        nutrientA: 'calcium',
        nutrientB: 'phosphorus',
        message: 'Excess phosphorus impairs calcium absorption'),
  ];
}
