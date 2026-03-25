class ReconstitutionResult {
  final double concentrationMcgPerMl;
  final double doseMcg;
  final int dosesPerVial;

  ReconstitutionResult({
    required this.concentrationMcgPerMl,
    required this.doseMcg,
    required this.dosesPerVial,
  });
}

class ReconstitutionCalc {
  static const allSites = [
    'abdomen_left', 'abdomen_right',
    'thigh_left', 'thigh_right',
    'deltoid_left', 'deltoid_right',
    'glute_left', 'glute_right',
  ];

  static const siteDisplayNames = {
    'abdomen_left': 'Abdomen (L)',
    'abdomen_right': 'Abdomen (R)',
    'thigh_left': 'Thigh (L)',
    'thigh_right': 'Thigh (R)',
    'deltoid_left': 'Deltoid (L)',
    'deltoid_right': 'Deltoid (R)',
    'glute_left': 'Glute (L)',
    'glute_right': 'Glute (R)',
  };

  /// Calculate reconstitution details.
  /// peptideMg: total mg of peptide in vial
  /// bacWaterMl: ml of bacteriostatic water added
  /// doseUnits: units drawn on a 100-unit insulin syringe
  static ReconstitutionResult calculate({
    required double peptideMg,
    required double bacWaterMl,
    required double doseUnits,
  }) {
    final concMcgPerMl = (peptideMg * 1000) / bacWaterMl;
    final doseMl = doseUnits / 100; // 100-unit syringe
    final doseMcg = concMcgPerMl * doseMl;
    final dosesPerVial = doseMl > 0 ? (bacWaterMl / doseMl).floor() : 0;

    return ReconstitutionResult(
      concentrationMcgPerMl: concMcgPerMl,
      doseMcg: doseMcg,
      dosesPerVial: dosesPerVial,
    );
  }

  /// Suggest next injection site based on round-robin rotation.
  static String suggestNextSite(List<String> recentSites) {
    if (recentSites.isEmpty) return allSites.first;
    final lastSite = recentSites.last;
    final idx = allSites.indexOf(lastSite);
    if (idx < 0) return allSites.first;
    return allSites[(idx + 1) % allSites.length];
  }
}
