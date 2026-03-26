import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/generated/l10n.dart';
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
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.biotech, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(S.of(context).biomarkersLabel,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddDialog(context),
                  tooltip: S.of(context).addLabResultTooltip,
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
                        S.of(context).biomarkerEmptyState,
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
              ..._buildStaleAlerts(theme),
              ..._buildCategoryGroups(theme),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStaleAlerts(ThemeData theme) {
    final stale = <String>[];
    final now = DateTime.now();

    for (final entry in _latestValues.entries) {
      final def = OptimalRangeCalc.getDefinition(entry.key);
      if (def == null) continue;
      final daysSince = now.difference(entry.value.dateTime).inDays;
      if (daysSince > def.refreshDays) {
        stale.add('${def.name} (${daysSince}d ago — refresh every ${def.refreshDays}d)');
      }
    }

    if (stale.isEmpty) return [];

    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.update, size: 16, color: theme.colorScheme.warning),
                const SizedBox(width: 6),
                Text(S.of(context).staleBiomarkersHeader,
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600, color: theme.colorScheme.warning)),
              ],
            ),
            const SizedBox(height: 4),
            ...stale.take(3).map((s) => Text(s,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 12))),
            if (stale.length > 3)
              Text('+${stale.length - 3} more',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ];
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
        ? theme.colorScheme.success
        : rating == 1
            ? theme.colorScheme.warning
            : theme.colorScheme.error;
    final label = rating == 2
        ? S.of(context).optimalRating
        : rating == 1
            ? S.of(context).normalRating
            : S.of(context).outOfRangeRating;

    final record = _latestValues[def.key]!;

    return InkWell(
      onTap: () => _showEditDialog(context, def, record),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, BiomarkerDef def, BiomarkerRecordOB record) {
    final valueController =
        TextEditingController(text: record.value.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).editBiomarkerTitle(def.name)),
        content: TextField(
          controller: valueController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: S.of(context).valueLabel,
            suffixText: def.unit,
            hintText: 'Optimal: ${def.optimalLow}–${def.optimalHigh}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.of(context).cancelLabel),
          ),
          FilledButton(
            onPressed: valueController.text.isEmpty
                ? null
                : () async {
                    final value =
                        double.tryParse(valueController.text);
                    if (value != null) {
                      // Validate against known ranges
                      if (value < def.normalLow * 0.1 ||
                          value > def.normalHigh * 5) {
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (c) => AlertDialog(
                            title: Text(S.of(context).unusualValueTitle),
                            content: Text(
                                'The value ${value.toStringAsFixed(1)} ${def.unit} seems unusual for ${def.name} '
                                '(normal range: ${def.normalLow}–${def.normalHigh}). Are you sure?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(c).pop(false),
                                  child: Text(S.of(context).cancelLabel)),
                              FilledButton(
                                  onPressed: () => Navigator.of(c).pop(true),
                                  child: Text(S.of(context).saveAnywayLabel)),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                      }
                      final ds = locator<BiomarkerDataSource>();
                      // Re-use same ObjectBox id → upsert (update in place)
                      await ds.addRecord(BiomarkerRecordOB(
                        id: record.id,
                        type: record.type,
                        value: value,
                        unit: record.unit,
                        dateTime: record.dateTime,
                        source: record.source,
                      ));
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      _load();
                    }
                  },
            child: Text(S.of(context).updateLabel),
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
            title: Text(S.of(context).addLabResultTitle),
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
                                  style: const TextStyle(fontSize: 12),
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
                      labelText: S.of(context).valueLabel,
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
                child: Text(S.of(context).cancelLabel),
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
                          // Validate against known ranges
                          if (value < def.normalLow * 0.1 ||
                              value > def.normalHigh * 5) {
                            final confirm = await showDialog<bool>(
                              context: ctx,
                              builder: (c) => AlertDialog(
                                title: Text(S.of(context).unusualValueTitle),
                                content: Text(
                                    'The value ${value.toStringAsFixed(1)} ${def.unit} seems unusual for ${def.name} '
                                    '(normal range: ${def.normalLow}–${def.normalHigh}). Are you sure?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(false),
                                      child: Text(S.of(context).cancelLabel)),
                                  FilledButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(true),
                                      child: Text(S.of(context).saveAnywayLabel)),
                                ],
                              ),
                            );
                            if (confirm != true) return;
                          }
                          final ds = locator<BiomarkerDataSource>();
                          await ds.addRecord(BiomarkerRecordOB(
                            type: selectedKey!,
                            value: value,
                            unit: def.unit,
                            dateTime: DateTime.now(),
                            source: 0,
                          ));
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          _load();
                        }
                      },
                child: Text(S.of(context).saveLabel),
              ),
            ],
          );
        },
      ),
    );
  }
}
