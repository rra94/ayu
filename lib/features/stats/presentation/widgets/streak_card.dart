import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/services/streak_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  bool _loading = true;
  StreakResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final intakeUsecase = locator<GetIntakeUsecase>();
    final allIntakes = await intakeUsecase.getAllIntakes();
    final result = StreakService.computeStreak(allIntakes);
    setState(() {
      _result = result;
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
                Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Clean Streak',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_result != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(theme, '${_result!.currentStreak}',
                      'Clean', Colors.orange),
                  _buildStat(theme, '${_result!.longestStreak}',
                      'Longest', theme.colorScheme.primary),
                  _buildStat(theme, '${_result!.fastingDaysThisMonth}',
                      'Fasts/mo', Colors.purple),
                  _buildStat(theme, '${_result!.monthlyCheatCount}',
                      'Cheats', Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _result!.motivationalText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
      ThemeData theme, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
