import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/entities/config_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/objectbox.g.dart';

class StepsCard extends StatefulWidget {
  const StepsCard({super.key});

  @override
  State<StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {
  bool _loading = true;
  int _todaySteps = 0;
  int _stepGoal = 10000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Get step goal from config
    final store = locator<Store>();
    final config = store.box<ConfigOB>().getAll().firstOrNull;
    final goal = config?.dailyStepGoal ?? 10000;

    // Get today's steps from biomarker records (synced from HealthKit)
    final bioDs = locator<BiomarkerDataSource>();
    final stepRecords = await bioDs.getRecordsByType('steps');
    final now = DateTime.now();
    final todaySteps = stepRecords
        .where((r) =>
            r.dateTime.year == now.year &&
            r.dateTime.month == now.month &&
            r.dateTime.day == now.day)
        .fold<double>(0, (sum, r) => sum + r.value);

    if (mounted) {
      setState(() {
        _todaySteps = todaySteps.round();
        _stepGoal = goal;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = _stepGoal > 0 ? (_todaySteps / _stepGoal).clamp(0.0, 1.0) : 0.0;
    final goalMet = _todaySteps >= _stepGoal;

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: pct,
                strokeWidth: 4,
                backgroundColor: Colors.green.withValues(alpha: 0.15),
                color: goalMet ? Colors.green : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_walk, size: 18,
                          color: goalMet ? Colors.green : theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Steps',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (!_loading)
                    Text(
                      '$_todaySteps / $_stepGoal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: goalMet ? Colors.green : theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Text('Loading...', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, size: 18),
              onPressed: () => _showGoalDialog(context),
              tooltip: 'Set step goal',
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final controller = TextEditingController(text: _stepGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily Step Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            hintText: '10000',
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
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                final store = locator<Store>();
                final configBox = store.box<ConfigOB>();
                final config = configBox.getAll().firstOrNull ?? ConfigOB();
                config.dailyStepGoal = value;
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
