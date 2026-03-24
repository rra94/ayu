/// Biomarker range definitions with normal (medical) and optimal (longevity) ranges.
/// Sources: Longevity Coach, Peter Attia, Bryan Johnson Blueprint.
class BiomarkerDef {
  final String key;
  final String name;
  final String unit;
  final String category;
  final double normalLow;
  final double normalHigh;
  final double optimalLow;
  final double optimalHigh;

  /// Recommended re-test interval in days (e.g., 90 for blood work, 30 for measurements)
  final int refreshDays;

  const BiomarkerDef({
    required this.key,
    required this.name,
    required this.unit,
    required this.category,
    required this.normalLow,
    required this.normalHigh,
    required this.optimalLow,
    required this.optimalHigh,
    this.refreshDays = 90,
  });

  /// 0=red (out of normal), 1=yellow (normal not optimal), 2=green (optimal)
  int getRating(double value) {
    if (value >= optimalLow && value <= optimalHigh) return 2;
    if (value >= normalLow && value <= normalHigh) return 1;
    return 0;
  }
}

class OptimalRangeCalc {
  static const List<BiomarkerDef> biomarkers = [
    // ── Metabolic ──
    BiomarkerDef(key: 'fasting_glucose', name: 'Fasting Glucose', unit: 'mg/dL',
        category: 'Metabolic', normalLow: 70, normalHigh: 100, optimalLow: 72, optimalHigh: 85),
    BiomarkerDef(key: 'hba1c', name: 'HbA1c', unit: '%',
        category: 'Metabolic', normalLow: 4.0, normalHigh: 5.6, optimalLow: 4.0, optimalHigh: 5.0),
    BiomarkerDef(key: 'fasting_insulin', name: 'Fasting Insulin', unit: 'uIU/mL',
        category: 'Metabolic', normalLow: 2.6, normalHigh: 24.9, optimalLow: 2.6, optimalHigh: 5.0),

    // ── Lipids ──
    BiomarkerDef(key: 'total_cholesterol', name: 'Total Cholesterol', unit: 'mg/dL',
        category: 'Lipids', normalLow: 125, normalHigh: 200, optimalLow: 140, optimalHigh: 180),
    BiomarkerDef(key: 'ldl', name: 'LDL', unit: 'mg/dL',
        category: 'Lipids', normalLow: 0, normalHigh: 130, optimalLow: 0, optimalHigh: 70),
    BiomarkerDef(key: 'hdl', name: 'HDL', unit: 'mg/dL',
        category: 'Lipids', normalLow: 40, normalHigh: 100, optimalLow: 55, optimalHigh: 100),
    BiomarkerDef(key: 'triglycerides', name: 'Triglycerides', unit: 'mg/dL',
        category: 'Lipids', normalLow: 0, normalHigh: 150, optimalLow: 0, optimalHigh: 80),
    BiomarkerDef(key: 'apob', name: 'ApoB', unit: 'mg/dL',
        category: 'Lipids', normalLow: 40, normalHigh: 130, optimalLow: 40, optimalHigh: 60),

    // ── Inflammation ──
    BiomarkerDef(key: 'crp', name: 'hs-CRP', unit: 'mg/L',
        category: 'Inflammation', normalLow: 0, normalHigh: 3.0, optimalLow: 0, optimalHigh: 0.5),
    BiomarkerDef(key: 'homocysteine', name: 'Homocysteine', unit: 'umol/L',
        category: 'Inflammation', normalLow: 5, normalHigh: 15, optimalLow: 5, optimalHigh: 8),

    // ── Liver / Kidney ──
    BiomarkerDef(key: 'alt', name: 'ALT', unit: 'U/L',
        category: 'Liver/Kidney', normalLow: 7, normalHigh: 56, optimalLow: 7, optimalHigh: 25),
    BiomarkerDef(key: 'ast', name: 'AST', unit: 'U/L',
        category: 'Liver/Kidney', normalLow: 10, normalHigh: 40, optimalLow: 10, optimalHigh: 25),
    BiomarkerDef(key: 'alp', name: 'ALP', unit: 'U/L',
        category: 'Liver/Kidney', normalLow: 44, normalHigh: 147, optimalLow: 44, optimalHigh: 80),
    BiomarkerDef(key: 'creatinine', name: 'Creatinine', unit: 'mg/dL',
        category: 'Liver/Kidney', normalLow: 0.7, normalHigh: 1.3, optimalLow: 0.7, optimalHigh: 1.0),
    BiomarkerDef(key: 'albumin', name: 'Albumin', unit: 'g/dL',
        category: 'Liver/Kidney', normalLow: 3.5, normalHigh: 5.5, optimalLow: 4.2, optimalHigh: 5.0),

    // ── Blood ──
    BiomarkerDef(key: 'wbc', name: 'WBC', unit: 'K/uL',
        category: 'Blood', normalLow: 4.5, normalHigh: 11.0, optimalLow: 4.5, optimalHigh: 7.0),
    BiomarkerDef(key: 'rbc', name: 'RBC', unit: 'M/uL',
        category: 'Blood', normalLow: 4.5, normalHigh: 5.5, optimalLow: 4.5, optimalHigh: 5.2),
    BiomarkerDef(key: 'mcv', name: 'MCV', unit: 'fL',
        category: 'Blood', normalLow: 80, normalHigh: 100, optimalLow: 85, optimalHigh: 95),
    BiomarkerDef(key: 'rdw', name: 'RDW', unit: '%',
        category: 'Blood', normalLow: 11.5, normalHigh: 14.5, optimalLow: 11.5, optimalHigh: 13.0),
    BiomarkerDef(key: 'lymphocyte_pct', name: 'Lymphocyte %', unit: '%',
        category: 'Blood', normalLow: 20, normalHigh: 40, optimalLow: 25, optimalHigh: 40),

    // ── Hormonal ──
    BiomarkerDef(key: 'testosterone', name: 'Testosterone', unit: 'ng/dL',
        category: 'Hormonal', normalLow: 300, normalHigh: 1000, optimalLow: 500, optimalHigh: 900),
    BiomarkerDef(key: 'tsh', name: 'TSH', unit: 'mIU/L',
        category: 'Hormonal', normalLow: 0.4, normalHigh: 4.0, optimalLow: 0.5, optimalHigh: 2.0),
    BiomarkerDef(key: 'vitamin_d', name: 'Vitamin D', unit: 'ng/mL',
        category: 'Hormonal', normalLow: 30, normalHigh: 100, optimalLow: 40, optimalHigh: 60),

    // ── Longevity ──
    BiomarkerDef(key: 'igf1', name: 'IGF-1', unit: 'ng/mL',
        category: 'Longevity', normalLow: 100, normalHigh: 300, optimalLow: 100, optimalHigh: 180),
    BiomarkerDef(key: 'dhea_s', name: 'DHEA-S', unit: 'ug/dL',
        category: 'Longevity', normalLow: 80, normalHigh: 560, optimalLow: 200, optimalHigh: 400),

    // ── Fitness ──
    BiomarkerDef(key: 'vo2_max', name: 'VO2 Max', unit: 'mL/kg/min',
        category: 'Fitness', normalLow: 30, normalHigh: 60, optimalLow: 40, optimalHigh: 55),
    BiomarkerDef(key: 'resting_hr', name: 'Resting Heart Rate', unit: 'bpm',
        category: 'Fitness', normalLow: 50, normalHigh: 100, optimalLow: 50, optimalHigh: 65),
    BiomarkerDef(key: 'grip_strength', name: 'Grip Strength', unit: 'kg',
        category: 'Fitness', normalLow: 20, normalHigh: 70, optimalLow: 35, optimalHigh: 60),

    // ── Body Measurements ──
    BiomarkerDef(key: 'waist', name: 'Waist Circumference', unit: 'cm',
        category: 'Body', normalLow: 60, normalHigh: 102, optimalLow: 60, optimalHigh: 88),
    BiomarkerDef(key: 'hip', name: 'Hip Circumference', unit: 'cm',
        category: 'Body', normalLow: 80, normalHigh: 120, optimalLow: 80, optimalHigh: 105),
    BiomarkerDef(key: 'waist_hip_ratio', name: 'Waist-to-Hip Ratio', unit: '',
        category: 'Body', normalLow: 0.7, normalHigh: 1.0, optimalLow: 0.7, optimalHigh: 0.85),
    BiomarkerDef(key: 'bicep', name: 'Bicep', unit: 'cm',
        category: 'Body', normalLow: 25, normalHigh: 45, optimalLow: 30, optimalHigh: 40),
    BiomarkerDef(key: 'chest', name: 'Chest', unit: 'cm',
        category: 'Body', normalLow: 85, normalHigh: 120, optimalLow: 90, optimalHigh: 110),
    BiomarkerDef(key: 'thigh', name: 'Thigh', unit: 'cm',
        category: 'Body', normalLow: 45, normalHigh: 70, optimalLow: 50, optimalHigh: 65),
    BiomarkerDef(key: 'neck', name: 'Neck', unit: 'cm',
        category: 'Body', normalLow: 30, normalHigh: 45, optimalLow: 33, optimalHigh: 40, refreshDays: 30),

    // ── Cosmetic / Wellness (1-5 self-assessment scale) ──
    BiomarkerDef(key: 'hair_health', name: 'Hair Health', unit: '/5',
        category: 'Wellness', normalLow: 1, normalHigh: 5, optimalLow: 4, optimalHigh: 5, refreshDays: 30),
    BiomarkerDef(key: 'hair_norwood', name: 'Hair Loss (Norwood Scale)', unit: 'stage',
        category: 'Wellness', normalLow: 1, normalHigh: 7, optimalLow: 1, optimalHigh: 2, refreshDays: 90),
    BiomarkerDef(key: 'skin_health', name: 'Skin Clarity', unit: '/5',
        category: 'Wellness', normalLow: 1, normalHigh: 5, optimalLow: 4, optimalHigh: 5, refreshDays: 30),
    BiomarkerDef(key: 'teeth_health', name: 'Teeth / Gum Health', unit: '/5',
        category: 'Wellness', normalLow: 1, normalHigh: 5, optimalLow: 4, optimalHigh: 5, refreshDays: 30),
    BiomarkerDef(key: 'nail_health', name: 'Nail Health', unit: '/5',
        category: 'Wellness', normalLow: 1, normalHigh: 5, optimalLow: 4, optimalHigh: 5, refreshDays: 30),
    BiomarkerDef(key: 'energy_level', name: 'Daily Energy Level', unit: '/5',
        category: 'Wellness', normalLow: 1, normalHigh: 5, optimalLow: 4, optimalHigh: 5, refreshDays: 7),
    BiomarkerDef(key: 'sleep_quality_avg', name: 'Sleep Quality (avg)', unit: '/5',
        category: 'Wellness', normalLow: 1, normalHigh: 5, optimalLow: 4, optimalHigh: 5, refreshDays: 7),
    BiomarkerDef(key: 'stress_level', name: 'Stress Level', unit: '/10',
        category: 'Wellness', normalLow: 1, normalHigh: 10, optimalLow: 1, optimalHigh: 3, refreshDays: 7),
  ];

  static BiomarkerDef? getDefinition(String key) {
    try {
      return biomarkers.firstWhere((b) => b.key == key);
    } catch (_) {
      return null;
    }
  }

  static Map<String, List<BiomarkerDef>> getByCategory() {
    final map = <String, List<BiomarkerDef>>{};
    for (final b in biomarkers) {
      map.putIfAbsent(b.category, () => []).add(b);
    }
    return map;
  }
}
