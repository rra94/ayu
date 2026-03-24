import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/stool_data_source.dart';
import 'package:opennutritracker/core/db/entities/stool_log_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class BristolStoolCard extends StatefulWidget {
  const BristolStoolCard({super.key});

  @override
  State<BristolStoolCard> createState() => _BristolStoolCardState();
}

class _BristolStoolCardState extends State<BristolStoolCard> {
  List<StoolLogOB> _logs = [];
  bool _loading = true;

  static const _typeDescriptions = {
    1: 'Hard lumps',
    2: 'Lumpy sausage',
    3: 'Cracked sausage',
    4: 'Smooth snake',
    5: 'Soft blobs',
    6: 'Mushy',
    7: 'Watery',
  };

  static const _typeIcons = {
    1: '🟤',
    2: '🟫',
    3: '🟢',
    4: '🟢',
    5: '🟡',
    6: '🟠',
    7: '🔴',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<StoolDataSource>();
    final logs = await ds.getLast30Days();
    setState(() {
      _logs = logs;
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
                Icon(Icons.water_drop_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Bristol Stool Scale',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showLogDialog(context),
                  tooltip: 'Log stool',
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
            else if (_logs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Tap + to log your first entry.\nTypes 3-4 are ideal.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              _buildDistribution(theme),
              const SizedBox(height: 8),
              _buildRecentList(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDistribution(ThemeData theme) {
    // Count by type
    final counts = List.filled(7, 0);
    for (final log in _logs) {
      if (log.type >= 1 && log.type <= 7) {
        counts[log.type - 1]++;
      }
    }
    final maxCount = counts.reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          maxY: maxCount > 0 ? maxCount + 1 : 5,
          alignment: BarChartAlignment.spaceAround,
          barGroups: List.generate(7, (i) {
            final isIdeal = i == 2 || i == 3; // types 3-4
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i].toDouble(),
                  color: isIdeal
                      ? Colors.green
                      : theme.colorScheme.primary.withValues(alpha: 0.5),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ],
            );
          }),
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
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt() + 1}',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRecentList(ThemeData theme) {
    final recent = _logs.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent (last 30 days: ${_logs.length} entries)',
            style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        ...recent.map((log) {
          final isIdeal = log.type == 3 || log.type == 4;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(_typeIcons[log.type] ?? '?', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Type ${log.type} — ${_typeDescriptions[log.type]}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isIdeal ? Colors.green : null,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(log.dateTime),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  void _showLogDialog(BuildContext context) {
    int? selectedType;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log Stool Type'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (i) {
                final type = i + 1;
                final isIdeal = type == 3 || type == 4;
                return RadioListTile<int>(
                  dense: true,
                  value: type,
                  groupValue: selectedType,
                  onChanged: (val) => setDialogState(() => selectedType = val),
                  title: Text(
                    '${_typeIcons[type]} Type $type — ${_typeDescriptions[type]}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isIdeal ? Colors.green : null,
                      fontWeight: isIdeal ? FontWeight.w600 : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedType == null
                  ? null
                  : () async {
                      final ds = locator<StoolDataSource>();
                      await ds.addLog(StoolLogOB(
                        type: selectedType!,
                        dateTime: DateTime.now(),
                      ));
                      Navigator.of(ctx).pop();
                      _load();
                    },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }
}
