import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/core/db/data_sources/weight_data_source.dart';
import 'package:opennutritracker/core/db/entities/config_ob.dart';
import 'package:opennutritracker/core/db/entities/weight_record_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/objectbox.g.dart';

class WeightChartCard extends StatefulWidget {
  const WeightChartCard({super.key});

  @override
  State<WeightChartCard> createState() => _WeightChartCardState();
}

class _WeightChartCardState extends State<WeightChartCard> {
  List<WeightRecordOB> _records = [];
  double? _targetWeight;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<WeightDataSource>();
    final records = await ds.getAllRecords();
    final store = locator<Store>();
    final configBox = store.box<ConfigOB>();
    final config = configBox.getAll().firstOrNull;
    setState(() {
      _records = records;
      _targetWeight = config?.targetWeightKG;
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
                Icon(Icons.monitor_weight_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Weight',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showAddDialog(context),
                  tooltip: 'Log weight',
                ),
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 20),
                  onPressed: () => _showTargetDialog(context),
                  tooltip: 'Set target',
                ),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.scale, size: 40,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text('Log your first weight entry',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              )
            else ...[
              _buildSummary(theme),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: _buildChart(theme),
              ),
              if (_records.length > 1) ...[
                const SizedBox(height: 8),
                _buildEta(theme),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final latest = _records.last;
    final change = _records.length > 1
        ? latest.weightKG - _records[_records.length - 2].weightKG
        : 0.0;
    final changeStr = change >= 0
        ? '+${change.toStringAsFixed(1)}'
        : change.toStringAsFixed(1);

    return Row(
      children: [
        Text(
          '${latest.weightKG.toStringAsFixed(1)} kg',
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        if (_records.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: change <= 0
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$changeStr kg',
              style: theme.textTheme.labelSmall?.copyWith(
                color: change <= 0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (_targetWeight != null) ...[
          const Spacer(),
          Text(
            'Target: ${_targetWeight!.toStringAsFixed(1)} kg',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChart(ThemeData theme) {
    final spots = _records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightKG);
    }).toList();

    final weights = _records.map((r) => r.weightKG).toList();
    var minY = weights.reduce((a, b) => a < b ? a : b) - 2;
    var maxY = weights.reduce((a, b) => a > b ? a : b) + 2;
    if (_targetWeight != null) {
      minY = [minY, _targetWeight! - 2].reduce((a, b) => a < b ? a : b);
      maxY = [maxY, _targetWeight! + 2].reduce((a, b) => a > b ? a : b);
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _records.length > 7
                  ? (_records.length / 5).ceilToDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= _records.length) return const SizedBox();
                return Text(
                  DateFormat('d/M').format(_records[idx].dateTime),
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: theme.colorScheme.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: _records.length <= 30,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: theme.colorScheme.primary,
                    strokeWidth: 0,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        extraLinesData: _targetWeight != null
            ? ExtraLinesData(horizontalLines: [
                HorizontalLine(
                  y: _targetWeight!,
                  color: Colors.green,
                  strokeWidth: 1.5,
                  dashArray: [8, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                    labelResolver: (_) => 'Target',
                  ),
                ),
              ])
            : null,
      ),
    );
  }

  Widget _buildEta(ThemeData theme) {
    if (_targetWeight == null) return const SizedBox();
    final current = _records.last.weightKG;
    final diff = (current - _targetWeight!).abs();
    if (diff < 0.5) {
      return Text(
        'You\'re at your target weight!',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
      );
    }
    final weeksToGoal = (diff / 0.45).ceil(); // ~1 lb/week safe rate
    return Text(
      'Estimated ${weeksToGoal}w to target (at ~0.45 kg/week)',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            hintText: 'e.g. 72.5',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final ds = locator<WeightDataSource>();
                await ds.addRecord(WeightRecordOB(
                  weightKG: value,
                  dateTime: DateTime.now(),
                ));
                Navigator.of(ctx).pop();
                _load();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog(BuildContext context) {
    final controller = TextEditingController(
      text: _targetWeight?.toStringAsFixed(1) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Target Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Target weight (kg)',
            hintText: 'e.g. 70.0',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                final store = locator<Store>();
                final configBox = store.box<ConfigOB>();
                final config = configBox.getAll().firstOrNull ??
                    ConfigOB();
                config.targetWeightKG = value;
                configBox.put(config);
                Navigator.of(ctx).pop();
                _load();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
