import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/utils/calc/optimal_range_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class BiomarkerCard extends StatefulWidget {
  const BiomarkerCard({super.key});

  @override
  State<BiomarkerCard> createState() => _BiomarkerCardState();
}

class _BiomarkerCardState extends State<BiomarkerCard> {
  bool _loading = true;
  Map<String, BiomarkerRecordOB> _latestValues = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<BiomarkerDataSource>();
    final latest = await ds.getLatestByType();
    setState(() {
      _latestValues = latest;
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
                Icon(Icons.biotech, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Biomarkers',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showAddDialog(context),
                  tooltip: 'Add lab result',
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
            else if (_latestValues.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.science, size: 36,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(
                        'Add your blood work results to track\nbiomarkers against longevity-optimal ranges',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              ..._buildCategoryGroups(theme),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryGroups(ThemeData theme) {
    final categories = OptimalRangeCalc.getByCategory();
    final widgets = <Widget>[];

    for (final entry in categories.entries) {
      final categoryMarkers = entry.value
          .where((b) => _latestValues.containsKey(b.key))
          .toList();
      if (categoryMarkers.isEmpty) continue;

      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          entry.key,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ));

      for (final def in categoryMarkers) {
        final record = _latestValues[def.key]!;
        final rating = def.getRating(record.value);
        widgets.add(_buildMarkerRow(theme, def, record.value, rating));
      }
    }

    return widgets;
  }

  Widget _buildMarkerRow(
      ThemeData theme, BiomarkerDef def, double value, int rating) {
    final color = rating == 2
        ? Colors.green
        : rating == 1
            ? Colors.orange
            : Colors.red;
    final label = rating == 2
        ? 'Optimal'
        : rating == 1
            ? 'Normal'
            : 'Out of range';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(def.name, style: theme.textTheme.bodySmall),
          ),
          Text(
            '${value.toStringAsFixed(1)} ${def.unit}',
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    String? selectedKey;
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final categories = OptimalRangeCalc.getByCategory();
          return AlertDialog(
            title: const Text('Add Lab Result'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: categories.entries.expand((cat) {
                        return [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(cat.key,
                                style: Theme.of(ctx)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          ...cat.value.map((def) => RadioListTile<String>(
                                dense: true,
                                value: def.key,
                                groupValue: selectedKey,
                                onChanged: (val) =>
                                    setDialogState(() => selectedKey = val),
                                title: Text('${def.name} (${def.unit})',
                                    style: const TextStyle(fontSize: 13)),
                                subtitle: Text(
                                  'Optimal: ${def.optimalLow}-${def.optimalHigh}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              )),
                        ];
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: valueController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Value',
                      hintText: selectedKey != null
                          ? OptimalRangeCalc.getDefinition(selectedKey!)?.unit
                          : '',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: (selectedKey == null ||
                        valueController.text.isEmpty)
                    ? null
                    : () async {
                        final value = double.tryParse(valueController.text);
                        final def =
                            OptimalRangeCalc.getDefinition(selectedKey!);
                        if (value != null && def != null) {
                          final ds = locator<BiomarkerDataSource>();
                          await ds.addRecord(BiomarkerRecordOB(
                            type: selectedKey!,
                            value: value,
                            unit: def.unit,
                            dateTime: DateTime.now(),
                            source: 0,
                          ));
                          Navigator.of(ctx).pop();
                          _load();
                        }
                      },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
