import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/core/db/entities/symptom_log_ob.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/generated/l10n.dart';

class DailySummaryCard extends StatefulWidget {
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
  State<DailySummaryCard> createState() => _DailySummaryCardState();
}

class _DailySummaryCardState extends State<DailySummaryCard> {
  /// null = not rated, true = thumbs up, false = thumbs down
  bool? _dayRating;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasIntakes) return const SizedBox();

    final theme = Theme.of(context);
    final checks = _evaluateDay();
    final allGood = checks.every((c) => c.passed);

    return Card(
      color: allGood
          ? theme.colorScheme.success.withValues(alpha: 0.1)
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
                  color: allGood ? theme.colorScheme.chartAmber : theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  allGood ? S.of(context).greatDayTitle : S.of(context).dailySummaryTitle,
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
                  S.of(context).greatDayMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const Divider(height: 16),
            _buildDayRatingRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRatingRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(S.of(context).howWasTodayLabel, style: theme.textTheme.bodySmall),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            _dayRating == true ? Icons.thumb_up : Icons.thumb_up_outlined,
          ),
          onPressed: () => _logDayRating(true),
          color: _dayRating == true ? theme.colorScheme.success : theme.colorScheme.success.withValues(alpha: 0.7),
          iconSize: 22,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            _dayRating == false ? Icons.thumb_down : Icons.thumb_down_outlined,
          ),
          onPressed: () => _logDayRating(false),
          color: _dayRating == false ? theme.colorScheme.error : theme.colorScheme.error.withValues(alpha: 0.7),
          iconSize: 22,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }

  Future<void> _logDayRating(bool positive) async {
    setState(() => _dayRating = positive);
    try {
      final symptomDs = locator<SymptomDataSource>();
      // Use mood_low symptom index (8) with severity: 5 = good day, 1 = bad day
      await symptomDs.addLog(SymptomLogOB(
        symptom: 8, // mood_low index — reused as general mood rating
        severity: positive ? 5 : 1,
        dateTime: DateTime.now(),
        notes: positive ? 'day_rating:good' : 'day_rating:bad',
      ));
    } catch (_) {}
  }

  Widget _buildCheckRow(ThemeData theme, _Check check) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            check.passed ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: check.passed ? theme.colorScheme.success : theme.colorScheme.error,
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
    final calDiff = widget.caloriesTracked - widget.calorieGoal;
    final calOnTrack = calDiff >= -1000 && calDiff <= 500;
    final calPct = widget.calorieGoal > 0
        ? (widget.caloriesTracked / widget.calorieGoal * 100).round()
        : 0;
    checks.add(_Check(
      passed: calOnTrack,
      label: calOnTrack
          ? S.of(context).caloriesOnTrack(calPct)
          : calDiff > 0
              ? S.of(context).overCalorieGoal(calDiff.round())
              : S.of(context).underCalorieGoal(calPct),
    ));

    // Protein check: >= 80% of goal
    if (widget.proteinGoal != null && widget.proteinGoal! > 0 && widget.proteinTracked != null) {
      final pctProtein = (widget.proteinTracked! / widget.proteinGoal! * 100).round();
      final proteinOk = pctProtein >= 80;
      checks.add(_Check(
        passed: proteinOk,
        label: proteinOk
            ? S.of(context).proteinGoalMet(pctProtein)
            : S.of(context).proteinLow(pctProtein),
      ));
    }

    // Gut health check
    final gutBad = widget.gutHealthItems.isNotEmpty;
    checks.add(_Check(
      passed: !gutBad,
      label: gutBad
          ? '${widget.gutHealthItems.length} gut-harmful item${widget.gutHealthItems.length > 1 ? 's' : ''} detected'
          : 'No gut-harmful items \u2014 clean eating!',
    ));

    return checks;
  }
}

class _Check {
  final bool passed;
  final String label;
  const _Check({required this.passed, required this.label});
}
