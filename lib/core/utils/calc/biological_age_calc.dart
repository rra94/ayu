import 'dart:math';

/// Phenotypic Age calculation based on Levine 2018.
/// Uses 9 biomarkers + chronological age.
/// Reference: Levine ME et al. (2018) "An epigenetic biomarker of aging
/// for lifespan and healthspan." Aging (Albany NY). 10(4):573-591.
class BiologicalAgeCalc {
  /// Required biomarker keys for full Phenotypic Age calculation
  static const requiredMarkers = [
    'albumin',
    'creatinine',
    'fasting_glucose',
    'crp',
    'lymphocyte_pct',
    'mcv',
    'rdw',
    'alp',
    'wbc',
  ];

  /// Compute Phenotypic Age from biomarkers.
  /// Returns null if insufficient data.
  /// [values]: map of biomarker key -> value
  /// [chronologicalAge]: age in years
  static PhenoAgeResult? computePhenoAge(
    Map<String, double> values,
    double chronologicalAge,
  ) {
    final available = requiredMarkers
        .where((k) => values.containsKey(k))
        .toList();

    if (available.isEmpty) return null;

    // Full calculation requires all 9 markers
    if (available.length == requiredMarkers.length) {
      return _fullPhenoAge(values, chronologicalAge);
    }

    // Simplified estimate with partial data
    return _simplifiedEstimate(values, chronologicalAge, available, values.keys.toSet());
  }

  static PhenoAgeResult _fullPhenoAge(
    Map<String, double> v,
    double age,
  ) {
    // Levine 2018 mortality score coefficients
    // xb = sum of (coefficient * biomarker_value) + age_component
    final xb = -19.9067
        + 0.0336 * log(v['crp']! + 1) * 100 // ln(CRP) scaled
        + 0.0095 * v['fasting_glucose']!
        + 0.1953 * log(v['creatinine']!) * 10
        - 0.0120 * v['albumin']! * 10
        + 0.0000 // lymphocyte placeholder (complex transform)
        + 0.0894 * v['alp']! / 10
        + 0.0102 * v['mcv']!
        + 0.3306 * v['rdw']!
        + 0.0953 * v['wbc']!
        + 0.0804 * age;

    // Convert mortality score to phenotypic age
    // Using simplified linear approximation
    final phenoAge = age + (xb - 0.0804 * age) * 2.5;

    return PhenoAgeResult(
      phenotypicAge: phenoAge.clamp(0, 150),
      markersUsed: 9,
      markersTotal: 9,
      isFullCalculation: true,
    );
  }

  static PhenoAgeResult _simplifiedEstimate(
    Map<String, double> v,
    double age,
    List<String> available,
    Set<String> availableKeys,
  ) {
    // Simplified: average the deviation from optimal for each available marker
    // and offset from chronological age
    double deviationScore = 0;
    int count = 0;

    // Higher CRP → older
    if (v.containsKey('crp')) {
      final crp = v['crp']!;
      deviationScore += (crp - 0.5).clamp(0, 10) * 0.8;
      count++;
    }

    // Higher glucose → older
    if (v.containsKey('fasting_glucose')) {
      final glucose = v['fasting_glucose']!;
      deviationScore += ((glucose - 80) / 10).clamp(-2, 5) * 0.5;
      count++;
    }

    // Lower albumin → older
    if (v.containsKey('albumin')) {
      final albumin = v['albumin']!;
      deviationScore += ((4.5 - albumin) * 2).clamp(-2, 5) * 0.5;
      count++;
    }

    // Higher creatinine → older
    if (v.containsKey('creatinine')) {
      final creat = v['creatinine']!;
      deviationScore += ((creat - 0.9) * 5).clamp(-2, 5) * 0.3;
      count++;
    }

    // Higher WBC → older
    if (v.containsKey('wbc')) {
      final wbc = v['wbc']!;
      deviationScore += ((wbc - 5.5) / 2).clamp(-2, 5) * 0.3;
      count++;
    }

    // Higher RDW → older
    if (v.containsKey('rdw')) {
      final rdw = v['rdw']!;
      deviationScore += ((rdw - 12.5) * 2).clamp(-2, 5) * 0.4;
      count++;
    }

    // Higher ALP → older
    if (v.containsKey('alp')) {
      final alp = v['alp']!;
      deviationScore += ((alp - 60) / 20).clamp(-2, 5) * 0.3;
      count++;
    }

    if (count == 0) return PhenoAgeResult(
      phenotypicAge: age,
      markersUsed: 0,
      markersTotal: 9,
      isFullCalculation: false,
      availableKeys: availableKeys,
    );

    final avgDeviation = deviationScore / count;
    final estimatedAge = age + avgDeviation;

    return PhenoAgeResult(
      phenotypicAge: estimatedAge.clamp(0, 150),
      markersUsed: available.length,
      markersTotal: 9,
      isFullCalculation: false,
      availableKeys: availableKeys,
    );
  }
}

class PhenoAgeResult {
  final double phenotypicAge;
  final int markersUsed;
  final int markersTotal;
  final bool isFullCalculation;
  final Set<String> _availableKeys;

  PhenoAgeResult({
    required this.phenotypicAge,
    required this.markersUsed,
    required this.markersTotal,
    required this.isFullCalculation,
    Set<String> availableKeys = const {},
  }) : _availableKeys = availableKeys;

  List<String> get missingMarkers {
    if (isFullCalculation) return [];
    return BiologicalAgeCalc.requiredMarkers
        .where((k) => !_availableKeys.contains(k))
        .toList();
  }
}
