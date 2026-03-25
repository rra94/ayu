import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/peptide_data_source.dart';
import 'package:opennutritracker/core/db/entities/peptide_ob.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'peptide_log_dialog.dart';

class PeptideStackWidget extends StatefulWidget {
  const PeptideStackWidget({super.key});

  @override
  State<PeptideStackWidget> createState() => _PeptideStackWidgetState();
}

class _PeptideStackWidgetState extends State<PeptideStackWidget> {
  List<PeptideOB> _peptides = [];
  Set<int> _todayLoggedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<PeptideDataSource>();
    final peptides = await ds.getAllActive();
    final todayLogged = await ds.getTodayLoggedIds();
    setState(() {
      _peptides = peptides;
      _todayLoggedIds = todayLogged;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = isDark ? ayuGoldLight : ayuGoldMuted;

    if (_loading) return const SizedBox();

    if (_peptides.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.vaccines_outlined, color: goldColor),
                  const SizedBox(width: 8),
                  Text(
                    'Peptides',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'No peptides. Add one to track your stack.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dosedCount = _todayLoggedIds.length;
    final totalCount = _peptides.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              children: [
                Icon(Icons.vaccines_outlined, color: goldColor),
                const SizedBox(width: 8),
                Text(
                  'Peptides',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: dosedCount == totalCount
                        ? Colors.green.withValues(alpha: 0.2)
                        : goldColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dosedCount/$totalCount dosed today',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: dosedCount == totalCount
                          ? Colors.green
                          : goldColor,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showAddDialog(context),
                  tooltip: 'Add Peptide',
                ),
              ],
            ),
            const Divider(),
            // Peptide rows
            ..._peptides.map((p) => _buildPeptideRow(context, p, goldColor, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeptideRow(
      BuildContext context, PeptideOB p, Color goldColor, ThemeData theme) {
    final logged = _todayLoggedIds.contains(p.id);
    final isDoseDay = p.isDoseDay;
    final isResting = !p.isInActiveCyclePhase;

    final cycleText = isResting
        ? 'REST'
        : 'Day ${p.cycleDayNumber}/${p.cycleDays}';

    final doseStr =
        '${p.doseMcg.toStringAsFixed(0)}mcg ${p.route}';

    final dimmed = !isDoseDay;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          Checkbox(
            value: logged,
            activeColor: goldColor,
            onChanged: isDoseDay
                ? (val) async {
                    if (val == true) {
                      await _showLogDialog(context, p);
                    }
                  }
                : null,
          ),
          // Main info
          Expanded(
            child: Opacity(
              opacity: dimmed ? 0.45 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.name} \u2022 $doseStr',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration:
                          logged ? TextDecoration.lineThrough : null,
                      color: logged
                          ? theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.5)
                          : null,
                    ),
                  ),
                  Row(
                    children: [
                      if (!isDoseDay && !isResting)
                        Text(
                          'Not a dose day',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.textTheme.labelSmall?.color
                                ?.withValues(alpha: 0.5),
                          ),
                        )
                      else
                        Text(
                          '${p.dosesPerVial} doses/vial',
                          style: theme.textTheme.labelSmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cycle badge
          _buildCycleBadge(cycleText, isResting, goldColor, theme),
        ],
      ),
    );
  }

  Widget _buildCycleBadge(
      String text, bool isResting, Color goldColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isResting
            ? Colors.red.withValues(alpha: 0.15)
            : goldColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isResting ? Colors.red : goldColor,
        ),
      ),
    );
  }

  Future<void> _showLogDialog(BuildContext context, PeptideOB peptide) async {
    final ds = locator<PeptideDataSource>();
    final history = await ds.getInjectionSiteHistory(peptide.id, count: 10);
    final recentSites = history.map((l) => l.injectionSite).toList();

    if (!context.mounted) return;

    final logged = await showDialog<bool>(
      context: context,
      builder: (_) => PeptideLogDialog(
        peptide: peptide,
        recentSites: recentSites,
      ),
    );

    if (logged == true) {
      _load();
    }
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final mgCtrl = TextEditingController();
    final bacCtrl = TextEditingController();
    final doseUnitsCtrl = TextEditingController();
    final cycleDaysCtrl = TextEditingController(text: '60');
    final restDaysCtrl = TextEditingController(text: '30');
    String frequency = 'daily';
    String route = 'subq';

    const frequencies = ['daily', 'eod', 'mon_wed_fri', '5on2off', 'weekly'];
    const routes = ['subq', 'im'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Peptide'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: mgCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Peptide mg'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bacCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'BAC water ml'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: doseUnitsCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Dose units (syringe)'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: frequencies
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => frequency = val ?? frequency),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cycleDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Cycle days'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: restDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Rest days'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: route,
                  decoration: const InputDecoration(labelText: 'Route'),
                  items: routes
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => route = val ?? route),
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
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  final ds = locator<PeptideDataSource>();
                  await ds.addPeptide(PeptideOB(
                    name: nameCtrl.text,
                    peptideMg: double.tryParse(mgCtrl.text) ?? 5.0,
                    bacWaterMl: double.tryParse(bacCtrl.text) ?? 2.0,
                    doseUnits: double.tryParse(doseUnitsCtrl.text) ?? 10.0,
                    frequency: frequency,
                    cycleDays: int.tryParse(cycleDaysCtrl.text) ?? 60,
                    restDays: int.tryParse(restDaysCtrl.text) ?? 30,
                    startDate: DateTime.now(),
                    route: route,
                  ));
                  if (ctx.mounted) Navigator.of(ctx).pop();
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
