import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/dexa_data_source.dart';
import 'package:opennutritracker/core/db/entities/dexa_scan_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:intl/intl.dart';

class DexaCard extends StatefulWidget {
  const DexaCard({super.key});

  @override
  State<DexaCard> createState() => _DexaCardState();
}

class _DexaCardState extends State<DexaCard> {
  List<DexaScanOB> _scans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<DexaDataSource>();
    final scans = await ds.getAllScans();
    setState(() {
      _scans = scans;
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
                Icon(Icons.accessibility_new,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('DEXA Body Composition',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showAddDialog(context),
                  tooltip: 'Add DEXA scan',
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
            else if (_scans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Add your DEXA scan results to track\nbody composition over time',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),
              ..._scans.take(3).map((scan) => _buildScanRow(theme, scan)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanRow(ThemeData theme, DexaScanOB scan) {
    final parts = <String>[];
    if (scan.totalBodyFatPercent != null) {
      parts.add('${scan.totalBodyFatPercent!.toStringAsFixed(1)}% BF');
    }
    if (scan.leanMassKG != null) {
      parts.add('${scan.leanMassKG!.toStringAsFixed(1)}kg lean');
    }
    if (scan.fatMassKG != null) {
      parts.add('${scan.fatMassKG!.toStringAsFixed(1)}kg fat');
    }
    if (scan.visceralFatArea != null) {
      parts.add('VAT ${scan.visceralFatArea!.toStringAsFixed(0)}cm\u00B2');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMd().format(scan.scanDate),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(parts.join(' | '), style: theme.textTheme.bodySmall),
          if (scan.boneMineralDensity != null || scan.tScore != null)
            Text(
              [
                if (scan.boneMineralDensity != null)
                  'BMD: ${scan.boneMineralDensity!.toStringAsFixed(3)}',
                if (scan.tScore != null)
                  'T-score: ${scan.tScore!.toStringAsFixed(1)}',
              ].join(' | '),
              style: theme.textTheme.labelSmall,
            ),
          const Divider(),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controllers = {
      'bodyFat': TextEditingController(),
      'leanMass': TextEditingController(),
      'fatMass': TextEditingController(),
      'bmd': TextEditingController(),
      'vat': TextEditingController(),
      'tScore': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add DEXA Scan'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controllers['bodyFat'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Body Fat %'),
                ),
                TextField(
                  controller: controllers['leanMass'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Lean Mass (kg)'),
                ),
                TextField(
                  controller: controllers['fatMass'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Fat Mass (kg)'),
                ),
                TextField(
                  controller: controllers['bmd'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Bone Mineral Density (g/cm\u00B2)'),
                ),
                TextField(
                  controller: controllers['vat'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Visceral Fat Area (cm\u00B2)'),
                ),
                TextField(
                  controller: controllers['tScore'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'T-Score'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final ds = locator<DexaDataSource>();
              await ds.addScan(DexaScanOB(
                scanDate: DateTime.now(),
                totalBodyFatPercent:
                    double.tryParse(controllers['bodyFat']!.text),
                leanMassKG:
                    double.tryParse(controllers['leanMass']!.text),
                fatMassKG:
                    double.tryParse(controllers['fatMass']!.text),
                boneMineralDensity:
                    double.tryParse(controllers['bmd']!.text),
                visceralFatArea:
                    double.tryParse(controllers['vat']!.text),
                tScore:
                    double.tryParse(controllers['tScore']!.text),
              ));
              Navigator.of(ctx).pop();
              _load();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
