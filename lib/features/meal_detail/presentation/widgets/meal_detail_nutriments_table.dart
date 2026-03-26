import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/common_foods_db.dart';
import 'package:opennutritracker/core/services/nutrient_synergy_service.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class MealDetailNutrimentsTable extends StatelessWidget {
  final MealEntity product;
  final bool usesImperialUnits;
  final double? servingQuantity;
  final String? servingUnit;

  const MealDetailNutrimentsTable(
      {super.key,
      required this.product,
      required this.usesImperialUnits,
      this.servingQuantity,
      this.servingUnit});

  @override
  Widget build(BuildContext context) {
    final textStyleNormal =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final textStyleBold = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle();

    final headerText = servingQuantity != null
        ? "${S.of(context).perServingLabel} (${servingQuantity!.roundToPrecision(1)}${servingUnit ?? 'g/ml'})"
        : S.of(context).per100gmlLabel;

    final n = product.nutriments;

    // Build mineral rows (only if value is not null)
    final mineralRows = <TableRow>[];
    if (n.sodium100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Sodium',
          '${_adjustValueForServing(n.sodium100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.potassium100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Potassium',
          '${_adjustValueForServing(n.potassium100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.calcium100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Calcium',
          '${_adjustValueForServing(n.calcium100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.iron100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Iron',
          '${_adjustValueForServing(n.iron100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.magnesium100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Magnesium',
          '${_adjustValueForServing(n.magnesium100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.phosphorus100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Phosphorus',
          '${_adjustValueForServing(n.phosphorus100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.zinc100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Zinc',
          '${_adjustValueForServing(n.zinc100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.copper100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Copper',
          '${_adjustValueForServing(n.copper100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.manganese100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Manganese',
          '${_adjustValueForServing(n.manganese100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.selenium100 != null) {
      mineralRows.add(_getNutrimentsTableRow(
          '   Selenium',
          '${_adjustValueForServing(n.selenium100!).roundToPrecision(2)}mcg',
          textStyleNormal));
    }

    // Build vitamin rows (only if value is not null)
    final vitaminRows = <TableRow>[];
    if (n.vitaminA100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Vitamin A',
          '${_adjustValueForServing(n.vitaminA100!).roundToPrecision(2)}mcg',
          textStyleNormal));
    }
    if (n.vitaminC100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Vitamin C',
          '${_adjustValueForServing(n.vitaminC100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.vitaminD100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Vitamin D',
          '${_adjustValueForServing(n.vitaminD100!).roundToPrecision(2)}mcg',
          textStyleNormal));
    }
    if (n.vitaminE100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Vitamin E',
          '${_adjustValueForServing(n.vitaminE100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.vitaminK100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Vitamin K',
          '${_adjustValueForServing(n.vitaminK100!).roundToPrecision(2)}mcg',
          textStyleNormal));
    }
    if (n.thiamine100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Thiamine (B1)',
          '${_adjustValueForServing(n.thiamine100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.riboflavin100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Riboflavin (B2)',
          '${_adjustValueForServing(n.riboflavin100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.niacin100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Niacin (B3)',
          '${_adjustValueForServing(n.niacin100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.pantothenicAcid100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Pantothenic Acid (B5)',
          '${_adjustValueForServing(n.pantothenicAcid100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.vitaminB6100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Vitamin B6',
          '${_adjustValueForServing(n.vitaminB6100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.folate100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Folate (B9)',
          '${_adjustValueForServing(n.folate100!).roundToPrecision(2)}mcg',
          textStyleNormal));
    }
    if (n.vitaminB12100 != null) {
      vitaminRows.add(_getNutrimentsTableRow(
          '   Vitamin B12',
          '${_adjustValueForServing(n.vitaminB12100!).roundToPrecision(2)}mcg',
          textStyleNormal));
    }

    // Build other rows
    final otherRows = <TableRow>[];
    if (n.cholesterol100 != null) {
      otherRows.add(_getNutrimentsTableRow(
          '   Cholesterol',
          '${_adjustValueForServing(n.cholesterol100!).roundToPrecision(2)}mg',
          textStyleNormal));
    }
    if (n.addedSugars100 != null) {
      otherRows.add(_getNutrimentsTableRow(
          '   Added Sugars',
          '${_adjustValueForServing(n.addedSugars100!).roundToPrecision(2)}g',
          textStyleNormal));
    }

    // Build synergy tips
    final presenceMap = NutrientSynergyService.buildPresenceMap(
      iron: n.iron100,
      calcium: n.calcium100,
      vitaminC: n.vitaminC100,
      vitaminD: n.vitaminD100,
      vitaminA: n.vitaminA100,
      vitaminE: n.vitaminE100,
      vitaminK: n.vitaminK100,
      zinc: n.zinc100,
      magnesium: n.magnesium100,
      potassium: n.potassium100,
      fiber: n.fiber100,
      fat: n.fat100,
      protein: n.proteins100,
      vitaminB12: n.vitaminB12100,
      folate: n.folate100,
      copper: n.copper100,
      phosphorus: n.phosphorus100,
      omega3: n.omega3100,
    );
    final synergyTips = NutrientSynergyService.checkSynergies(presenceMap);

    final giLabel = CommonFoodsDB.getGiLabel(product.name ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.ecoscoreGrade != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                const Icon(Icons.eco, size: 18),
                const SizedBox(width: 6),
                Text('Eco Score: ',
                    style: Theme.of(context).textTheme.bodyMedium),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _ecoGradeColor(product.ecoscoreGrade!)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.ecoscoreGrade!.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _ecoGradeColor(product.ecoscoreGrade!),
                    ),
                  ),
                ),
                if (product.ecoscoreScore != null) ...[
                  const SizedBox(width: 8),
                  Text('(${product.ecoscoreScore!.round()}/100)',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        if (giLabel != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: giLabel.contains('High')
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(
                  giLabel.contains('High')
                      ? Icons.trending_up
                      : Icons.trending_flat,
                  size: 16,
                  color: giLabel.contains('High') ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  giLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: giLabel.contains('High')
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Text(S.of(context).nutritionInfoLabel,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5)),
          children: <TableRow>[
            _getNutrimentsTableRow("", headerText, textStyleBold),
            _getNutrimentsTableRow(
                S.of(context).energyLabel,
                "${_adjustValueForServing(product.nutriments.energyKcal100?.toDouble() ?? 0).toInt()} ${S.of(context).kcalLabel}",
                textStyleNormal),
            _getNutrimentsTableRow(
                S.of(context).fatLabel,
                "${_adjustValueForServing(product.nutriments.fat100 ?? 0).roundToPrecision(2)}g",
                textStyleNormal),
            _getNutrimentsTableRow(
                '   ${S.of(context).saturatedFatLabel}',
                "${_adjustValueForServing(product.nutriments.saturatedFat100 ?? 0).roundToPrecision(2)}g",
                textStyleNormal),
            _getNutrimentsTableRow(
                S.of(context).carbohydrateLabel,
                "${_adjustValueForServing(product.nutriments.carbohydrates100 ?? 0).roundToPrecision(2)}g",
                textStyleNormal),
            _getNutrimentsTableRow(
                '    ${S.of(context).sugarLabel}',
                "${_adjustValueForServing(product.nutriments.sugars100 ?? 0).roundToPrecision(2)}g",
                textStyleNormal),
            _getNutrimentsTableRow(
                S.of(context).fiberLabel,
                "${_adjustValueForServing(product.nutriments.fiber100 ?? 0).roundToPrecision(2)}g",
                textStyleNormal),
            _getNutrimentsTableRow(
                S.of(context).proteinLabel,
                "${_adjustValueForServing(product.nutriments.proteins100 ?? 0).roundToPrecision(2)}g",
                textStyleNormal),
            // Minerals section
            if (mineralRows.isNotEmpty)
              _getNutrimentsTableRow('Minerals', '', textStyleBold),
            ...mineralRows,
            // Vitamins section
            if (vitaminRows.isNotEmpty)
              _getNutrimentsTableRow('Vitamins', '', textStyleBold),
            ...vitaminRows,
            // Other section
            if (otherRows.isNotEmpty)
              _getNutrimentsTableRow('Other', '', textStyleBold),
            ...otherRows,
          ],
        ),
        if (synergyTips.isNotEmpty) ...[
          const SizedBox(height: 24.0),
          Text('Nutrient Synergies',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8.0),
          ...synergyTips.map((tip) => _buildSynergyRow(context, tip)),
        ],
      ],
    );
  }

  Widget _buildSynergyRow(BuildContext context, SynergyTip tip) {
    final isEnhancer = tip.type == 'enhancer';
    final color = isEnhancer ? Colors.green.shade700 : Colors.orange.shade800;
    final icon = isEnhancer ? Icons.check_circle_outline : Icons.warning_amber_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18.0),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.message,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: color),
                ),
                if (tip.source != null)
                  Text(
                    tip.source!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _ecoGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF1B5E20);
      case 'b':
        return const Color(0xFF4CAF50);
      case 'c':
        return const Color(0xFFFFD600);
      case 'd':
        return const Color(0xFFFF9800);
      case 'e':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  double _adjustValueForServing(double value) {
    if (servingQuantity == null) {
      return value;
    }
    // Calculate per serving value based on 100g reference
    return (value * servingQuantity!) / 100;
  }

  TableRow _getNutrimentsTableRow(
      String label, String quantityString, TextStyle textStyle) {
    return TableRow(children: <Widget>[
      Container(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(label, style: textStyle)),
      Container(
          padding: const EdgeInsets.only(right: 8.0),
          alignment: Alignment.centerRight,
          child: Text(quantityString, style: textStyle)),
    ]);
  }
}
