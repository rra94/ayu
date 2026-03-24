import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/entities/sleep_record_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class SleepCard extends StatefulWidget {
  const SleepCard({super.key});

  @override
  State<SleepCard> createState() => _SleepCardState();
}

class _SleepCardState extends State<SleepCard> {
  List<SleepRecordOB> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<SleepDataSource>();
    final records = await ds.getRecords(limit: 7);
    setState(() {
      _records = records.reversed.toList(); // oldest first for chart
      _loading = false;
    });
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
                Icon(Icons.bedtime_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Sleep',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showLogDialog(context),
                  tooltip: 'Log sleep',
                ),
              ],
            ),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Log your sleep to track duration and quality',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              _buildLastNight(theme),
              if (_records.length > 1) ...[
                const SizedBox(height: 12),
                SizedBox(height: 120, child: _buildChart(theme)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastNight(ThemeData theme) {
    final last = _records.last;
    final hours = last.durationHours;
    final stars = '★' * last.qualityScore + '☆' * (5 - last.qualityScore);

    return Row(
      children: [
        Text(
          '${hours.toStringAsFixed(1)}h',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: hours >= 7 ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stars, style: const TextStyle(color: Colors.amber)),
            if (last.notes != null && last.notes!.isNotEmpty)
              Text(last.notes!,
                  style: theme.textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(ThemeData theme) {
    return BarChart(
      BarChartData(
        maxY: 12,
        alignment: BarChartAlignment.spaceAround,
        barGroups: _records.asMap().entries.map((e) {
          final hours = e.value.durationHours;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: hours,
                color: hours >= 7 ? Colors.green : Colors.orange,
                width: 16,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= _records.length) {
                  return const SizedBox();
                }
                final stars = '★' * _records[idx].qualityScore;
                return Text(stars,
                    style: const TextStyle(fontSize: 8, color: Colors.amber));
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: 8,
            color: Colors.green.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ]),
      ),
    );
  }

  void _showLogDialog(BuildContext context) {
    TimeOfDay bedTime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 0);
    int quality = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log Sleep'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bedtime'),
                trailing: Text(bedTime.format(ctx)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: bedTime,
                  );
                  if (picked != null) {
                    setDialogState(() => bedTime = picked);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Wake time'),
                trailing: Text(wakeTime.format(ctx)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: wakeTime,
                  );
                  if (picked != null) {
                    setDialogState(() => wakeTime = picked);
                  }
                },
              ),
              Row(
                children: [
                  const Text('Quality: '),
                  Expanded(
                    child: Slider(
                      value: quality.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$quality',
                      onChanged: (val) =>
                          setDialogState(() => quality = val.round()),
                    ),
                  ),
                  Text('$quality/5'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final now = DateTime.now();
                final yesterday = now.subtract(const Duration(days: 1));
                final bed = DateTime(yesterday.year, yesterday.month,
                    yesterday.day, bedTime.hour, bedTime.minute);
                final wake = DateTime(
                    now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);

                final ds = locator<SleepDataSource>();
                await ds.addRecord(SleepRecordOB(
                  bedTime: bed,
                  wakeTime: wake,
                  qualityScore: quality,
                ));
                Navigator.of(ctx).pop();
                _load();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
