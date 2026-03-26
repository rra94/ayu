import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/services/health_condition_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

enum _GlucoseTiming {
  fasting('Fasting'),
  beforeMeal('Before meal'),
  oneHourAfter('1h after meal'),
  twoHoursAfter('2h after meal'),
  bedtime('Bedtime');

  const _GlucoseTiming(this.label);
  final String label;
}

class GlucoseCard extends StatefulWidget {
  const GlucoseCard({super.key});

  @override
  State<GlucoseCard> createState() => _GlucoseCardState();
}

class _GlucoseCardState extends State<GlucoseCard> {
  bool _loading = true;
  List<BiomarkerRecordOB> _allRecords = [];
  List<BiomarkerRecordOB> _records = [];
  bool _hasDiabetes = false;
  int _periodDays = 7;

  static const _type = 'glucose';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<BiomarkerDataSource>();
    final all = await ds.getRecordsByType(_type);
    final conditions = HealthConditionService.getUserConditions();
    final hasDiabetes = conditions.any(
        (c) => c.toLowerCase().contains('diabetes'));
    setState(() {
      _allRecords = all; // store all records
      _hasDiabetes = hasDiabetes;
      _loading = false;
      _applyPeriodFilter();
    });
  }

  void _applyPeriodFilter() {
    final cutoff = DateTime.now().subtract(Duration(days: _periodDays));
    final filtered = _allRecords
        .where((r) => r.dateTime.isAfter(cutoff))
        .toList();
    // Keep at most last 30, oldest first for chart
    _records = filtered.reversed.toList().take(30).toList().reversed.toList();
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
            // Header
            Row(
              children: [
                Icon(Icons.water_drop_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Blood Glucose',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add reading',
                  onPressed: () => _showAddDialog(context),
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
                    'Add a blood glucose reading to start tracking',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              // Period selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('7d'),
                    selected: _periodDays == 7,
                    onSelected: (_) => setState(() {
                      _periodDays = 7;
                      _applyPeriodFilter();
                    }),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('30d'),
                    selected: _periodDays == 30,
                    onSelected: (_) => setState(() {
                      _periodDays = 30;
                      _applyPeriodFilter();
                    }),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('90d'),
                    selected: _periodDays == 90,
                    onSelected: (_) => setState(() {
                      _periodDays = 90;
                      _applyPeriodFilter();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildLatestReading(theme),
              if (_records.length > 1) ...[
                const SizedBox(height: 12),
                SizedBox(height: 100, child: _buildChart(theme)),
              ],
              const SizedBox(height: 8),
              _buildLegend(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLatestReading(ThemeData theme) {
    final latest = _records.last;
    final color = _glucoseColor(latest.value);

    return Row(
      children: [
        Text(
          '${latest.value.round()} mg/dL',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _glucoseLabel(latest.value),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (latest.notes != null && latest.notes!.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            latest.notes!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const Spacer(),
        Text(
          _formatDate(latest.dateTime),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(ThemeData theme) {
    final spots = _records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        minY: 60,
        maxY: _records.map((r) => r.value).reduce((a, b) => a > b ? a : b) + 20,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) {
                final color = _glucoseColor(spot.y);
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        // Reference lines for fasting ranges (diabetes-aware)
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: _normalMax,
            color: Colors.orange.withValues(alpha: 0.4),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
          HorizontalLine(
            y: _highMin,
            color: Colors.red.withValues(alpha: 0.4),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ]),
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
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= _records.length) {
                  return const SizedBox();
                }
                final d = _records[idx].dateTime;
                return Text(
                  '${d.month}/${d.day}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    final labelStyle = theme.textTheme.bodySmall;
    if (_hasDiabetes) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendDot(Colors.green),
          const SizedBox(width: 3),
          Text('Controlled (70–130)', style: labelStyle),
          const SizedBox(width: 8),
          _legendDot(Colors.orange),
          const SizedBox(width: 3),
          Text('Above target', style: labelStyle),
          const SizedBox(width: 8),
          _legendDot(Colors.red),
          const SizedBox(width: 3),
          Text('High (>180)', style: labelStyle),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendDot(Colors.green),
        const SizedBox(width: 3),
        Text('Normal (70–100)', style: labelStyle),
        const SizedBox(width: 8),
        _legendDot(Colors.orange),
        const SizedBox(width: 3),
        Text('Pre-diabetic', style: labelStyle),
        const SizedBox(width: 8),
        _legendDot(Colors.red),
        const SizedBox(width: 3),
        Text('High', style: labelStyle),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  double get _normalMax => _hasDiabetes ? 130.0 : 100.0;
  double get _highMin => _hasDiabetes ? 180.0 : 126.0;

  Color _glucoseColor(double value) {
    if (value <= _normalMax) return Colors.green;
    if (value <= _highMin) return Colors.orange;
    return Colors.red;
  }

  String _glucoseLabel(double value) {
    if (_hasDiabetes) {
      if (value <= 130) return 'Controlled';
      if (value <= 180) return 'Above target';
      return 'High — consult doctor';
    }
    if (value <= 100) return 'Normal';
    if (value <= 126) return 'Pre-diabetic';
    return 'High';
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showAddDialog(BuildContext context, {BiomarkerRecordOB? existing}) {
    final valueController = TextEditingController(
      text: existing != null ? existing.value.toStringAsFixed(0) : '',
    );
    final notesController = TextEditingController();
    _GlucoseTiming timing = _GlucoseTiming.fasting;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Reading' : 'Edit Reading'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Blood glucose (mg/dL)',
                  hintText: 'e.g. 95',
                  suffixText: 'mg/dL',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<_GlucoseTiming>(
                initialValue: timing,
                decoration: const InputDecoration(
                  labelText: 'Timing',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _GlucoseTiming.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => timing = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. after breakfast',
                ),
                maxLines: 1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: valueController.text.isEmpty
                  ? null
                  : () async {
                      final value =
                          double.tryParse(valueController.text);
                      if (value == null) return;
                      final ds = locator<BiomarkerDataSource>();
                      await ds.addRecord(BiomarkerRecordOB(
                        id: existing?.id ?? 0,
                        type: _type,
                        value: value,
                        unit: 'mg/dL',
                        dateTime: existing?.dateTime ?? DateTime.now(),
                        source: 0,
                        notes: timing.label,
                      ));
                      if (ctx.mounted) Navigator.of(ctx).pop();
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
