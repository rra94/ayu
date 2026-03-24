import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/sleep_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/services/streak_service.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class TodayViewCard extends StatefulWidget {
  final double caloriesConsumed;
  final double calorieGoal;

  const TodayViewCard({
    super.key,
    required this.caloriesConsumed,
    required this.calorieGoal,
  });

  @override
  State<TodayViewCard> createState() => _TodayViewCardState();
}

class _TodayViewCardState extends State<TodayViewCard> {
  double _waterPct = 0;
  int _suppsTaken = 0;
  int _suppsTotal = 0;
  double? _sleepHours;
  int _streak = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final waterDs = locator<WaterDataSource>();
      final waterMl = await waterDs.getTodayTotal();

      final suppDs = locator<SupplementDataSource>();
      final supps = await suppDs.getAllActive();
      final taken = await suppDs.getTakenIdsForDate(DateTime.now());

      final sleepDs = locator<SleepDataSource>();
      final lastSleep = await sleepDs.getLastNight();
      final now = DateTime.now();
      final sleepToday = lastSleep != null &&
              lastSleep.wakeTime.year == now.year &&
              lastSleep.wakeTime.month == now.month &&
              lastSleep.wakeTime.day == now.day
          ? lastSleep.durationHours
          : null;

      final intakeUsecase = locator<GetIntakeUsecase>();
      final allIntakes = await intakeUsecase.getAllIntakes();
      final streakResult = StreakService.computeStreak(allIntakes);

      if (mounted) {
        setState(() {
          _waterPct = (waterMl / 2500).clamp(0, 1);
          _suppsTaken = taken.length;
          _suppsTotal = supps.length;
          _sleepHours = sleepToday;
          _streak = streakResult.currentStreak;
          _loaded = true;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox();
    final theme = Theme.of(context);
    final calPct = widget.calorieGoal > 0
        ? (widget.caloriesConsumed / widget.calorieGoal).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MiniGauge(
              value: calPct,
              label: '${widget.caloriesConsumed.round()}',
              subtitle: 'kcal',
              color: calPct > 1 ? Colors.red : theme.colorScheme.primary,
            ),
            _MiniGauge(
              value: _waterPct,
              label: '${(_waterPct * 100).round()}%',
              subtitle: 'water',
              color: Colors.blue,
            ),
            _MiniStat(
              value: '$_suppsTaken/$_suppsTotal',
              subtitle: 'supps',
              color: _suppsTaken == _suppsTotal && _suppsTotal > 0
                  ? Colors.green
                  : Colors.orange,
            ),
            if (_sleepHours != null)
              _MiniStat(
                value: '${_sleepHours!.toStringAsFixed(1)}h',
                subtitle: 'sleep',
                color: _sleepHours! >= 7 ? Colors.green : Colors.orange,
              ),
            _MiniStat(
              value: '$_streak',
              subtitle: 'streak',
              color: _streak >= 7 ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniGauge extends StatelessWidget {
  final double value;
  final String label;
  final String subtitle;
  final Color color;

  const _MiniGauge({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            value: value.clamp(0, 1),
            strokeWidth: 3,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: color)),
        Text(subtitle,
            style: TextStyle(fontSize: 8,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String subtitle;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: color)),
        Text(subtitle,
            style: TextStyle(fontSize: 8,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
