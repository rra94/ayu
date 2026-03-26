import 'package:opennutritracker/core/db/entities/symptom_log_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';

class FoodFeelingCorrelation {
  final String foodName;
  final String symptomName;
  final int occurrences;
  final double ratio; // how many times more likely vs baseline

  FoodFeelingCorrelation({
    required this.foodName,
    required this.symptomName,
    required this.occurrences,
    required this.ratio,
  });
}

class FoodFeelingService {
  /// Look back 2-6 hours from each symptom log and count which foods
  /// precede the symptom. Compare to baseline frequency.
  /// Requires 10+ symptom logs for meaningful results.
  static List<FoodFeelingCorrelation> computeCorrelations(
    List<SymptomLogOB> symptoms,
    List<IntakeEntity> allIntakes,
  ) {
    if (symptoms.length < 10 || allIntakes.isEmpty) return [];

    // Count total days with any intake (baseline denominator)
    final intakeDays = <String>{};
    for (final intake in allIntakes) {
      intakeDays.add(_dayKey(intake.dateTime));
    }
    final totalDays = intakeDays.length;
    if (totalDays == 0) return [];

    // Count how often each food appears in any day (baseline)
    final foodDayCount = <String, int>{};
    for (final intake in allIntakes) {
      final name = intake.meal.name ?? 'Unknown';
      final key = '${name}_${_dayKey(intake.dateTime)}';
      if (!foodDayCount.containsKey(name)) foodDayCount[name] = 0;
      // Dedupe per day
      foodDayCount[name] = foodDayCount[name]! + 1;
    }

    // For each symptom, find foods consumed 2-6 hours before
    final symptomFoodHits = <int, Map<String, int>>{}; // symptom -> food -> count

    for (final symptom in symptoms) {
      final windowStart =
          symptom.dateTime.subtract(const Duration(hours: 6));
      final windowEnd =
          symptom.dateTime.subtract(const Duration(hours: 2));

      final precedingFoods = allIntakes
          .where((i) =>
              i.dateTime.isAfter(windowStart) &&
              i.dateTime.isBefore(windowEnd))
          .map((i) => i.meal.name ?? 'Unknown')
          .toSet();

      for (final food in precedingFoods) {
        symptomFoodHits
            .putIfAbsent(symptom.symptom, () => {})
            .update(food, (v) => v + 1, ifAbsent: () => 1);
      }
    }

    // Build correlations
    final results = <FoodFeelingCorrelation>[];

    for (final entry in symptomFoodHits.entries) {
      final symptomIdx = entry.key;
      final symptomName = symptomIdx < SymptomLogOB.symptomNames.length
          ? SymptomLogOB.symptomNames[symptomIdx]
          : 'Unknown';

      // How many times this symptom was logged
      final symptomCount =
          symptoms.where((s) => s.symptom == symptomIdx).length;

      for (final foodEntry in entry.value.entries) {
        final food = foodEntry.key;
        final hitCount = foodEntry.value;

        if (hitCount < 2) continue; // need at least 2 co-occurrences

        // Baseline rate: how often this food appears per day
        final baselineRate = (foodDayCount[food] ?? 0) / totalDays;
        // Symptom rate: how often this food precedes this symptom
        final symptomRate = hitCount / symptomCount;

        if (baselineRate > 0 && symptomRate > baselineRate) {
          final ratio = symptomRate / baselineRate;
          if (ratio >= 1.5) {
            results.add(FoodFeelingCorrelation(
              foodName: food,
              symptomName: symptomName,
              occurrences: hitCount,
              ratio: ratio,
            ));
          }
        }
      }
    }

    // Sort by ratio descending
    results.sort((a, b) => b.ratio.compareTo(a.ratio));
    return results.take(10).toList();
  }

  static String _dayKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
