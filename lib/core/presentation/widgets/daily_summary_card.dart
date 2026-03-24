import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';

class DailySummaryCard extends StatelessWidget {
  final double calorieGoal;
  final double caloriesTracked;
  final double? carbsGoal;
  final double? carbsTracked;
  final double? fatGoal;
  final double? fatTracked;
  final double? proteinGoal;
  final double? proteinTracked;
  final List<GutHealthItemOB> gutHealthItems;
  final bool hasIntakes;

  const DailySummaryCard({
    super.key,
    required this.calorieGoal,
    required this.caloriesTracked,
    this.carbsGoal,
    this.carbsTracked,
    this.fatGoal,
    this.fatTracked,
    this.proteinGoal,
    this.proteinTracked,
    required this.gutHealthItems,
    required this.hasIntakes,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasIntakes) return const SizedBox();

    final theme = Theme.of(context);
    final checks = _evaluateDay();
    final allGood = checks.every((c) => c.passed);

    return Card(
      
      color: allGood
          ? Colors.green.withValues(alpha: 0.1)
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allGood ? Icons.emoji_events : Icons.insights,
                  color: allGood ? Colors.amber : theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  allGood ? 'Great day!' : 'Daily Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...checks.map((c) => _buildCheckRow(theme, c)),
            if (allGood)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'You hit your goals and kept your gut clean. Keep it up!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(ThemeData theme, _Check check) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            check.passed ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: check.passed ? Colors.green : theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              check.label,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  List<_Check> _evaluateDay() {
    final checks = <_Check>[];

    // Calorie check: within -1000 to +500 of goal
    final calDiff = caloriesTracked - calorieGoal;
    final calOnTrack = calDiff >= -1000 && calDiff <= 500;
    final calPct = calorieGoal > 0
        ? (caloriesTracked / calorieGoal * 100).round()
        : 0;
    checks.add(_Check(
      passed: calOnTrack,
      label: calOnTrack
          ? 'Calories on track ($calPct% of goal)'
          : calDiff > 0
              ? 'Over calorie goal by ${calDiff.round()} kcal'
              : 'Under calorie goal ($calPct%)',
    ));

    // Protein check: >= 80% of goal
    if (proteinGoal != null && proteinGoal! > 0 && proteinTracked != null) {
      final pctProtein = (proteinTracked! / proteinGoal! * 100).round();
      final proteinOk = pctProtein >= 80;
      checks.add(_Check(
        passed: proteinOk,
        label: proteinOk
            ? 'Protein goal met ($pctProtein%)'
            : 'Protein low ($pctProtein% of goal)',
      ));
    }

    // Gut health check
    final gutBad = gutHealthItems.isNotEmpty;
    checks.add(_Check(
      passed: !gutBad,
      label: gutBad
          ? '${gutHealthItems.length} gut-harmful item${gutHealthItems.length > 1 ? 's' : ''} detected'
          : 'No gut-harmful items — clean eating!',
    ));

    return checks;
  }
}

class _Check {
  final bool passed;
  final String label;
  const _Check({required this.passed, required this.label});
}
