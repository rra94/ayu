import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/utils/calc/optimal_range_calc.dart';

class Insight {
  final String title;
  final String message;
  final String? action;
  final int priority; // 0=red, 1=yellow, 2=green

  const Insight({
    required this.title,
    required this.message,
    this.action,
    required this.priority,
  });
}

class LongevityInsightsService {
  static List<Insight> generateInsights(
      Map<String, BiomarkerRecordOB> latestBiomarkers) {
    final insights = <Insight>[];

    for (final entry in latestBiomarkers.entries) {
      final def = OptimalRangeCalc.getDefinition(entry.key);
      if (def == null) continue;

      final value = entry.value.value;
      final rating = def.getRating(value);

      if (rating == 0) {
        // Out of normal range — red
        final msg = value < def.normalLow
            ? '${def.name} (${value.toStringAsFixed(1)} ${def.unit}) is below normal range (${def.normalLow}-${def.normalHigh}).'
            : '${def.name} (${value.toStringAsFixed(1)} ${def.unit}) is above normal range (${def.normalLow}-${def.normalHigh}).';
        insights.add(Insight(
          title: def.name,
          message: msg,
          action: _getAction(entry.key, value, def),
          priority: 0,
        ));
      } else if (rating == 1) {
        // Normal but not optimal — yellow
        final msg = value < def.optimalLow
            ? '${def.name} (${value.toStringAsFixed(1)}) is normal but below optimal (${def.optimalLow}-${def.optimalHigh} ${def.unit}).'
            : '${def.name} (${value.toStringAsFixed(1)}) is normal but above optimal (${def.optimalLow}-${def.optimalHigh} ${def.unit}).';
        insights.add(Insight(
          title: def.name,
          message: msg,
          action: _getAction(entry.key, value, def),
          priority: 1,
        ));
      } else {
        // Optimal — green (only show for key markers)
        if (['fasting_glucose', 'crp', 'ldl', 'hdl', 'vitamin_d']
            .contains(entry.key)) {
          insights.add(Insight(
            title: def.name,
            message:
                '${def.name} (${value.toStringAsFixed(1)} ${def.unit}) is in the longevity-optimal range.',
            priority: 2,
          ));
        }
      }
    }

    // Sort: red first, then yellow, then green
    insights.sort((a, b) => a.priority.compareTo(b.priority));
    return insights;
  }

  static String? _getAction(String key, double value, BiomarkerDef def) {
    switch (key) {
      case 'fasting_glucose':
        return value > def.optimalHigh
            ? 'Consider reducing refined carbs and increasing fiber.'
            : null;
      case 'vitamin_d':
        return value < def.optimalLow
            ? 'Consider 2,000-5,000 IU vitamin D3 daily with K2.'
            : null;
      case 'crp':
        return value > def.optimalHigh
            ? 'Omega-3, curcumin, and reducing processed foods may help.'
            : null;
      case 'ldl':
        return value > def.optimalHigh
            ? 'Consider increasing fiber, reducing saturated fat. Discuss ApoB with your doctor.'
            : null;
      case 'hdl':
        return value < def.optimalLow
            ? 'Exercise, olive oil, and omega-3 may increase HDL.'
            : null;
      case 'homocysteine':
        return value > def.optimalHigh
            ? 'B12, folate, and B6 supplementation may reduce homocysteine.'
            : null;
      case 'triglycerides':
        return value > def.optimalHigh
            ? 'Reduce sugar/refined carbs, increase omega-3.'
            : null;
      case 'tsh':
        return value > def.optimalHigh
            ? 'TSH slightly elevated. Selenium and iodine support thyroid function.'
            : null;
      case 'testosterone':
        return value < def.optimalLow
            ? 'Sleep, zinc, vitamin D, and resistance training support testosterone.'
            : null;
      default:
        return null;
    }
  }
}
