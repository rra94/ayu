import 'package:flutter/material.dart';
import 'package:opennutritracker/core/services/daily_summary_service.dart';
import 'package:opennutritracker/core/services/weekly_review_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class WeeklyReviewCard extends StatefulWidget {
  const WeeklyReviewCard({super.key});

  @override
  State<WeeklyReviewCard> createState() => _WeeklyReviewCardState();
}

class _WeeklyReviewCardState extends State<WeeklyReviewCard> {
  bool _loading = true;
  bool _expanded = false;
  WeeklyReviewResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = locator<DailySummaryService>();
    final now = DateTime.now();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));

    final thisWeekStart = DateTime(thisMonday.year, thisMonday.month, thisMonday.day);
    final thisWeekEnd = DateTime(now.year, now.month, now.day);
    final lastWeekStart = DateTime(lastMonday.year, lastMonday.month, lastMonday.day);
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    final thisWeek = await service.buildRange(thisWeekStart, thisWeekEnd);
    final lastWeek = await service.buildRange(lastWeekStart, lastWeekEnd);

    final result = WeeklyReviewService.generate(thisWeek, lastWeek);

    setState(() {
      _result = result;
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
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Icon(Icons.summarize, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Weekly Review',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_expanded && _result != null) ...[
              const Divider(),
              // Wins
              if (_result!.wins.isNotEmpty) ...[
                Text('Wins',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.green, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ..._result!.wins.map((w) => _buildItem(theme, w, Colors.green)),
                const SizedBox(height: 8),
              ],
              // Improvements
              if (_result!.improvements.isNotEmpty) ...[
                Text('Areas to Improve',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.orange, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ..._result!.improvements
                    .map((i) => _buildItem(theme, i, Colors.orange)),
                const SizedBox(height: 8),
              ],
              // Trends
              if (_result!.trends.isNotEmpty) ...[
                Text('Week-over-Week',
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ..._result!.trends.entries.map((e) => _buildTrend(theme, e)),
              ],
              // Summary stats
              if (_result!.avgCalories != null ||
                  _result!.avgSleep != null ||
                  _result!.weightChange != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  children: [
                    if (_result!.avgCalories != null)
                      Text(
                          'Avg cal: ${_result!.avgCalories!.round()}/day',
                          style: theme.textTheme.bodySmall),
                    if (_result!.avgSleep != null)
                      Text(
                          'Avg sleep: ${_result!.avgSleep!.toStringAsFixed(1)}h',
                          style: theme.textTheme.bodySmall),
                    if (_result!.weightChange != null)
                      Text(
                          'Weight: ${_result!.weightChange! >= 0 ? '+' : ''}${_result!.weightChange!.toStringAsFixed(1)}kg',
                          style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ] else if (!_loading && !_expanded)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Tap to expand your weekly summary',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ThemeData theme, WeeklyReviewItem item, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            item.isWin ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(item.text, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildTrend(ThemeData theme, MapEntry<String, String> trend) {
    final icon = trend.value == 'up'
        ? Icons.trending_up
        : trend.value == 'down'
            ? Icons.trending_down
            : Icons.trending_flat;
    final color = trend.value == 'up'
        ? Colors.green
        : trend.value == 'down'
            ? Colors.orange
            : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '${trend.key[0].toUpperCase()}${trend.key.substring(1)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
