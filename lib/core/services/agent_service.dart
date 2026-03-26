import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/db/data_sources/activity_snapshot_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/biomarker_data_source.dart';
import 'package:opennutritracker/core/services/agent_context.dart';
import 'package:opennutritracker/core/services/data_collection_agent.dart';
import 'package:opennutritracker/core/db/data_sources/config_data_source_ob.dart';
import 'package:opennutritracker/core/db/data_sources/eco_score_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/location_visit_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/peptide_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/supplement_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/services/circadian_service.dart';
import 'package:opennutritracker/core/services/core_motion_service.dart';
import 'package:opennutritracker/core/services/hrv_analysis_service.dart';
import 'package:opennutritracker/core/services/location_inference_service.dart';
import 'package:opennutritracker/core/services/calendar_service.dart';
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

// AgentContext is defined in agent_context.dart and re-exported via the import above.

class AgentService {
  static final _log = Logger('AgentService');

  // Rate-limit: max once per 5 minutes
  static DateTime? _lastRun;
  static List<AgentSuggestion>? _cachedSuggestions;

  /// React to app foreground — check all agents and return suggestions.
  /// Observations run FIRST to build shared context, then agents use it.
  static Future<List<AgentSuggestion>> getSuggestions() async {
    if (_lastRun != null &&
        DateTime.now().difference(_lastRun!).inMinutes < 5 &&
        _cachedSuggestions != null) {
      return _cachedSuggestions!;
    }
    _lastRun = DateTime.now();

    final suggestions = <AgentSuggestion>[];

    // Phase 1: Observations run first — build shared context
    final ctx = AgentContext();

    // Load today's intakes ONCE — agents use ctx.todayIntakes to avoid 50+ queries
    try {
      final getIntake = locator<GetIntakeUsecase>();
      final now = DateTime.now();
      ctx.todayIntakes = [
        ...await getIntake.getBreakfastIntakeByDay(now),
        ...await getIntake.getLunchIntakeByDay(now),
        ...await getIntake.getDinnerIntakeByDay(now),
        ...await getIntake.getSnackIntakeByDay(now),
      ];
    } catch (e) { debugPrint('AgentService loadIntakes: $e'); }

    // Check current place for context
    try {
      final place = locator<LocationInferenceService>().lastDetectedPlace;
      if (place != null) {
        ctx.currentPlace = place['category'] as String?;
        ctx.currentPlaceName = place['name'] as String?;
      }
    } catch (e) { debugPrint('AgentService placeDetect: $e'); }

    try {
      final obs = await ObservationAgent.observe(ctx);
      suggestions.addAll(obs);
    } catch (e) { debugPrint('observationAgent: $e'); }

    // Phase 2: Agents run informed by observation context
    // Stress agent runs early — it sets ctx.lowMood for downstream agents
    try { suggestions.addAll(await _stressAgent(ctx)); } catch (e) { debugPrint('stressAgent: $e'); }

    // Skip agents whose topic is already covered by an observation
    try { if (!ctx.isAlreadyCovered('meal_pattern')) suggestions.addAll(await _mealPatternAgent()); } catch (e) { debugPrint('mealPatternAgent: $e'); }
    try { if (!ctx.isAlreadyCovered('nutrient_gap')) suggestions.addAll(await _nutrientGapAgent(ctx)); } catch (e) { debugPrint('nutrientGapAgent: $e'); }
    try { suggestions.addAll(await _fastingAdaptAgent()); } catch (e) { debugPrint('fastingAdaptAgent: $e'); }
    try { suggestions.addAll(await _supplementTimingAgent()); } catch (e) { debugPrint('supplementTimingAgent: $e'); }
    try { suggestions.addAll(await _circadianAgent(ctx)); } catch (e) { debugPrint('circadianAgent: $e'); }
    try { suggestions.addAll(await _hydrationAgent(ctx)); } catch (e) { debugPrint('hydrationAgent: $e'); }
    try { suggestions.addAll(await _biomarkerAgent()); } catch (e) { debugPrint('biomarkerAgent: $e'); }
    try { if (!ctx.isAlreadyCovered('sedentary')) suggestions.addAll(await _sedentaryAgent()); } catch (e) { debugPrint('sedentaryAgent: $e'); }
    try { suggestions.addAll(await _gymFrequencyAgent()); } catch (e) { debugPrint('gymFrequencyAgent: $e'); }
    try { if (!ctx.isAlreadyCovered('outdoor_time')) suggestions.addAll(await _outdoorTimeAgent()); } catch (e) { debugPrint('outdoorTimeAgent: $e'); }
    try { suggestions.addAll(await _peptideReminderAgent()); } catch (e) { debugPrint('peptideReminderAgent: $e'); }
    try { suggestions.addAll(await _ecoScoreAgent(ctx)); } catch (e) { debugPrint('ecoScoreAgent: $e'); }
    try { suggestions.addAll(await _calendarAgent()); } catch (e) { debugPrint('calendarAgent: $e'); }
    try { suggestions.addAll(await _missedDaysAgent(ctx)); } catch (e) { debugPrint('missedDaysAgent: $e'); }

    // Phase 3: Data Collection Agent — sends targeted notification for missing data
    try { await DataCollectionAgent.sendDataRequest(ctx); } catch (e) { debugPrint('dataCollectionAgent: $e'); }

    // Priority order: observations first, then reminders, then informational
    const typePriority = {
      'stress': 0,
      'observation': 1,
      'calendar': 2,
      'circadian': 3,
      'supplement_timing': 4,
      'nutrient_gap': 5,
      'peptide_reminder': 6,
      'supplement_reminder': 7,
      'hydration': 8,
      'sedentary': 9,
      'meal_pattern': 10,
      'eco_score': 11,
      'biomarker_stale': 12,
      'biomarker_wellness': 13,
      'fasting_adapt': 14,
      'gym_frequency': 15,
      'outdoor_time': 16,
      'missed_days': 1, // high priority — welcome back message
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
    _cachedSuggestions = suggestions;
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
  /// Context-aware: if gym day detected, prioritize protein/magnesium.
  static Future<List<AgentSuggestion>> _nutrientGapAgent(AgentContext ctx) async {
    final user = await locator<GetUserUsecase>().getUserData();
    final now = DateTime.now();

    // Only suggest after noon (enough meals logged)
    if (now.hour < 12) return [];

    final allIntakes = ctx.todayIntakes;

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

    // Context-aware: on gym days, prioritize protein and magnesium
    var topGap = gaps.first;
    if (ctx.gymToday) {
      final gymPriority = gaps.where((g) =>
          g.nutrient.toLowerCase().contains('protein') ||
          g.nutrient.toLowerCase().contains('magnesium'));
      if (gymPriority.isNotEmpty) topGap = gymPriority.first;
    }

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

  // ── Hydration Agent ──

  /// Gentle water reminder based on intake pace.
  /// Context-aware: more aggressive on active/gym days, mentions caffeine if relevant.
  static Future<List<AgentSuggestion>> _hydrationAgent(AgentContext ctx) async {
    final now = DateTime.now();
    if (now.hour < 9 || now.hour > 21) return [];

    final waterDs = locator<WaterDataSource>();
    final todayMl = await waterDs.getTodayTotal();
    final targetMl = 2500.0;

    // Expected pace: linear over 9 AM to 9 PM (12 hours)
    final hoursSince9 = (now.hour - 9).clamp(0, 12);
    final expectedMl = (hoursSince9 / 12) * targetMl;

    // On active/gym days or pressure drop days, trigger earlier (0.7 instead of 0.6)
    final threshold = (ctx.gymToday || ctx.sedentaryDay == false || ctx.pressureDrop) ? 0.7 : 0.6;

    if (todayMl < expectedMl * threshold) {
      final deficit = (expectedMl - todayMl).round();
      final reason = ctx.gymToday
          ? ' — extra important on gym days'
          : ctx.highCaffeine
              ? ' — caffeine dehydrates, drink extra'
              : ctx.pressureDrop
                  ? ' — pressure dropped, hydration helps'
                  : '';
      return [
        AgentSuggestion(
          type: 'hydration',
          title: 'Drink water',
          message: 'You\'re ${deficit}ml behind pace$reason.',
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
  static Future<List<AgentSuggestion>> _ecoScoreAgent(AgentContext ctx) async {
    final configDs = locator<ConfigDataSourceOB>();
    final showSustainability = configDs.getShowSustainability();
    if (!showSustainability) return [];

    final now = DateTime.now();
    if (now.hour < 12) return []; // only after noon

    final allIntakes = ctx.todayIntakes;

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

  // ── Calendar Agent ──

  /// Reads today's calendar events and gives time-sensitive nutrition advice.
  static Future<List<AgentSuggestion>> _calendarAgent() async {
    final events = await CalendarService.getTodayEvents();
    if (events.isEmpty) return [];

    final now = DateTime.now().hour + DateTime.now().minute / 60.0;

    for (final event in events) {
      final hoursUntil = event.startHour - now;
      if (hoursUntil < 0 || hoursUntil > 4) continue; // only next 4 hours

      switch (event.inferredType) {
        case 'exercise':
          if (hoursUntil < 2) {
            return [
              AgentSuggestion(
                type: 'calendar',
                title: 'Gym in ${(hoursUntil * 60).round()} min',
                message: 'Have a pre-workout snack with carbs + protein. Hydrate extra.',
              ),
            ];
          }
        case 'dining':
          if (hoursUntil < 3) {
            final restaurant = event.location.isNotEmpty ? event.location : event.title;
            return [
              AgentSuggestion(
                type: 'calendar',
                title: 'Dining out at ${_truncate(restaurant, 25)}',
                message: 'Eat lighter now — save calories for dinner. Consider protein-first at the restaurant.',
              ),
            ];
          }
        case 'travel':
          return [
            AgentSuggestion(
              type: 'calendar',
              title: 'Travel day',
              message: 'Pack healthy snacks, stay hydrated (cabin air is dry), and maintain your eating schedule.',
            ),
          ];
        case 'medical':
          final past = event.endHour < now;
          if (past) {
            return [
              AgentSuggestion(
                type: 'calendar',
                title: 'Log your results',
                message: 'You had a medical appointment — update biomarkers with any new lab values.',
              ),
            ];
          }
        case 'fasting':
          return [
            AgentSuggestion(
              type: 'calendar',
              title: 'Fasting scheduled',
              message: 'Your calendar shows a fast today. Stay hydrated with water and electrolytes.',
            ),
          ];
      }
    }

    return [];
  }

  static String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}...' : s;

  // ── Missed Days Agent ──

  /// If the user hasn't logged food in 2+ days, show a welcome-back nudge.
  static Future<List<AgentSuggestion>> _missedDaysAgent(AgentContext ctx) async {
    if (ctx.todayIntakes.isNotEmpty) return []; // logged today, no gap

    final getIntake = locator<GetIntakeUsecase>();
    int daysBack = 0;
    for (int d = 1; d <= 7; d++) {
      final day = DateTime.now().subtract(Duration(days: d));
      final intakes = [
        ...await getIntake.getBreakfastIntakeByDay(day),
        ...await getIntake.getLunchIntakeByDay(day),
        ...await getIntake.getDinnerIntakeByDay(day),
        ...await getIntake.getSnackIntakeByDay(day),
      ];
      if (intakes.isNotEmpty) break;
      daysBack = d;
    }

    if (daysBack >= 2) {
      return [
        AgentSuggestion(
          type: 'missed_days',
          title: 'Welcome back!',
          message: 'You haven\'t logged in $daysBack days. Start fresh today \u2014 every day counts.',
        ),
      ];
    }
    return [];
  }

  // ── Stress Agent ──

  /// Passive stress detection via HRV analysis.
  /// Runs early so it can set ctx.lowMood for downstream agents.
  static Future<List<AgentSuggestion>> _stressAgent(AgentContext ctx) async {
    final stressLevel = await HRVAnalysisService.getStressLevel();
    if (stressLevel <= 2) return []; // low stress, no action needed

    ctx.lowMood = true; // inform other agents

    if (stressLevel >= 4) {
      return [
        AgentSuggestion(
          type: 'stress',
          title: 'High stress detected',
          message: 'Your HRV is below baseline — consider: deep breathing, magnesium, reduce caffeine, short walk.',
        ),
      ];
    }
    if (stressLevel == 3) {
      return [
        AgentSuggestion(
          type: 'stress',
          title: 'Moderate stress',
          message: 'HRV is slightly below your average. Prioritize sleep tonight.',
        ),
      ];
    }
    return [];
  }

  // ── Circadian Agent ──

  /// Monitors eating schedule relative to circadian profile and nudges
  /// the user to close their eating window or maintain meal consistency.
  static Future<List<AgentSuggestion>> _circadianAgent(AgentContext ctx) async {
    final profile = await CircadianService.buildProfile();
    if (profile == null) return [];

    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60.0;

    // Use cached intakes from context
    final todayIntakes = ctx.todayIntakes;

    if (todayIntakes.isNotEmpty) {
      final lastMealHour = todayIntakes
          .map((i) => i.dateTime.hour + i.dateTime.minute / 60.0)
          .reduce((a, b) => a > b ? a : b);
      final hoursBeforeBed = profile.avgBedHour - lastMealHour;
      if (hoursBeforeBed < 2 && hoursBeforeBed > 0) {
        return [
          AgentSuggestion(
            type: 'circadian',
            title: 'Close your eating window',
            message: 'You usually sleep at ${CircadianProfile.formatHour(profile.avgBedHour)} — stop eating now for better sleep.',
          ),
        ];
      }
    }

    // Morning: if no food logged 1h past usual first meal
    if (todayIntakes.isEmpty && currentHour > profile.avgFirstMealHour + 1 && currentHour < 14) {
      return [
        AgentSuggestion(
          type: 'circadian',
          title: 'Late first meal today',
          message: 'You usually eat by ${CircadianProfile.formatHour(profile.avgFirstMealHour)} — a consistent schedule supports circadian rhythm.',
        ),
      ];
    }

    return [];
  }

  // ── Supplement Timing Agent ──

  /// Smart supplement timing based on circadian profile.
  /// Knows when specific supplements are best absorbed and reminds
  /// during the optimal window.
  static Future<List<AgentSuggestion>> _supplementTimingAgent() async {
    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60.0;
    if (currentHour < 7 || currentHour > 22) return [];

    final profile = await CircadianService.buildProfile();
    final suppDs = locator<SupplementDataSource>();
    final all = await suppDs.getAllActive();
    final taken = await suppDs.getTakenIdsForDate(now);

    if (all.isEmpty) return [];
    final remaining = all.where((s) => !taken.contains(s.id)).toList();
    if (remaining.isEmpty) return [];

    // If we have a circadian profile, give specific timing advice
    if (profile != null) {
      final timing = profile.optimalSupplementTiming;

      // Check if any supplement names match timing windows
      for (final supp in remaining) {
        final nameLower = supp.name.toLowerCase();

        if (nameLower.contains('magnesium') && currentHour >= profile.avgBedHour - 1.5 && currentHour < profile.avgBedHour) {
          return [
            AgentSuggestion(
              type: 'supplement_timing',
              title: 'Take magnesium now',
              message: '${timing['magnesium']} — you haven\'t taken it yet.',
            ),
          ];
        }
        if (nameLower.contains('vitamin d') && currentHour >= profile.avgFirstMealHour - 0.5 && currentHour < profile.avgFirstMealHour + 1) {
          return [
            AgentSuggestion(
              type: 'supplement_timing',
              title: 'Take Vitamin D with breakfast',
              message: '${timing['vitamin_d']} — fat-soluble, needs food.',
            ),
          ];
        }
        if (nameLower.contains('iron') && currentHour >= profile.avgFirstMealHour - 1.5 && currentHour < profile.avgFirstMealHour) {
          return [
            AgentSuggestion(
              type: 'supplement_timing',
              title: 'Take iron on empty stomach',
              message: '${timing['iron']} — best absorbed alone.',
            ),
          ];
        }
        if (nameLower.contains('zinc') && currentHour >= profile.avgBedHour - 2.5 && currentHour < profile.avgBedHour - 1) {
          return [
            AgentSuggestion(
              type: 'supplement_timing',
              title: 'Take zinc now',
              message: '${timing['zinc']}',
            ),
          ];
        }
        if ((nameLower.contains('omega') || nameLower.contains('fish oil')) && currentHour >= profile.avgLastMealHour - 0.5 && currentHour < profile.avgLastMealHour + 1) {
          return [
            AgentSuggestion(
              type: 'supplement_timing',
              title: 'Take omega-3 with dinner',
              message: '${timing['omega3']}',
            ),
          ];
        }
      }
    }

    return [];
  }
}
