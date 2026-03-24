import 'package:flutter/material.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        )
      ],
    );
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
