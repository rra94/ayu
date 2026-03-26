import 'package:flutter/material.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/calc/bmr_calc.dart';
import 'package:opennutritracker/core/utils/calc/pal_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class TdeeCard extends StatefulWidget {
  const TdeeCard({super.key});

  @override
  State<TdeeCard> createState() => _TdeeCardState();
}

class _TdeeCardState extends State<TdeeCard> {
  bool _loading = true;
  double _bmr = 0;
  double _activityFactor = 0;
  double _tef = 0;
  double _tdee = 0;
  bool _showTef = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = await locator<GetUserUsecase>().getUserData();
      final bmr = BMRCalc.getBMRMifflinStJeor1990(user);
      final pal = PalCalc.getPALValueFromActivityCategory(user);
      final activityKcal = bmr * (pal - 1);

      // Calculate TEF from today's macros
      final tef = await _calculateTEF(user);

      final tdee = bmr + activityKcal + tef;

      if (!mounted) return;
      setState(() {
        _bmr = bmr;
        _activityFactor = activityKcal;
        _tef = tef;
        _tdee = tdee;
        _showTef = tef > 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; });
    }
  }

  /// TEF per macro (Westerterp 2004, Halton & Hu 2004):
  /// Protein: 20-30% → use 25%
  /// Carbs: 5-10% → use 7.5%
  /// Fat: 0-3% → use 1.5%
  Future<double> _calculateTEF(UserEntity user) async {
    final getIntake = locator<GetIntakeUsecase>();
    final today = DateTime.now();
    final breakfastList = await getIntake.getBreakfastIntakeByDay(today);
    final lunchList = await getIntake.getLunchIntakeByDay(today);
    final dinnerList = await getIntake.getDinnerIntakeByDay(today);
    final snackList = await getIntake.getSnackIntakeByDay(today);

    final allIntakes = [
      ...breakfastList,
      ...lunchList,
      ...dinnerList,
      ...snackList,
    ];

    if (allIntakes.isEmpty) return 0;

    double proteinKcal = 0;
    double carbKcal = 0;
    double fatKcal = 0;

    for (final intake in allIntakes) {
      proteinKcal += intake.totalProteinsGram * 4; // 4 kcal/g
      carbKcal += intake.totalCarbsGram * 4;
      fatKcal += intake.totalFatsGram * 9; // 9 kcal/g
    }

    return (proteinKcal * 0.25) + (carbKcal * 0.075) + (fatKcal * 0.015);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(S.of(context).energyExpenditureLabel,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // TDEE headline
              Text(
                '${_tdee.round()} kcal/day',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Breakdown bars
              _buildBreakdownRow(
                theme,
                S.of(context).bmrMifflinLabel,
                _bmr,
                _tdee,
                theme.colorScheme.primary,
              ),
              _buildBreakdownRow(
                theme,
                S.of(context).activityBreakdownLabel,
                _activityFactor,
                _tdee,
                theme.colorScheme.chartOrange,
              ),
              if (_showTef)
                _buildBreakdownRow(
                  theme,
                  S.of(context).tefLabel,
                  _tef,
                  _tdee,
                  theme.colorScheme.chartDeepPurple,
                ),
              if (!_showTef)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    S.of(context).tefHintLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    ThemeData theme,
    String label,
    double value,
    double total,
    Color color,
  ) {
    final pct = total > 0 ? (value / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const Spacer(),
              Text(
                '${value.round()} kcal (${(pct * 100).round()}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
