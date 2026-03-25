import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/activity_snapshot_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/config_data_source_ob.dart';
import 'package:opennutritracker/core/db/data_sources/eco_score_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/peptide_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/services/core_motion_service.dart';
import 'package:opennutritracker/core/services/location_inference_service.dart';
import 'package:opennutritracker/core/services/observation_agent.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/calc/optimal_range_calc.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/services/nutrient_recommendation_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

/// Agentic suggestions that react to user actions.
/// All computation is on-device. Nothing leaves the phone.
class AgentSuggestion {
  final String type; // meal_pattern, nutrient_gap, fasting_adapt, reorder, summary
  final String title;
  final String message;
  final String? actionLabel;
  final Function()? onAction;

  AgentSuggestion({
    required this.type,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
}

class AgentService {
  static final _log = Logger('AgentService');

  /// React to app foreground — check all agents and return suggestions.
  static Future<List<AgentSuggestion>> getSuggestions() async {
    final suggestions = <AgentSuggestion>[];

    try { suggestions.addAll(await _mealPatternAgent()); } catch (_) {}
    try { suggestions.addAll(await _nutrientGapAgent()); } catch (_) {}
    try { suggestions.addAll(await _fastingAdaptAgent()); } catch (_) {}
    try { suggestions.addAll(await _supplementReminderAgent()); } catch (_) {}
    try { suggestions.addAll(await _hydrationAgent()); } catch (_) {}
    try { suggestions.addAll(await _biomarkerAgent()); } catch (_) {}
    try { suggestions.addAll(await _sedentaryAgent()); } catch (_) {}
    try { suggestions.addAll(await _gymFrequencyAgent()); } catch (_) {}
    try { suggestions.addAll(await _outdoorTimeAgent()); } catch (_) {}
    try { suggestions.addAll(await _peptideReminderAgent()); } catch (_) {}
    try { suggestions.addAll(await _ecoScoreAgent()); } catch (_) {}

    // Cross-agent observation engine — finds contradictions and correlations
    try { suggestions.addAll(await ObservationAgent.observe()); } catch (_) {}

    // Priority order: observations first, then reminders, then informational
    const typePriority = {
      'observation': 0,
      'nutrient_gap': 1,
      'peptide_reminder': 2,
      'supplement_reminder': 3,
      'hydration': 4,
      'sedentary': 5,
      'meal_pattern': 6,
      'eco_score': 7,
      'biomarker_stale': 8,
      'biomarker_wellness': 9,
      'fasting_adapt': 10,
      'gym_frequency': 11,
      'outdoor_time': 12,
    };

    suggestions.sort((a, b) {
      final pa = typePriority[a.type] ?? 99;
      final pb = typePriority[b.type] ?? 99;
      return pa.compareTo(pb);
    });

    // Cap at 3 to avoid notification fatigue
    if (suggestions.length > 3) {
      suggestions.removeRange(3, suggestions.length);
    }

    _log.info('AgentService generated ${suggestions.length} suggestions');
    return suggestions;
  }

  // ── Meal Pattern Agent ──

  /// Suggests meals based on what you usually eat at this time on this day.
  static Future<List<AgentSuggestion>> _mealPatternAgent() async {
    final getIntake = locator<GetIntakeUsecase>();
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    // Look at same day of week over last 4 weeks
    final meals = <String, int>{};
    for (int w = 1; w <= 4; w++) {
      final day = now.subtract(Duration(days: 7 * w));
      final dayIntakes = [
        ...await getIntake.getBreakfastIntakeByDay(day),
        ...await getIntake.getLunchIntakeByDay(day),
        ...await getIntake.getDinnerIntakeByDay(day),
        ...await getIntake.getSnackIntakeByDay(day),
      ];
      for (final intake in dayIntakes) {
        final name = intake.meal.name;
        if (name != null && name.isNotEmpty) {
          meals[name] = (meals[name] ?? 0) + 1;
        }
      }
    }

    // Find meals that appeared 3+ times on this day of week
    final frequent = meals.entries
        .where((e) => e.value >= 3)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (frequent.isEmpty) return [];

    final topMeal = frequent.first.key;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return [
      AgentSuggestion(
        type: 'meal_pattern',
        title: 'Your usual ${dayNames[dayOfWeek - 1]} meal',
        message: 'You often have $topMeal — log it?',
      ),
    ];
  }

  // ── Nutrient Gap Agent ──

  /// After logging meals, suggests foods to fill nutrient gaps.
  static Future<List<AgentSuggestion>> _nutrientGapAgent() async {
    final getIntake = locator<GetIntakeUsecase>();
    final user = await locator<GetUserUsecase>().getUserData();
    final now = DateTime.now();

    // Only suggest after noon (enough meals logged)
    if (now.hour < 12) return [];

    final allIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(now),
      ...await getIntake.getLunchIntakeByDay(now),
      ...await getIntake.getDinnerIntakeByDay(now),
      ...await getIntake.getSnackIntakeByDay(now),
    ];

    if (allIntakes.isEmpty) return [];

    // Compute nutrient totals
    final totals = <String, double>{};
    for (final intake in allIntakes) {
      final n = intake.meal.nutriments;
      final a = intake.amount;
      void add(String key, double? per100) {
        if (per100 != null) totals[key] = (totals[key] ?? 0) + a * per100 / 100;
      }
      add('iron', n.iron100);
      add('calcium', n.calcium100);
      add('vitaminC', n.vitaminC100);
      add('vitaminD', n.vitaminD100);
      add('magnesium', n.magnesium100);
      add('potassium', n.potassium100);
    }

    final gaps = NutrientRecommendationService.getRecommendations(
      dailyTotals: totals, gender: user.gender.index, age: user.age,
    );

    if (gaps.isEmpty) return [];

    final topGap = gaps.first;
    final topFood = topGap.suggestions.isNotEmpty
        ? topGap.suggestions.first.food
        : null;

    return [
      AgentSuggestion(
        type: 'nutrient_gap',
        title: '${topGap.nutrient} is low (${topGap.pctRda.round()}%)',
        message: topFood != null
            ? 'Add $topFood to boost ${topGap.nutrient}'
            : 'Consider foods rich in ${topGap.nutrient}',
      ),
    ];
  }

  // ── Fasting Adapt Agent ──

  /// If user consistently exceeds their fasting target, suggest a longer protocol.
  static Future<List<AgentSuggestion>> _fastingAdaptAgent() async {
    final fastingDs = locator<FastingDataSource>();
    final sessions = await fastingDs.getCompletedSessions(limit: 14);

    if (sessions.length < 7) return [];

    final avgHours = sessions
        .map((s) => s.elapsedHours)
        .reduce((a, b) => a + b) / sessions.length;
    final currentTarget = sessions.first.targetHours;

    // If averaging 2+ hours over target for 7+ sessions
    if (avgHours >= currentTarget + 2) {
      final nextProtocol = currentTarget < 18 ? '18:6' : '20:4';
      return [
        AgentSuggestion(
          type: 'fasting_adapt',
          title: 'Ready for $nextProtocol?',
          message: 'You\'ve averaged ${avgHours.toStringAsFixed(1)}h fasts — try $nextProtocol',
        ),
      ];
    }

    return [];
  }

  // ── Supplement Reminder Agent ──

  /// Reminds about supplements not yet taken today.
  static Future<List<AgentSuggestion>> _supplementReminderAgent() async {
    final now = DateTime.now();
    if (now.hour < 8 || now.hour > 20) return [];

    final suppDs = locator<SupplementDataSource>();
    final all = await suppDs.getAllActive();
    final taken = await suppDs.getTakenIdsForDate(now);

    final remaining = all.length - taken.length;
    if (remaining <= 0 || all.isEmpty) return [];

    // Only suggest if more than half not taken and it's past 10 AM
    if (now.hour >= 10 && remaining > all.length ~/ 2) {
      return [
        AgentSuggestion(
          type: 'supplement_reminder',
          title: '$remaining supplements pending',
          message: 'Don\'t forget your supplements today',
        ),
      ];
    }

    return [];
  }

  // ── Hydration Agent ──

  /// Gentle water reminder based on intake pace.
  static Future<List<AgentSuggestion>> _hydrationAgent() async {
    final now = DateTime.now();
    if (now.hour < 9 || now.hour > 21) return [];

    final waterDs = locator<WaterDataSource>();
    final todayMl = await waterDs.getTodayTotal();
    final targetMl = 2500.0;

    // Expected pace: linear over 9 AM to 9 PM (12 hours)
    final hoursSince9 = (now.hour - 9).clamp(0, 12);
    final expectedMl = (hoursSince9 / 12) * targetMl;

    if (todayMl < expectedMl * 0.6) {
      final deficit = (expectedMl - todayMl).round();
      return [
        AgentSuggestion(
          type: 'hydration',
          title: 'Drink water',
          message: 'You\'re ${deficit}ml behind pace. Have a glass!',
        ),
      ];
    }

    return [];
  }

  // ── Biomarker Agent ──

  /// Prompts to update stale biomarkers and log wellness scores.
  static Future<List<AgentSuggestion>> _biomarkerAgent() async {
    final bioDs = locator<BiomarkerDataSource>();
    final latest = await bioDs.getLatestByType();
    final now = DateTime.now();

    // Check for stale biomarkers
    final stale = <String>[];
    for (final entry in latest.entries) {
      final def = OptimalRangeCalc.getDefinition(entry.key);
      if (def == null) continue;
      final daysSince = now.difference(entry.value.dateTime).inDays;
      if (daysSince > def.refreshDays) {
        stale.add(def.name);
      }
    }

    if (stale.isNotEmpty) {
      return [
        AgentSuggestion(
          type: 'biomarker_stale',
          title: '${stale.length} biomarker${stale.length > 1 ? 's' : ''} outdated',
          message: '${stale.take(3).join(', ')}${stale.length > 3 ? '...' : ''}'
              ' — time to re-measure',
        ),
      ];
    }

    // Check for wellness scores not logged this week
    final wellnessKeys = ['hair_health', 'skin_health', 'teeth_health', 'energy_level', 'stress_level'];
    final missingWellness = wellnessKeys.where((key) {
      final record = latest[key];
      if (record == null) return true;
      return now.difference(record.dateTime).inDays > 7;
    }).toList();

    if (missingWellness.isNotEmpty) {
      return [
        AgentSuggestion(
          type: 'biomarker_wellness',
          title: 'Weekly wellness check',
          message: 'Rate your hair, skin, teeth, energy, and stress this week',
        ),
      ];
    }

    return [];
  }

  // ── Sedentary Agent ──
  static Future<List<AgentSuggestion>> _sedentaryAgent() async {
    final now = DateTime.now();
    if (now.hour < 7 || now.hour >= 22) return []; // sleep hours

    final motionService = locator<CoreMotionService>();
    final stationaryMin = await motionService.getStationaryMinutes();
    if (stationaryMin < 180) return []; // less than 3 hours

    // Check if already active today
    final snapshotDs = locator<ActivitySnapshotDataSource>();
    final today = await snapshotDs.getTodaySnapshots();
    final activeToday = today.where((s) =>
        s.activityType == 'walking' || s.activityType == 'running').length;
    if (activeToday > 3) return []; // been active enough

    return [
      AgentSuggestion(
        type: 'sedentary',
        title: 'Time to move',
        message: 'You\'ve been sitting for ${stationaryMin ~/ 60}+ hours — even a 5 min walk helps.',
      ),
    ];
  }

  // ── Gym Frequency Agent ──
  static Future<List<AgentSuggestion>> _gymFrequencyAgent() async {
    final visitDs = locator<LocationVisitDataSource>();
    final gymCount = await visitDs.getThisWeekGymCount();

    // Only if user has gym visits (means they have a saved gym location)
    if (gymCount == 0) {
      final recentGym = await visitDs.getVisitsByLabel('gym', days: 30);
      if (recentGym.isEmpty) return []; // no gym history at all
      return [
        AgentSuggestion(
          type: 'gym_frequency',
          title: 'No gym visits this week',
          message: 'Schedule a session to stay on track.',
        ),
      ];
    }

    if (gymCount >= 3) {
      return [
        AgentSuggestion(
          type: 'gym_frequency',
          title: '$gymCount gym visits this week',
          message: 'Great consistency! Keep it up.',
        ),
      ];
    }

    return [];
  }

  // ── Outdoor Time Agent ──
  static Future<List<AgentSuggestion>> _outdoorTimeAgent() async {
    final now = DateTime.now();
    if (now.hour < 14) return []; // only suggest after 2pm

    final locationService = locator<LocationInferenceService>();
    final outdoorMin = await locationService.getOutdoorMinutesToday();

    if (outdoorMin < 15) {
      return [
        AgentSuggestion(
          type: 'outdoor_time',
          title: 'Get some sun',
          message: 'Only ${outdoorMin.round()} min outside today — sunlight boosts vitamin D and mood.',
        ),
      ];
    }

    return [];
  }

  // ── Peptide Reminder Agent ──
  static Future<List<AgentSuggestion>> _peptideReminderAgent() async {
    final now = DateTime.now();
    if (now.hour < 8 || now.hour > 22) return [];

    final ds = locator<PeptideDataSource>();
    final active = await ds.getAllActive();
    final todayLogged = await ds.getTodayLoggedIds();

    final pending = active.where((p) => p.isDoseDay && !todayLogged.contains(p.id)).toList();
    if (pending.isEmpty) return [];

    final names = pending.map((p) => p.name).join(', ');
    return [
      AgentSuggestion(
        type: 'peptide_reminder',
        title: '${pending.length} peptide${pending.length > 1 ? 's' : ''} due',
        message: '$names — don\'t forget today\'s dose',
      ),
    ];
  }

  // ── Eco-Score Agent ──

  /// Prompts the user to fill in missing eco-scores when more than half of
  /// today's intakes are unscored.
  static Future<List<AgentSuggestion>> _ecoScoreAgent() async {
    final configDs = locator<ConfigDataSourceOB>();
    final showSustainability = configDs.getShowSustainability();
    if (!showSustainability) return [];

    final getIntake = locator<GetIntakeUsecase>();
    final now = DateTime.now();
    if (now.hour < 12) return []; // only after noon

    final allIntakes = [
      ...await getIntake.getBreakfastIntakeByDay(now),
      ...await getIntake.getLunchIntakeByDay(now),
      ...await getIntake.getDinnerIntakeByDay(now),
      ...await getIntake.getSnackIntakeByDay(now),
    ];

    if (allIntakes.isEmpty) return [];

    final ecoDs = locator<EcoScoreDataSource>();
    int missing = 0;
    final int total = allIntakes.length;

    for (final intake in allIntakes) {
      final hasScore = intake.meal.ecoscoreScore != null;
      if (!hasScore) {
        final code = intake.meal.code;
        if (code != null) {
          final cached = await ecoDs.getByProductKey(code);
          if (cached == null) missing++;
        } else {
          missing++;
        }
      }
    }

    if (missing > 0 && missing > total ~/ 2) {
      return [
        AgentSuggestion(
          type: 'eco_score',
          title: '$missing items missing eco-score',
          message: 'Add eco-scores to improve your sustainability tracking',
        ),
      ];
    }

    return [];
  }
}
