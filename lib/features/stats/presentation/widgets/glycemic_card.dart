import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/utils/calc/glycemic_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class GlycemicCard extends StatefulWidget {
  const GlycemicCard({super.key});

  @override
  State<GlycemicCard> createState() => _GlycemicCardState();
}

class _GlycemicCardState extends State<GlycemicCard> {
  bool _loading = true;
  GlycemicResult? _result;
  double? _netCarbs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final getIntake = locator<GetIntakeUsecase>();
    final today = DateTime.now();
    final all = [
      ...await getIntake.getBreakfastIntakeByDay(today),
      ...await getIntake.getLunchIntakeByDay(today),
      ...await getIntake.getDinnerIntakeByDay(today),
      ...await getIntake.getSnackIntakeByDay(today),
    ];

    final result = GlycemicCalc.dailyGL(all);

    // Compute net carbs for the day
    double totalCarbs = 0;
    double totalFiber = 0;
    for (final intake in all) {
      final n = intake.meal.nutriments;
      totalCarbs += intake.amount * ((n.carbohydrates100 ?? 0) / 100);
      totalFiber += intake.amount * ((n.fiber100 ?? 0) / 100);
    }

    setState(() {
      _result = result;
      _netCarbs = totalCarbs - totalFiber;
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
                Icon(Icons.bloodtype_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Glycemic Load',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_result == null || _result!.matchedFoods == 0)
              Text('Log meals to see glycemic load estimate',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant))
            else ...[
              Row(
                children: [
                  Text(
                    _result!.glycemicLoad.round().toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _glColor(_result!.classification),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _glColor(_result!.classification)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _result!.classification,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _glColor(_result!.classification),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_netCarbs != null)
                    Text(
                      'Net carbs: ${_netCarbs!.round()}g',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              if (_result!.isPartialEstimate)
                Text(
                  'Partial estimate (${_result!.matchedFoods}/${_result!.totalFoods} foods matched)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _glColor(String classification) {
    switch (classification) {
      case 'Low': return Colors.green;
      case 'Medium': return Colors.orange;
      default: return Colors.red;
    }
  }
}
