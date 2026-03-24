import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/services/bioavailability_service.dart';
import 'package:opennutritracker/core/services/nutrient_recommendation_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class NutrientIntelligenceCard extends StatefulWidget {
  const NutrientIntelligenceCard({super.key});

  @override
  State<NutrientIntelligenceCard> createState() =>
      _NutrientIntelligenceCardState();
}

class _NutrientIntelligenceCardState extends State<NutrientIntelligenceCard> {
  bool _loading = true;
  List<NutrientGap> _gaps = [];
  List<BioavailabilityResult> _absorption = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final getIntake = locator<GetIntakeUsecase>();
    final user = await locator<GetUserUsecase>().getUserData();
    final today = DateTime.now();
    final allIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(today),
      ...await getIntake.getLunchIntakeByDay(today),
      ...await getIntake.getDinnerIntakeByDay(today),
      ...await getIntake.getSnackIntakeByDay(today),
    ];

    // Compute absorption
    final absorption = BioavailabilityService.computeAll(allIntakes);

    // Compute daily totals for recommendations
    final totals = <String, double>{};
    for (final intake in allIntakes) {
      final n = intake.meal.nutriments;
      final a = intake.amount;
      void add(String key, double? per100) {
        if (per100 != null) totals[key] = (totals[key] ?? 0) + a * per100 / 100;
      }

      add('iron', n.iron100);
      add('calcium', n.calcium100);
      add('vitaminD', n.vitaminD100);
      add('magnesium', n.magnesium100);
      add('zinc', n.zinc100);
      add('vitaminC', n.vitaminC100);
      add('vitaminB12', n.vitaminB12100);
      add('folate', n.folate100);
      add('potassium', n.potassium100);
    }

    final gaps = NutrientRecommendationService.getRecommendations(
      dailyTotals: totals,
      gender: user.gender.index,
      age: user.age,
    );

    setState(() {
      _gaps = gaps;
      _absorption = absorption;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Nutrient Intelligence',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_gaps.isEmpty && _absorption.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Log meals to see nutrient gaps and absorption estimates.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else ...[
              // Absorption panel
              if (_absorption.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Estimated Absorption',
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ..._absorption.map((a) => _buildAbsorptionRow(theme, a)),
              ],

              // Nutrient gaps + recommendations
              if (_gaps.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Top Up These Nutrients',
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange)),
                const SizedBox(height: 4),
                ..._gaps.take(3).map((g) => _buildGapSection(theme, g)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAbsorptionRow(ThemeData theme, BioavailabilityResult a) {
    final color = a.absorptionPct >= 50
        ? Colors.green
        : a.absorptionPct >= 25
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(a.nutrient,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500, fontSize: 11)),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (a.absorptionPct / 100).clamp(0, 1),
                    backgroundColor: color.withValues(alpha: 0.1),
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${a.absorptionPct.round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 74),
            child: Text(
              '${a.absorbedMg.toStringAsFixed(1)} of ${a.consumedMg.toStringAsFixed(1)} absorbed',
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          if (a.tip != null)
            Padding(
              padding: const EdgeInsets.only(left: 74, top: 2),
              child: Text(
                a.tip!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                  fontSize: 10,
                ),
              ),
            ),
          if (a.enhancers.isNotEmpty || a.inhibitors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 74, top: 1),
              child: Wrap(
                spacing: 4,
                children: [
                  ...a.enhancers.map((e) => Text('+$e',
                      style: TextStyle(
                          fontSize: 9, color: Colors.green[700]))),
                  ...a.inhibitors.map((i) => Text('-$i',
                      style: TextStyle(
                          fontSize: 9, color: Colors.red[400]))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGapSection(ThemeData theme, NutrientGap gap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${gap.nutrient}: ${gap.consumed.toStringAsFixed(0)}/${gap.rda.toStringAsFixed(0)}${gap.unit} (${gap.pctRda.round()}%)',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ...gap.suggestions.take(3).map((s) => Padding(
                padding: const EdgeInsets.only(left: 20, top: 1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${s.food} (${s.amount})',
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${s.bioavailableMg.toStringAsFixed(1)} absorbed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              )),
          if (gap.absorptionTip != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 2),
              child: Text(
                gap.absorptionTip!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
