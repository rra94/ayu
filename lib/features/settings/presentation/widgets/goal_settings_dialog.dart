import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/entities/config_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/objectbox.g.dart';

class GoalSettingsDialog extends StatefulWidget {
  const GoalSettingsDialog({super.key});

  @override
  State<GoalSettingsDialog> createState() => _GoalSettingsDialogState();
}

class _GoalSettingsDialogState extends State<GoalSettingsDialog> {
  late TextEditingController _targetWeightCtrl;
  late TextEditingController _deficitCtrl;
  late double _carbPct;
  late double _proteinPct;
  late double _fatPct;

  @override
  void initState() {
    super.initState();
    final store = locator<Store>();
    final config = store.box<ConfigOB>().getAll().firstOrNull ?? ConfigOB();

    _targetWeightCtrl = TextEditingController(
        text: config.targetWeightKG?.toStringAsFixed(1) ?? '');
    _deficitCtrl = TextEditingController(
        text: config.customDeficitKcal?.abs().toStringAsFixed(0) ?? '500');
    _carbPct = config.userCarbGoalPct ?? 40;
    _proteinPct = config.userProteinGoalPct ?? 30;
    _fatPct = config.userFatGoalPct ?? 30;
  }

  @override
  void dispose() {
    _targetWeightCtrl.dispose();
    _deficitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final macroTotal = _carbPct + _proteinPct + _fatPct;
    final macroValid = (macroTotal - 100).abs() < 1;

    return AlertDialog(
      title: const Text('Weight & Macro Goals'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target weight
            TextField(
              controller: _targetWeightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target weight (kg)',
                hintText: 'e.g. 70.0',
              ),
            ),
            const SizedBox(height: 16),

            // Daily deficit
            Text('Daily calorie deficit',
                style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _deficitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Deficit (kcal/day)',
                hintText: '500 = ~0.45kg/week loss',
                suffixText: 'kcal',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getDeficitDescription(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            // Macro ratios
            Text('Macro ratios',
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            _buildMacroSlider('Carbs', _carbPct, Colors.orange, (v) {
              setState(() => _carbPct = v);
            }),
            _buildMacroSlider('Protein', _proteinPct, Colors.blue, (v) {
              setState(() => _proteinPct = v);
            }),
            _buildMacroSlider('Fat', _fatPct, Colors.red, (v) {
              setState(() => _fatPct = v);
            }),

            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Total: ${macroTotal.round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: macroValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!macroValid) ...[
                  const SizedBox(width: 8),
                  Text('Must equal 100%',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.red)),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Presets
            Text('Presets', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Balanced'),
                  onPressed: () => setState(() {
                    _carbPct = 40; _proteinPct = 30; _fatPct = 30;
                  }),
                ),
                ActionChip(
                  label: const Text('High Protein'),
                  onPressed: () => setState(() {
                    _carbPct = 30; _proteinPct = 40; _fatPct = 30;
                  }),
                ),
                ActionChip(
                  label: const Text('Low Carb'),
                  onPressed: () => setState(() {
                    _carbPct = 20; _proteinPct = 35; _fatPct = 45;
                  }),
                ),
                ActionChip(
                  label: const Text('Keto'),
                  onPressed: () => setState(() {
                    _carbPct = 5; _proteinPct = 25; _fatPct = 70;
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: macroValid ? _save : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildMacroSlider(
      String label, double value, Color color, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 55, child: Text('$label:', style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: color,
            label: '${value.round()}%',
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 35,
          child: Text('${value.round()}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }

  String _getDeficitDescription() {
    final deficit = double.tryParse(_deficitCtrl.text) ?? 500;
    final weeklyLoss = deficit * 7 / 7700; // 7700 kcal = 1 kg fat
    return '~${weeklyLoss.toStringAsFixed(2)} kg/week loss';
  }

  void _save() {
    final store = locator<Store>();
    final configBox = store.box<ConfigOB>();
    final config = configBox.getAll().firstOrNull ?? ConfigOB();

    final targetWeight = double.tryParse(_targetWeightCtrl.text);
    final deficit = double.tryParse(_deficitCtrl.text);

    config.targetWeightKG = targetWeight;
    config.customDeficitKcal = deficit != null ? -deficit : null;
    config.userCarbGoalPct = _carbPct;
    config.userProteinGoalPct = _proteinPct;
    config.userFatGoalPct = _fatPct;

    configBox.put(config);
    Navigator.of(context).pop(true);
  }
}
