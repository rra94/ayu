import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/services/core_motion_service.dart';
import 'package:opennutritracker/core/services/location_inference_service.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class ActivityDashboardWidget extends StatefulWidget {
  const ActivityDashboardWidget({super.key});

  @override
  State<ActivityDashboardWidget> createState() =>
      _ActivityDashboardWidgetState();
}

class _ActivityDashboardWidgetState extends State<ActivityDashboardWidget> {
  // Today
  int _steps = 0;
  String _activity = 'unknown';
  double _activeKcal = 0;
  double _outdoorMinutes = 0;

  // This week
  int _gymCount = 0;
  int _workoutsCount = 0;
  double _avgRestingHr = 0;
  bool _hasHrData = false;

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bioDs = locator<BiomarkerDataSource>();
      final motionService = locator<CoreMotionService>();
      final locationService = locator<LocationInferenceService>();
      final visitDs = locator<LocationVisitDataSource>();

      // Today's steps — latest record
      final stepRecords = await bioDs.getRecordsByType('steps');
      final todaySteps = _latestTodayValue(stepRecords);

      // Current activity
      final activity = await motionService.getCurrentActivity();

      // Today's active energy — latest record
      final energyRecords = await bioDs.getRecordsByType('active_energy');
      final todayEnergy = _latestTodayValue(energyRecords);

      // Outdoor minutes today
      double outdoorMin = 0;
      try {
        outdoorMin = await locationService.getOutdoorMinutesToday();
      } catch (_) {}

      // This week gym count
      int gymCount = 0;
      try {
        gymCount = await visitDs.getThisWeekGymCount();
      } catch (_) {}

      // This week workouts count
      final workoutRecords = await bioDs.getRecordsByType('workouts');
      final weekWorkouts = _thisWeekRecords(workoutRecords);

      // This week avg resting HR
      final hrRecords = await bioDs.getRecordsByType('resting_hr');
      final weekHr = _thisWeekRecords(hrRecords);
      final hasHr = weekHr.isNotEmpty;
      final avgHr = hasHr
          ? weekHr.map((r) => r.value).reduce((a, b) => a + b) / weekHr.length
          : 0.0;

      if (mounted) {
        setState(() {
          _steps = todaySteps.round();
          _activity = activity;
          _activeKcal = todayEnergy;
          _outdoorMinutes = outdoorMin;
          _gymCount = gymCount;
          _workoutsCount = weekWorkouts.length;
          _avgRestingHr = avgHr;
          _hasHrData = hasHr;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    }
  }

  double _latestTodayValue(List<BiomarkerRecordOB> records) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    for (final r in records) {
      if (r.dateTime.isAfter(todayStart)) return r.value;
    }
    return 0;
  }

  List<BiomarkerRecordOB> _thisWeekRecords(List<BiomarkerRecordOB> records) {
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final weekStart =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return records
        .where((r) => r.dateTime.isAfter(weekStart))
        .toList();
  }

  IconData _activityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'stationary':
        return Icons.airline_seat_recline_normal;
      case 'walking':
        return Icons.directions_walk;
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'automotive':
        return Icons.directions_car;
      default:
        return Icons.help_outline;
    }
  }

  String _activityLabel(String activity) {
    if (activity.isEmpty || activity == 'unknown') return 'unknown';
    return activity.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox();

    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;
    final goldDim = gold.withValues(alpha: 0.6);

    const stepGoal = 10000;
    final stepPct = (stepGoal > 0 ? _steps / stepGoal : 0.0).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top row: Today ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Steps gauge
                _MiniGauge(
                  value: stepPct,
                  label: _steps >= 1000
                      ? '${(_steps / 1000).toStringAsFixed(1)}k'
                      : '$_steps',
                  subtitle: 'steps',
                  color: stepPct >= 1.0 ? gold : goldDim,
                ),
                // Activity icon
                _MiniIconStat(
                  icon: _activityIcon(_activity),
                  subtitle: _activityLabel(_activity),
                  color: goldDim,
                ),
                // Active calories
                _MiniStat(
                  value: _activeKcal > 0
                      ? '${_activeKcal.round()}'
                      : '—',
                  subtitle: 'cal burned',
                  color: _activeKcal > 0 ? gold : goldDim,
                ),
                // Outdoor minutes
                _MiniStat(
                  value: _outdoorMinutes > 0
                      ? '${_outdoorMinutes.round()}m'
                      : '—',
                  subtitle: 'outdoor',
                  color: _outdoorMinutes >= 30 ? gold : goldDim,
                ),
              ],
            ),

            // ── Bottom row: This Week (only if HealthKit data exists) ──
            if (_hasHrData) ...[
              const SizedBox(height: 8),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Gym visits
                  _MiniStat(
                    value: _gymCount > 0 ? '$_gymCount' : '—',
                    subtitle: 'gym / wk',
                    color: _gymCount >= 3 ? gold : goldDim,
                  ),
                  // Workouts this week
                  _MiniStat(
                    value: _workoutsCount > 0 ? '$_workoutsCount' : '—',
                    subtitle: 'workouts',
                    color: _workoutsCount > 0 ? gold : goldDim,
                  ),
                  // Avg resting HR
                  _MiniStat(
                    value: _avgRestingHr > 0
                        ? '${_avgRestingHr.round()}'
                        : '—',
                    subtitle: 'resting HR',
                    color: _avgRestingHr > 0 && _avgRestingHr < 65
                        ? gold
                        : goldDim,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Private widgets (same style as TodayViewCard) ──

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
            value: value.clamp(0.0, 1.0),
            strokeWidth: 3,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color),
        ),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 8,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
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
        Text(
          value,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 8,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _MiniIconStat extends StatelessWidget {
  final IconData icon;
  final String subtitle;
  final Color color;

  const _MiniIconStat({
    required this.icon,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 8,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
