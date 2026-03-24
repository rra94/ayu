import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/services/bioavailability_service.dart';
import 'package:opennutritracker/core/utils/calc/rda_calc.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MicronutrientSummaryScreen extends StatelessWidget {
  final List<IntakeEntity> allIntakes;
  final int gender; // 0=male, 1=female
  final int age;

  const MicronutrientSummaryScreen({
    super.key,
    required this.allIntakes,
    required this.gender,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    final rdaTargets = RDACalc.getDailyTargets(gender: gender, age: age);
    final totals = _computeDailyTotals(allIntakes);

    // Compute absorption data
    final absorptionResults = BioavailabilityService.computeAll(allIntakes);
    final absorptionMap = <String, BioavailabilityResult>{};
    for (final a in absorptionResults) {
      absorptionMap[a.nutrient] = a;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Micronutrient Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Minerals'),
          _buildNutrientRow(context, 'Sodium', totals['sodium'], rdaTargets['sodium'], 'mg', isLimit: true),
          _buildNutrientRow(context, 'Potassium', totals['potassium'], rdaTargets['potassium'], 'mg', absorption: absorptionMap['Potassium']),
          _buildNutrientRow(context, 'Calcium', totals['calcium'], rdaTargets['calcium'], 'mg', absorption: absorptionMap['Calcium']),
          _buildNutrientRow(context, 'Iron', totals['iron'], rdaTargets['iron'], 'mg', absorption: absorptionMap['Iron']),
          _buildNutrientRow(context, 'Magnesium', totals['magnesium'], rdaTargets['magnesium'], 'mg', absorption: absorptionMap['Magnesium']),
          _buildNutrientRow(context, 'Phosphorus', totals['phosphorus'], rdaTargets['phosphorus'], 'mg'),
          _buildNutrientRow(context, 'Zinc', totals['zinc'], rdaTargets['zinc'], 'mg', absorption: absorptionMap['Zinc']),
          _buildNutrientRow(context, 'Copper', totals['copper'], rdaTargets['copper'], 'mg'),
          _buildNutrientRow(context, 'Manganese', totals['manganese'], rdaTargets['manganese'], 'mg'),
          _buildNutrientRow(context, 'Selenium', totals['selenium'], rdaTargets['selenium'], 'mcg'),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Vitamins'),
          _buildNutrientRow(context, 'Vitamin A', totals['vitaminA'], rdaTargets['vitaminA'], 'mcg', absorption: absorptionMap['Vitamin A']),
          _buildNutrientRow(context, 'Vitamin C', totals['vitaminC'], rdaTargets['vitaminC'], 'mg', absorption: absorptionMap['Vitamin C']),
          _buildNutrientRow(context, 'Vitamin D', totals['vitaminD'], rdaTargets['vitaminD'], 'mcg', absorption: absorptionMap['Vitamin D']),
          _buildNutrientRow(context, 'Vitamin E', totals['vitaminE'], rdaTargets['vitaminE'], 'mg'),
          _buildNutrientRow(context, 'Vitamin K', totals['vitaminK'], rdaTargets['vitaminK'], 'mcg'),
          _buildNutrientRow(context, 'Thiamine (B1)', totals['thiamine'], rdaTargets['thiamine'], 'mg'),
          _buildNutrientRow(context, 'Riboflavin (B2)', totals['riboflavin'], rdaTargets['riboflavin'], 'mg'),
          _buildNutrientRow(context, 'Niacin (B3)', totals['niacin'], rdaTargets['niacin'], 'mg'),
          _buildNutrientRow(context, 'Pantothenic Acid (B5)', totals['pantothenicAcid'], rdaTargets['pantothenicAcid'], 'mg'),
          _buildNutrientRow(context, 'Vitamin B6', totals['vitaminB6'], rdaTargets['vitaminB6'], 'mg'),
          _buildNutrientRow(context, 'Folate (B9)', totals['folate'], rdaTargets['folate'], 'mcg', absorption: absorptionMap['Folate']),
          _buildNutrientRow(context, 'Vitamin B12', totals['vitaminB12'], rdaTargets['vitaminB12'], 'mcg', absorption: absorptionMap['Vitamin B12']),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Lipid Profile'),
          _buildNutrientRow(context, 'Total Fat', totals['fat'], rdaTargets['fat'], 'g'),
          _buildNutrientRow(context, '  Saturated', totals['saturatedFat'], rdaTargets['saturatedFat'], 'g', isLimit: true),
          _buildNutrientRow(context, '  Monounsaturated', totals['monoFat'], null, 'g'),
          _buildNutrientRow(context, '  Polyunsaturated', totals['polyFat'], null, 'g'),
          _buildNutrientRow(context, '  Trans Fat', totals['transFat'], null, 'g', isLimit: true),
          _buildNutrientRow(context, '  Omega-3', totals['omega3'], null, 'g'),
          _buildNutrientRow(context, 'Cholesterol', totals['cholesterol'], rdaTargets['cholesterol'], 'mg', isLimit: true),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Carbohydrate Profile'),
          _buildNutrientRow(context, 'Total Carbs', totals['carbs'], rdaTargets['carbs'], 'g'),
          _buildNutrientRow(context, '  Fiber', totals['fiber'], rdaTargets['fiber'], 'g'),
          _buildNutrientRow(context, '  Sugars', totals['sugars'], null, 'g'),
          _buildNutrientRow(context, '  Added Sugars', totals['addedSugars'], rdaTargets['addedSugars'], 'g', isLimit: true),
          _buildNutrientRow(context, '  Sugar Alcohols', totals['sugarAlcohols'], null, 'g'),
          _buildNutrientRow(context, '  Net Carbs', totals['netCarbs'], null, 'g'),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Protein Profile'),
          _buildNutrientRow(context, 'Total Protein', totals['protein'], rdaTargets['protein'], 'g'),
          _buildSectionHeader(context, '  Essential Amino Acids'),
          _buildNutrientRow(context, '  Leucine', null, null, 'g'),
          _buildNutrientRow(context, '  Isoleucine', null, null, 'g'),
          _buildNutrientRow(context, '  Valine', null, null, 'g'),
          _buildNutrientRow(context, '  Lysine', null, null, 'g'),
          _buildNutrientRow(context, '  Methionine', null, null, 'g'),
          _buildNutrientRow(context, '  Phenylalanine', null, null, 'g'),
          _buildNutrientRow(context, '  Threonine', null, null, 'g'),
          _buildNutrientRow(context, '  Tryptophan', null, null, 'g'),
          _buildNutrientRow(context, '  Histidine', null, null, 'g'),
          const SizedBox(height: 24),
          _buildDataCoverageNote(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildNutrientRow(
    BuildContext context,
    String name,
    double? current,
    double? target,
    String unit, {
    bool isLimit = false,
    BioavailabilityResult? absorption,
  }) {
    final theme = Theme.of(context);
    final hasData = current != null && current > 0;
    final rdaPercent = (hasData && target != null && target > 0)
        ? (current / target).clamp(0.0, 2.0)
        : 0.0;
    final displayPercent = (rdaPercent * 100).round();

    Color barColor;
    if (!hasData) {
      barColor = Colors.grey.shade300;
    } else if (isLimit) {
      barColor = rdaPercent <= 1.0 ? Colors.green : Colors.red;
    } else {
      if (rdaPercent >= 0.9) {
        barColor = Colors.green;
      } else if (rdaPercent >= 0.5) {
        barColor = Colors.orange;
      } else {
        barColor = Colors.red.shade300;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, style: theme.textTheme.bodyMedium),
              ),
              Text(
                hasData
                    ? '${current.toStringAsFixed(current < 1 ? 2 : 1)} / ${target?.toStringAsFixed(target < 1 ? 2 : 0) ?? '—'} $unit ($displayPercent%)'
                    : '— / ${target?.toStringAsFixed(target < 1 ? 2 : 0) ?? '—'} $unit',
                style: theme.textTheme.bodySmall?.copyWith(
                      color: hasData ? null : Colors.grey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8,
            percent: rdaPercent.clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            progressColor: barColor,
            barRadius: const Radius.circular(4),
          ),
          if (absorption != null && hasData) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.arrow_downward, size: 10,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Absorbed: ~${absorption.absorbedMg.toStringAsFixed(1)}$unit (${absorption.absorptionPct.round()}%)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: absorption.absorptionPct >= 50
                        ? Colors.green
                        : absorption.absorptionPct >= 25
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                if (absorption.tip != null) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      absorption.tip!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataCoverageNote(BuildContext context) {
    int mealsWithMicros = 0;
    for (final intake in allIntakes) {
      if (intake.meal.nutriments.sodium100 != null ||
          intake.meal.nutriments.vitaminC100 != null ||
          intake.meal.nutriments.calcium100 != null) {
        mealsWithMicros++;
      }
    }
    final totalMeals = allIntakes.length;
    final coverage = totalMeals > 0
        ? ((mealsWithMicros / totalMeals) * 100).round()
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Based on $mealsWithMicros of $totalMeals logged meals with micronutrient data ($coverage% coverage)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double?> _computeDailyTotals(List<IntakeEntity> intakes) {
    double? sum(double? Function(IntakeEntity) getter) {
      double total = 0;
      bool hasAny = false;
      for (final intake in intakes) {
        final val = getter(intake);
        if (val != null) {
          total += intake.amount * (val / 100);
          hasAny = true;
        }
      }
      return hasAny ? total : null;
    }

    final result = <String, double?>{
      'sodium': sum((i) => i.meal.nutriments.sodium100),
      'potassium': sum((i) => i.meal.nutriments.potassium100),
      'calcium': sum((i) => i.meal.nutriments.calcium100),
      'iron': sum((i) => i.meal.nutriments.iron100),
      'magnesium': sum((i) => i.meal.nutriments.magnesium100),
      'phosphorus': sum((i) => i.meal.nutriments.phosphorus100),
      'zinc': sum((i) => i.meal.nutriments.zinc100),
      'copper': sum((i) => i.meal.nutriments.copper100),
      'manganese': sum((i) => i.meal.nutriments.manganese100),
      'selenium': sum((i) => i.meal.nutriments.selenium100),
      'vitaminA': sum((i) => i.meal.nutriments.vitaminA100),
      'vitaminC': sum((i) => i.meal.nutriments.vitaminC100),
      'vitaminD': sum((i) => i.meal.nutriments.vitaminD100),
      'vitaminE': sum((i) => i.meal.nutriments.vitaminE100),
      'vitaminK': sum((i) => i.meal.nutriments.vitaminK100),
      'thiamine': sum((i) => i.meal.nutriments.thiamine100),
      'riboflavin': sum((i) => i.meal.nutriments.riboflavin100),
      'niacin': sum((i) => i.meal.nutriments.niacin100),
      'pantothenicAcid': sum((i) => i.meal.nutriments.pantothenicAcid100),
      'vitaminB6': sum((i) => i.meal.nutriments.vitaminB6100),
      'folate': sum((i) => i.meal.nutriments.folate100),
      'vitaminB12': sum((i) => i.meal.nutriments.vitaminB12100),
      'cholesterol': sum((i) => i.meal.nutriments.cholesterol100),
      'addedSugars': sum((i) => i.meal.nutriments.addedSugars100),
      'fiber': sum((i) => i.meal.nutriments.fiber100),
      // Macro sub-profiles
      'fat': sum((i) => i.meal.nutriments.fat100),
      'saturatedFat': sum((i) => i.meal.nutriments.saturatedFat100),
      'transFat': null,
      'monoFat': null, // Not in standard OFF/FDC nutriments
      'polyFat': null,
      'omega3': null,
      'carbs': sum((i) => i.meal.nutriments.carbohydrates100),
      'sugars': sum((i) => i.meal.nutriments.sugars100),
      'protein': sum((i) => i.meal.nutriments.proteins100),
      'sugarAlcohols': null, // Not available from OFF/FDC directly
    };

    // Compute net carbs
    final carbsVal = result['carbs'];
    final fiberVal = result['fiber'];
    result['netCarbs'] = carbsVal != null
        ? carbsVal - (fiberVal ?? 0)
        : null;

    return result;
  }
}
