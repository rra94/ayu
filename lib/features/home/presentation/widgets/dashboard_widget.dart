import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/features/home/presentation/widgets/macro_nutriments_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:opennutritracker/generated/l10n.dart';

class DashboardWidget extends StatefulWidget {
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;

  const DashboardWidget(
      {super.key,
      required this.totalKcalSupplied,
      required this.totalKcalBurned,
      required this.totalKcalDaily,
      required this.totalKcalLeft,
      required this.totalCarbsIntake,
      required this.totalFatsIntake,
      required this.totalProteinsIntake,
      required this.totalCarbsGoal,
      required this.totalFatsGoal,
      required this.totalProteinsGoal});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  void _showNutritionBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Nutrition',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildMacroRow(ctx, 'Calories', widget.totalKcalSupplied,
                  widget.totalKcalDaily, 'kcal'),
              _buildMacroRow(ctx, 'Protein', widget.totalProteinsIntake,
                  widget.totalProteinsGoal, 'g'),
              _buildMacroRow(ctx, 'Carbs', widget.totalCarbsIntake,
                  widget.totalCarbsGoal, 'g'),
              _buildMacroRow(ctx, 'Fat', widget.totalFatsIntake,
                  widget.totalFatsGoal, 'g'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroRow(BuildContext ctx, String label, double current,
      double goal, String unit) {
    final pct = goal > 0 ? (current / goal * 100).clamp(0, 200) : 0.0;
    final theme = Theme.of(ctx);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                '${current.round()} / ${goal.round()} $unit',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (pct / 100).clamp(0, 1),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: pct > 100 ? Colors.red : theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double kcalLeftLabel = 0;
    double gaugeValue = 0;
    if (widget.totalKcalLeft > widget.totalKcalDaily) {
      kcalLeftLabel = widget.totalKcalDaily;
      gaugeValue = 0;
    } else if (widget.totalKcalLeft < 0) {
      kcalLeftLabel = 0;
      gaugeValue = 1;
    } else {
      kcalLeftLabel = widget.totalKcalLeft;
      gaugeValue = (widget.totalKcalDaily - widget.totalKcalLeft) /
          widget.totalKcalDaily;
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up_outlined,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      Text('${widget.totalKcalSupplied.toInt()}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                      Text(S.of(context).suppliedLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                    ],
                  )),
                  Semantics(
                    label: 'Calorie ring. ${kcalLeftLabel.toInt()} calories remaining. Tap for nutrition breakdown.',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showNutritionBreakdown(context);
                      },
                      child: CircularPercentIndicator(
                      radius: 70.0,
                      lineWidth: 13.0,
                      animation: true,
                      percent: gaugeValue,
                      arcType: ArcType.FULL,
                      progressColor: gaugeValue >= 1.0
                          ? Colors.red
                          : Theme.of(context).brightness == Brightness.light
                              ? ayuGoldMuted
                              : ayuGoldLight,
                      arcBackgroundColor:
                          (Theme.of(context).brightness == Brightness.light
                                  ? ayuGoldMuted
                                  : ayuGoldLight)
                              .withAlpha(50),
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedFlipCounter(
                              duration: const Duration(milliseconds: 1000),
                              value: kcalLeftLabel.toInt(),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      letterSpacing: -1)),
                          Text(
                            S.of(context).kcalLeftLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                          )
                        ],
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    ),
                  ),
                  Flexible(child: Column(
                    children: [
                      Icon(Icons.keyboard_arrow_down_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      Text('${widget.totalKcalBurned.toInt()}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                      Text(S.of(context).burnedLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                    ],
                  )),
                ],
              ),
              MacroNutrientsView(
                  totalCarbsIntake: widget.totalCarbsIntake,
                  totalFatsIntake: widget.totalFatsIntake,
                  totalProteinsIntake: widget.totalProteinsIntake,
                  totalCarbsGoal: widget.totalCarbsGoal,
                  totalFatsGoal: widget.totalFatsGoal,
                  totalProteinsGoal: widget.totalProteinsGoal),
            ],
          ),
        ),
      ),
    );
  }
}
