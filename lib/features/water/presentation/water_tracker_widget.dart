import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WaterTrackerWidget extends StatelessWidget {
  final double currentML;
  final double goalML;
  final void Function(double ml) onAddWater;

  const WaterTrackerWidget({
    super.key,
    required this.currentML,
    required this.goalML,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = goalML > 0 ? (currentML / goalML).clamp(0.0, 1.0) : 0.0;
    final currentL = (currentML / 1000).toStringAsFixed(1);
    final goalL = (goalML / 1000).toStringAsFixed(1);

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(Icons.water_drop, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearPercentIndicator(
                    lineHeight: 14.0,
                    percent: percent,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    progressColor: theme.colorScheme.primary,
                    barRadius: const Radius.circular(7),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$currentL / $goalL L',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick-add buttons
            Row(
              children: [
                _QuickAddButton(
                  label: '+250ml',
                  onTap: () => onAddWater(250),
                ),
                const SizedBox(width: 8),
                _QuickAddButton(
                  label: '+500ml',
                  onTap: () => onAddWater(500),
                ),
                const SizedBox(width: 8),
                _QuickAddButton(
                  label: '+Custom',
                  onTap: () => _showCustomDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Water'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            hintText: 'e.g. 350',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                onAddWater(value);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
