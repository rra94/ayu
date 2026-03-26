import 'dart:async';

import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/entities/supplement_ob.dart';
import 'package:opennutritracker/core/services/intent_donation_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class SupplementChecklistWidget extends StatefulWidget {
  const SupplementChecklistWidget({super.key});

  @override
  State<SupplementChecklistWidget> createState() =>
      _SupplementChecklistWidgetState();
}

class _SupplementChecklistWidgetState extends State<SupplementChecklistWidget> {
  List<SupplementOB> _supplements = [];
  Set<int> _takenIds = {};
  bool _loading = true;
  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    super.dispose();
  }

  void _scheduleReload() {
    _reloadTimer?.cancel();
    _reloadTimer = Timer(const Duration(milliseconds: 300), () => _load());
  }

  Future<void> _load() async {
    final ds = locator<SupplementDataSource>();
    final supplements = await ds.getAllActive();
    final takenIds = await ds.getTakenIdsForDate(DateTime.now());
    if (!mounted) return;
    setState(() {
      _supplements = supplements;
      _takenIds = takenIds;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) return const SizedBox();
    if (_supplements.isEmpty) {
      return const SizedBox.shrink();
    }

    final takenCount = _takenIds.length;
    final totalCount = _supplements.length;

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.medication_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Supplements',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: takenCount == totalCount
                        ? Colors.green.withValues(alpha: 0.2)
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$takenCount/$totalCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: takenCount == totalCount
                          ? Colors.green
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showAddDialog(context),
                ),
              ],
            ),
            const Divider(),
            ..._supplements.map((supp) {
              final taken = _takenIds.contains(supp.id);
              return Semantics(
                label: '${supp.name} ${supp.dosage}${supp.unit}. ${taken ? "Taken" : "Not taken"}. Tap to toggle.',
                button: true,
                child: InkWell(
                onTap: () async {
                  try {
                  final nowTaken = !taken;
                  final ds = locator<SupplementDataSource>();
                  await ds.toggleLog(supp.id, DateTime.now(), nowTaken);
                  if (nowTaken) {
                    IntentDonationService.donateTakeSupplements();
                  }
                  _scheduleReload();
                  if (context.mounted) {
                    // Don't clear previous snackbars — let them queue naturally
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${supp.name} marked as ${nowTaken ? "taken" : "skipped"}'),
                        duration: const Duration(seconds: 10),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await ds.toggleLog(
                                supp.id, DateTime.now(), !nowTaken);
                            _load();
                          },
                        ),
                      ),
                    );
                  }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update: $e')),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: taken,
                        onChanged: null, // handled by InkWell onTap
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${supp.name} ${supp.dosage}${supp.unit}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                decoration: taken ? TextDecoration.lineThrough : null,
                                color: taken
                                    ? theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.5)
                                    : null,
                              ),
                            ),
                            Text(supp.category,
                                style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              );
              // Original onChanged code removed — now handled in InkWell.onTap above
              // This is a workaround for CheckboxListTile not receiving taps
              // inside CollapsibleSection > Card > ListView scroll context
            }),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    String unit = 'mg';
    String category = 'vitamin';

    final units = ['mg', 'mcg', 'IU', 'g', 'drops', 'capsule'];
    final categories = [
      'vitamin', 'mineral', 'amino_acid', 'herbal', 'probiotic', 'other'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Supplement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dosageCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(labelText: 'Dosage'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: unit,
                    items: units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => unit = val ?? unit),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => category = val ?? category),
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
                if (nameCtrl.text.isNotEmpty) {
                  final ds = locator<SupplementDataSource>();
                  await ds.addSupplement(SupplementOB(
                    name: nameCtrl.text,
                    dosage: dosageCtrl.text.isEmpty ? '1' : dosageCtrl.text,
                    unit: unit,
                    category: category,
                  ));
                  Navigator.of(ctx).pop();
                  _load();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
