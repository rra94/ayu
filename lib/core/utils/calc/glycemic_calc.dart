import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/calc/glycemic_index_data.dart';

class GlycemicResult {
  final double glycemicLoad;
  final int matchedFoods;
  final int totalFoods;
  final String classification; // Low, Medium, High

  GlycemicResult({
    required this.glycemicLoad,
    required this.matchedFoods,
    required this.totalFoods,
    required this.classification,
  });

  bool get isPartialEstimate => matchedFoods < totalFoods;
}

class GlycemicCalc {
  /// Calculate glycemic load for a single intake.
  /// GL = (GI * available carbs per serving) / 100
  static double? intakeGL(IntakeEntity intake) {
    final name = intake.meal.name;
    if (name == null) return null;

    final gi = GlycemicIndexData.lookup(name);
    if (gi == null) return null;

    final carbsPer100 = intake.meal.nutriments.carbohydrates100;
    if (carbsPer100 == null) return null;

    final totalCarbs = intake.amount * (carbsPer100 / 100);
    return (gi * totalCarbs) / 100;
  }

  /// Calculate daily glycemic load from all intakes.
  static GlycemicResult dailyGL(List<IntakeEntity> intakes) {
    double totalGL = 0;
    int matched = 0;

    for (final intake in intakes) {
      final gl = intakeGL(intake);
      if (gl != null) {
        totalGL += gl;
        matched++;
      }
    }

    return GlycemicResult(
      glycemicLoad: totalGL,
      matchedFoods: matched,
      totalFoods: intakes.length,
      classification: _classify(totalGL),
    );
  }

  /// Daily GL classification
  static String _classify(double dailyGL) {
    if (dailyGL < 80) return 'Low';
    if (dailyGL < 120) return 'Medium';
    return 'High';
  }

  /// Per-meal GL classification
  static String classifyMeal(double mealGL) {
    if (mealGL < 10) return 'Low';
    if (mealGL < 20) return 'Medium';
    return 'High';
  }

  /// Calculate net carbs: total carbs - fiber - sugar alcohols
  static double? netCarbs({
    required double? totalCarbs100,
    required double? fiber100,
    double? sugarAlcohols100,
  }) {
    if (totalCarbs100 == null) return null;
    return totalCarbs100 - (fiber100 ?? 0) - (sugarAlcohols100 ?? 0);
  }

  /// Calculate omega-6:omega-3 ratio
  static double? omegaRatio({
    required double? omega6Total,
    required double? omega3Total,
  }) {
    if (omega6Total == null || omega3Total == null || omega3Total == 0) {
      return null;
    }
    return omega6Total / omega3Total;
  }

  /// Omega ratio classification
  static String classifyOmegaRatio(double ratio) {
    if (ratio < 4) return 'Optimal';
    if (ratio < 10) return 'Moderate';
    return 'High';
  }
}
