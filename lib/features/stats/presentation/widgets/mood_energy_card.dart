import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/db/data_sources/symptom_data_source.dart';
import 'package:opennutritracker/core/db/entities/symptom_log_ob.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class MoodEnergyCard extends StatefulWidget {
  const MoodEnergyCard({super.key});

  @override
  State<MoodEnergyCard> createState() => _MoodEnergyCardState();
}

class _MoodEnergyCardState extends State<MoodEnergyCard> {
  int? _todayMood;
  int? _todayEnergy;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = locator<SymptomDataSource>();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final logs = await ds.getLogsByDateRange(start, end);

    // Find today's mood (symptom 8 = Low mood → invert for mood scale)
    // and energy (symptom 3 = Energy crash → invert for energy scale)
    for (final log in logs) {
      if (log.symptom == 100) _todayMood = log.severity; // custom mood
      if (log.symptom == 101) _todayEnergy = log.severity; // custom energy
    }
    if (mounted) setState(() {});
  }

  Future<void> _logMood(int value) async {
    final ds = locator<SymptomDataSource>();
    await ds.addLog(SymptomLogOB(
      symptom: 100, // custom: mood
      severity: value,
      dateTime: DateTime.now(),
    ));
    setState(() => _todayMood = value);
  }

  Future<void> _logEnergy(int value) async {
    final ds = locator<SymptomDataSource>();
    await ds.addLog(SymptomLogOB(
      symptom: 101, // custom: energy
      severity: value,
      dateTime: DateTime.now(),
    ));
    setState(() => _todayEnergy = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling?',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Mood ', style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
                ...List.generate(5, (i) {
                  final val = i + 1;
                  final selected = _todayMood == val;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _logMood(val);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _moodEmoji(val),
                        style: TextStyle(
                          fontSize: selected ? 24 : 18,
                          color: selected ? null : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Energy', style: theme.textTheme.bodySmall),
                const SizedBox(width: 4),
                ...List.generate(5, (i) {
                  final val = i + 1;
                  final selected = _todayEnergy == val;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _logEnergy(val);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _energyEmoji(val),
                        style: TextStyle(
                          fontSize: selected ? 24 : 18,
                          color: selected ? null : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _moodEmoji(int val) {
    switch (val) {
      case 1: return '😢';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '😐';
    }
  }

  String _energyEmoji(int val) {
    switch (val) {
      case 1: return '🔋';
      case 2: return '⚡';
      case 3: return '💪';
      case 4: return '🔥';
      case 5: return '⚡⚡';
      default: return '⚡';
    }
  }
}
